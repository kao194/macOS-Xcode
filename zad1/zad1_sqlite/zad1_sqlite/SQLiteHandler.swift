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
        
        if(amountOfSensorsInDB == 0) {
            createSensors();
        }
    }
    
    func createSensors() {
        let getAmountOfSensorsCreated = "INSERT INTO sensors (name, description) VALUES (?,?)";
        var stmt: OpaquePointer? = nil
        sqlite3_prepare_v2(getConnection(), getAmountOfSensorsCreated, -1, &stmt, nil)
        sqlite3_bind_text(stmt, 1, "Name", -1, nil)
        sqlite3_bind_text(stmt, 2, "DescriptionOpisETC", -1, nil)
        if (sqlite3_step(stmt) != SQLITE_DONE) {
            print("\nCould not step (execute) stmt.\n");
        }
        sqlite3_reset(stmt);

    }
    
}
