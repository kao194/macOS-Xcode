//
//  SQLiteHandler.swift
//  zad1_sqlite
//
//  Created by Użytkownik Gość on 08.12.2017.
//  Copyright © 2017 Waclawik. All rights reserved.
//

import Foundation
import CoreData

class CoreDataHandler {

    var appDelegate: AppDelegate? = nil;
    
    var moc: NSManagedObjectContext;
    
    init(moc: NSManagedObjectContext) {
        self.moc = moc
    }
    
    func createSensorsIfNotPresent() {
        print(getSensors().count)
        if(getSensors().count) != 20 {
            createSensors();
        }
    }
    
    func createSensors() {
        let entity = NSEntityDescription.entity(forEntityName: "Sensor", in: moc)
        for counter in 1...20 {
            
            let sensor = NSManagedObject(entity: entity!, insertInto: moc)
            sensor.setValue(counter, forKey:"id");
            let name: NSString
            if counter<10 {
                name="S0\(counter)" as NSString
            }else {
                name="S\(counter)" as NSString
            }
            sensor.setValue(name, forKey:"name");

            let desc:NSString = "Sensor number \(counter)" as NSString;
            sensor.setValue(desc, forKey:"sensorDescription");
            
            try? moc.save()
        }
        print("Created sensors")
    }

    func getSensors() -> Array<NSManagedObject> {
        let fr = NSFetchRequest<NSManagedObject>(entityName: "Sensor")
        
        
        let sensors: [NSManagedObject]? = try? moc.fetch(fr)
        var sernik:Array<NSManagedObject> = Array<NSManagedObject>(sensors!)
        return sernik
    }
    
    func generateReadings(amount: Int) {
        deleteReadings()
        sqlite3_exec(nil, "BEGIN TRANSACTION;", nil, nil, nil)
        
        let insertGeneratedReadingQuery = "INSERT INTO readings (timestamp, sensor_id, value) VALUES (?,?,?)";
        
        var stmt: OpaquePointer? = nil
        sqlite3_prepare_v2(nil, insertGeneratedReadingQuery, -1, &stmt, nil)
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
            //let reading = Reading(id: i, timestamp: timestamp, sensorId: sensorId, value: value);
            //print("Reading id: \(reading.id); timestamp: \(reading.timestamp); sensor: \(reading.sensorId); value: \(reading.value)")
        }
        sqlite3_exec(nil, "COMMIT;", nil, nil, nil)
        print("Created Readings")
    }
    
    func findEarliestReading() {
        sqlite3_exec(nil, "SELECT min(timestamp) FROM readings;", nil, nil, nil)
    }
    
    func findLatestReading() {
        sqlite3_exec(nil, "SELECT max(timestamp) FROM readings;", nil, nil, nil)
    }
    
    func findAverageReadingValue() {
        sqlite3_exec(nil, "SELECT avg(value) FROM readings;", nil, nil, nil)
    }
    
    func findAverageReadingValuePerSensor() {
        sqlite3_exec(nil, "SELECT avg(value) FROM readings GROUP BY sensor_id;", nil, nil, nil)
    }
    
    func deleteReadings() {
        sqlite3_exec(nil, "DELETE FROM readings;", nil, nil, nil)
    }
    
    func getReadings() -> Array<Reading> {
        var readingsList: Array<Reading> = Array()
        let getReadingsQuery = "SELECT * FROM readings;";
        var stmt: OpaquePointer? = nil
        sqlite3_prepare_v2(nil, getReadingsQuery, -1, &stmt, nil)
        while sqlite3_step(stmt) == SQLITE_ROW {
            let id = Int(sqlite3_column_int(stmt, 0))
            let timestamp = Int64(sqlite3_column_int64(stmt, 1))
            let sensorId = Int(sqlite3_column_int(stmt, 2))
            let value = Float(sqlite3_column_double(stmt, 3))
            //readingsList.append(Reading(id: id, timestamp: timestamp, sensorId: sensorId, value: value))
        }
        sqlite3_finalize(stmt)
        return readingsList
    }
    
    func randomFloat(min: Float, max: Float) -> Float {
        return Float(Float(arc4random()) / Float(UINT32_MAX)) * (max - min) + min
    }
}
