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
    
    func generateReadings(amount: Int) {
        sqlite3_exec(getConnection(), "TRUNCATE TABLE readings;", nil, nil, nil)
        sqlite3_exec(getConnection(), "BEGIN TRANSACTION;", nil, nil, nil)
        
        let insertGeneratedReadingQuery = "INSERT INTO readings (timestamp, sensor_id, value) VALUES (?,?,?)";
        
        var stmt: OpaquePointer? = nil
        sqlite3_prepare_v2(getConnection(), insertGeneratedReadingQuery, -1, &stmt, nil)
        for i in 1...amount {
            
            let sensor = arc4random_uniform(20) + 1
            let sensorId:Int = Int(sensor);
            let value:Float = randomFloat(min: 0, max: 100)
            
            let date: Date = Date();
            // random value of time in the year
            let randomSecondInTheLastYear = arc4random_uniform(31556926) + 1;
            
            var secondsSinceTheBeginning = date.timeIntervalSince1970
            secondsSinceTheBeginning.subtract(Double(randomSecondInTheLastYear));
            
            let timestamp = Int64(secondsSinceTheBeginning*1000)
            
            sqlite3_bind_int64(stmt, 1, timestamp)
            sqlite3_bind_int(stmt, 2, Int32(sensorId))
            sqlite3_bind_double(stmt, 3, Double(value))
            
            if (sqlite3_step(stmt) != SQLITE_DONE) {
                print("\nCould not step (execute) stmt. Did not add reading\n");
            }
            sqlite3_reset(stmt);
            let reading = Reading(id: i, timestamp: timestamp, sensorId: sensorId, value: value);
            print("Reading id: \(reading.id); timestamp: \(reading.timestamp); sensor: \(reading.sensorId); value: \(reading.value)")
        }
        sqlite3_exec(getConnection(), "COMMIT;", nil, nil, nil)
        print("Created Readings")
    }
    
    func findEarliestReading() {
        sqlite3_exec(getConnection(), "SELECT min(timestamp) FROM readings;", nil, nil, nil)
    }
    
    func findLatestReading() {
        sqlite3_exec(getConnection(), "SELECT max(timestamp) FROM readings;", nil, nil, nil)
    }
    
    func findAverageReadingValue() {
        sqlite3_exec(getConnection(), "SELECT avg(value) FROM readings;", nil, nil, nil)
    }
    
    func findAverageReadingValuePerSensor() {
        sqlite3_exec(getConnection(), "SELECT avg(value) FROM readings GROUP BY sensor_id;", nil, nil, nil)
    }
    
    func getReadings() -> Array<Reading> {
        var readingsList: Array<Reading> = Array()
        let getReadingsQuery = "SELECT * FROM readings;";
        var stmt: OpaquePointer? = nil
        sqlite3_prepare_v2(getConnection(), getReadingsQuery, -1, &stmt, nil)
        while sqlite3_step(stmt) == SQLITE_ROW {
            let id = Int(sqlite3_column_int(stmt, 0))
            let timestamp = Int64(sqlite3_column_int64(stmt, 1))
            let sensorId = Int(sqlite3_column_int(stmt, 2))
            let value = Float(sqlite3_column_double(stmt, 3))
            readingsList.append(Reading(id: id, timestamp: timestamp, sensorId: sensorId, value: value))
        }
        sqlite3_finalize(stmt)
        return readingsList
    }
    
    func randomFloat(min: Float, max: Float) -> Float {
        return Float(Float(arc4random()) / Float(UINT32_MAX)) * (max - min) + min
    }
}
