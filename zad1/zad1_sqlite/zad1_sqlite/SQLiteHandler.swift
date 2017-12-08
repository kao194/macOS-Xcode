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
    
        print(dbFilePath);
        
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

    
}
