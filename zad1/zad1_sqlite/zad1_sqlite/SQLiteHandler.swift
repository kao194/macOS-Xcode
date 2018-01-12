//
//  SQLiteHandler.swift
//  zad1_sqlite
//
//  Created by Użytkownik Gość on 08.12.2017.
//  Copyright © 2017 Waclawik. All rights reserved.
//

import Foundation

class SqLiteHandler {

    var db: OpaquePointer? = nil;
    
    func getConnection()->OpaquePointer? {
        if(db==nil) {
            initialize()
        }
    return db;
    }
    
    func initialize() {
        let docDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let dbFilePath = NSURL(fileURLWithPath: docDir).appendingPathComponent("demo.db")?.path
    
        print(dbFilePath!);
        
        if sqlite3_open(dbFilePath, &db) == SQLITE_OK {
            print("ok")
        } else {
            print("fail")
        }
    }
    
    func createTables() {
        let createSensorsTableStatement = "CREATE TABLE IF NOT EXISTS sensors (id INTEGER PRIMARY KEY AUTOINCREMENT, name VARCHAR(50), description VARCHAR(200));"
        if sqlite3_exec(getConnection(), createSensorsTableStatement, nil, nil, nil) == SQLITE_OK {
            print("Table sensors created");
        } else {
            print("fail");
            return;
        }

        let createReadingsTableStatement = "CREATE TABLE IF NOT EXISTS readings (id INTEGER PRIMARY KEY AUTOINCREMENT, timestamp INTEGER, sensor_id INTEGER REFERENCES sensors(id), value REAL);"
        if sqlite3_exec(getConnection(), createReadingsTableStatement, nil, nil, nil) == SQLITE_OK {
            print("Table readings created")
        } else {
            print("fail")
        }


    }

    func createSensorsIfNotPresent() {
        let getAmountOfSensorsCreated = "SELECT count(*) FROM sensors;";
        var amountOfSensorsInDB:Int = 0;
        var stmt: OpaquePointer? = nil
        sqlite3_prepare_v2(getConnection(), getAmountOfSensorsCreated, -1, &stmt, nil)
        while sqlite3_step(stmt) == SQLITE_ROW {
            amountOfSensorsInDB = Int(sqlite3_column_int(stmt, 0))
            print("DB contains \(amountOfSensorsInDB) sensor(s)")
        }
        sqlite3_finalize(stmt)
        
        if(amountOfSensorsInDB) != 20 {
            deleteSensors();
            createSensors();
        }
    }
    
    func createSensors() {
        let getAmountOfSensorsCreated = "INSERT INTO sensors (id, name, description) VALUES (?,?,?)";
        var stmt: OpaquePointer? = nil
        sqlite3_prepare_v2(getConnection(), getAmountOfSensorsCreated, -1, &stmt, nil)
        for i in 1...20 {
            sqlite3_bind_int(stmt, 1, Int32(i))
            let name: NSString
            if i<10 {
                name="S0\(i)" as NSString
            }else {
                name="S\(i)" as NSString
            }
            print(name);
            let desc:NSString = "Sensor number \(i)" as NSString;
            //let SQLITE_TRANSIENT = unsafeBitCast(OpaquePointer(bitPattern: -1), to: sqlite3_destructor_type.self)
            //name.cString(using: .ascii) -- nie zadzialalo (.utf8 rowniez)
            //uzycie name.utf8String pomoze, uzycie SQLITE_TRANSIENT jako 4ty parametr ze zwyklym swiftowym String rowniez
            sqlite3_bind_text(stmt, 2, name.utf8String, -1, nil)
            sqlite3_bind_text(stmt, 3, desc.utf8String, -1, nil)
            if (sqlite3_step(stmt) != SQLITE_DONE) {
                print("\nCould not step (execute) stmt.\n");
            }
            sqlite3_reset(stmt);
        }
        print("Created sensors")
    }
    
    func createSensorsWithoutBinding() {
        for i in 1...20 {
            let name: String
            if i<10 {
                name="S0\(i)"
            }else {
                name="S\(i)"
            }
            print(name);
            let desc: String = "Sensor number \(i)"
            let insertSQL = "INSERT INTO sensors (id, name, description) VALUES (\(i),'\(name)','\(desc)');"
            sqlite3_exec(getConnection(), insertSQL, nil, nil, nil)
        }

    }
    
    func deleteSensors() {
        let createReadingsTableStatement = "DELETE FROM sensors;"
        if sqlite3_exec(getConnection(), createReadingsTableStatement, nil, nil, nil) == SQLITE_OK {
            print("Sensors deleted")
        } else {
            print("fail")
        }
    }
    
    func getSensors() -> Array<Sensor> {
        var sensorsList: Array<Sensor> = Array()
        let getSensorsQuery = "SELECT * FROM sensors;";
        var stmt: OpaquePointer? = nil
        sqlite3_prepare_v2(getConnection(), getSensorsQuery, -1, &stmt, nil)
        while sqlite3_step(stmt) == SQLITE_ROW {
            let id = Int(sqlite3_column_int(stmt, 0))
            let name = String(cString: sqlite3_column_text(stmt, 1))
            let description = String(cString: sqlite3_column_text(stmt, 2))
            print("Sensor: id: \(id), name: \(name), desc: \(description).")
            sensorsList.append(Sensor(id: id, name: name, description: description))
        }
        sqlite3_finalize(stmt)
        return sensorsList
    }
}
