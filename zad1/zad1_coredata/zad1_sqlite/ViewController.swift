//
//  ViewController.swift
//  zad1_sqlite
//
//  Created by Użytkownik Gość on 01.12.2017.
//  Copyright © 2017 Waclawik. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var butn: UIButton!
    @IBOutlet weak var exp2butn: UIButton!
    @IBOutlet weak var entriesTextField: UITextField!
    @IBOutlet weak var generateButton: UIButton!
    @IBOutlet weak var clearReadingsButton: UIButton!
    
    @IBOutlet weak var exp1butn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func BtnOnClick(_ sender: UIButton) {
        let handler: SqLiteHandler = SqLiteHandler();
        handler.createTables();
        handler.createSensorsIfNotPresent();
    }
    
    @IBAction func ClearReadingsOnClick(_ sender: Any) {
        let handler: SqLiteHandler = SqLiteHandler();
        handler.deleteReadings();
    }

    @IBAction func ClearBtnOnClick(_ sender: UIButton) {
        let handler: SqLiteHandler = SqLiteHandler();
        handler.deleteSensors();
    }
    
    @IBAction func GenerateCustomAmountOfEntries(_ sender: Any) {
        let amount = Int(entriesTextField.text!)
        if amount! <= 0 { return };
        let handler: SqLiteHandler = SqLiteHandler();
        
        handler.generateReadings(amount: amount!)
        print("Generated \(amount) entries.")
    }
    
    @IBAction func ExecuteExp1OnClick(_ sender: Any) {
        let handler: SqLiteHandler = SqLiteHandler();
        // first experiment: 1000 readings
        
        let startTime = NSDate()
        
        handler.generateReadings(amount: 1000)
        
        let finishTime = NSDate()
        let measuredTime = finishTime.timeIntervalSince(startTime as Date)
        print(measuredTime)
        
        let startEarliestTime = Date()
        handler.findEarliestReading()
        let startLatestDate = Date()
        handler.findLatestReading()
        let startAverageReadingDate = Date()
        handler.findAverageReadingValue()
        let startAverageReadingGroupedDate = Date()
        handler.findAverageReadingValuePerSensor()
        let stopAverageReadingGroupedDate = Date()
        
        print("Finding earliest measurement time: "+startLatestDate.timeIntervalSince(startEarliestTime).description)
        print("Finding latest measurement time: "+startAverageReadingDate.timeIntervalSince(startLatestDate).description)
        print("Finding average overall time: "+startAverageReadingGroupedDate.timeIntervalSince(startAverageReadingDate).description)
        print("Finding average per group time: "+stopAverageReadingGroupedDate.timeIntervalSince(startAverageReadingGroupedDate).description)
        print("Done - 1 000 entries experiment")
    }
    @IBAction func ExecuteExp2OnClick(_ sender: Any) {
        let handler: SqLiteHandler = SqLiteHandler();
        // first experiment: 1000000 readings
        
        let startTime = Date()
        
        handler.generateReadings(amount: 1000000)
        
        let finishTime = Date()
        let measuredTime = finishTime.timeIntervalSince(startTime)
        print(measuredTime)
        
        let startEarliestTime = Date()
        handler.findEarliestReading()
        let startLatestDate = Date()
        handler.findLatestReading()
        let startAverageReadingDate = Date()
        handler.findAverageReadingValue()
        let startAverageReadingGroupedDate = Date()
        handler.findAverageReadingValuePerSensor()
        let stopAverageReadingGroupedDate = Date()
        
        print("Finding earliest measurement time: "+startLatestDate.timeIntervalSince(startEarliestTime).description)
        print("Finding latest measurement time: "+startAverageReadingDate.timeIntervalSince(startLatestDate).description)
        print("Finding average overall time: "+startAverageReadingGroupedDate.timeIntervalSince(startAverageReadingDate).description)
        print("Finding average per group time: "+stopAverageReadingGroupedDate.timeIntervalSince(startAverageReadingGroupedDate).description)
        print("Done - 1 000 000 entries experiment")
    }
}

