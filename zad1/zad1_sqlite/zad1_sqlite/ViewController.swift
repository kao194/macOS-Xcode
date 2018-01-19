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

    @IBAction func ClearBtnOnClick(_ sender: UIButton) {
        let handler: SqLiteHandler = SqLiteHandler();
        handler.deleteSensors();
    }
    
    @IBAction func ExecuteExp1OnClick(_ sender: Any) {
        let handler: SqLiteHandler = SqLiteHandler();
        handler.generateReadings(amount: 20)
    }
}

