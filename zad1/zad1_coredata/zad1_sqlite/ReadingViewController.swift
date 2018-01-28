//
//  ReadingViewController.swift
//  zad1_sqlite
//
//  Created by Użytkownik Gość on 19.01.2018.
//  Copyright © 2018 Waclawik. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class ReadingViewController: UITableViewController {
    
    var readingList:Array<Reading> = Array<Reading>();
    
    @IBOutlet var TableViewDisplayingOutlet: UITableView!
    
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
        readingList.append(contentsOf: handler.getReadings());
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let handler: CoreDataHandler = CoreDataHandler(moc: getMOC()!);
        readingList.removeAll()
        readingList.append(contentsOf: handler.getReadings());
        TableViewDisplayingOutlet.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return readingList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReadingValueCell", for: indexPath)
        
        cell.textLabel?.text = readingList[indexPath.row].value.description
        cell.detailTextLabel?.text = "\(String(describing: readingList[indexPath.row].sensor!.name!)) - \(readingList[indexPath.row].timestamp)"
        
        
        return cell
    }
    
}
