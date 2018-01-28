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

    func getSensors() -> Array<Sensor> {
        let fr = NSFetchRequest<NSManagedObject>(entityName: "Sensor")
        
        
        let sensors: [NSManagedObject]? = try? moc.fetch(fr)
        let sernik:Array<Sensor> = sensors! as! Array<Sensor>
        return sernik
    }
    
    func generateReadings(amount: Int) {
        deleteReadings()
        
        let sensors = getSensors()
        
        let entity = NSEntityDescription.entity(forEntityName: "Reading", in: moc)
        print("About to generate \(amount) readings")
        for i in 1...amount {
            print("iteration: \(i)")
            let sensor = arc4random_uniform(20) + 1
            let sensorId:Int = Int(sensor);
            let value:Float = randomFloat(min: 0, max: 100)
            
            let date: Date = Date();
            // random value of time in the year
            let randomSecondInTheLastYear = arc4random_uniform(31556926) + 1;
            
            var secondsSinceTheBeginning = date.timeIntervalSince1970
            secondsSinceTheBeginning.subtract(Double(randomSecondInTheLastYear));
            
            let timestamp = Int64(secondsSinceTheBeginning*1000)
            
            let reading = NSManagedObject(entity: entity!, insertInto: moc) as! Reading
            reading.setValue(i, forKey:"id");
            reading.setValue(timestamp, forKey:"timestamp");
            reading.setValue(value, forKey:"value");
            var sensorToConnect: Sensor? = nil;
            
            for j in 0...19 {
                if sensors[j].id == Int32(sensorId) {
                    sensorToConnect = sensors[j]
                }
            }
            reading.setValue(sensorToConnect, forKey: "sensor")
            
        }
        try? moc.save()
        print("Created Readings")
    }
    
    func findEarliestReading() {
        
        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: true)
        let fr = NSFetchRequest<Reading>(entityName: "Reading")
        fr.sortDescriptors=[sortDescriptor]
        fr.fetchLimit = 1
        
        let reading: [Reading]? = try? moc.fetch(fr)
        let sernik:Array<Reading> = reading! 
        print(sernik.count)
    }
    
    func findLatestReading() {
        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
        let fr = NSFetchRequest<Reading>(entityName: "Reading")
        fr.sortDescriptors=[sortDescriptor]
        fr.fetchLimit = 1
        
        let reading: [Reading]? = try? moc.fetch(fr)
        let sernik:Array<Reading> = reading!
        print(sernik.count)
    }
    
    func findAverageReadingValue() {
        let fr = NSFetchRequest<NSDictionary>(entityName: "Reading")
        
        fr.resultType = .dictionaryResultType
        let ed = NSExpressionDescription()
        ed.name = "Average"
        ed.expression = NSExpression(format: "@avg.value")
        ed.expressionResultType = .floatAttributeType
        fr.propertiesToFetch = [ed]
        try? moc.fetch(fr)[0]
        
    }
    
    func findAverageReadingValuePerSensor() {
        let fr = NSFetchRequest<NSDictionary>(entityName: "Reading")
        
        fr.resultType = .dictionaryResultType
        let ed = NSExpressionDescription()
        ed.name = "Average"
        ed.expression = NSExpression(format: "@avg.value")
        ed.expressionResultType = .floatAttributeType
        fr.propertiesToFetch = [ed]
        fr.propertiesToGroupBy=["sensor"]
        try? moc.fetch(fr)[0]
    }
    
    func deleteReadings() {
        //
    }
    
    func getReadings() -> Array<Reading> {
        let fr = NSFetchRequest<Reading>(entityName: "Reading")
        
        let readings: [Reading]? = try? moc.fetch(fr)
        let sernik:Array<Reading> = readings!
        return sernik
    }
    
    func randomFloat(min: Float, max: Float) -> Float {
        return Float(Float(arc4random()) / Float(UINT32_MAX)) * (max - min) + min
    }
}
