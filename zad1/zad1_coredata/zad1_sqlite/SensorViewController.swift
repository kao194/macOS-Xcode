//
//  SensorViewController.swift
//  zad1_sqlite
//
//  Created by Użytkownik Gość on 12.01.2018.
//  Copyright © 2018 Waclawik. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class SensorViewController: UITableViewController {
    
    var sensorsList:Array<Sensor> = Array<Sensor>();
    
    func getMOC()-> NSManagedObjectContext? {
        guard let ad=UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        let moc = ad.persistentContainer.viewContext
        return moc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let handler: CoreDataHandler = CoreDataHandler(moc: getMOC()!);
        handler.createSensorsIfNotPresent()
        sensorsList.append(contentsOf: handler.getSensors());

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sensorsList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SensorCell", for: indexPath)
        
        cell.textLabel?.text = sensorsList[indexPath.row].name
        cell.detailTextLabel?.text = sensorsList[indexPath.row].description
        
        
        return cell
    }
    
}

