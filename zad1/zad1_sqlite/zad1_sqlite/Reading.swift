//
//  Reading.swift
//  zad1_sqlite
//
//  Created by Użytkownik Gość on 08.12.2017.
//  Copyright © 2017 Waclawik. All rights reserved.
//

import Foundation


class Reading {
    var id : Int = 0;
    var timestamp: Int64 = 0;
    var sensorId:Int = 0;
    var value:Float = 0;
    
    init(id: Int, timestamp:Int64, sensorId:Int, value:Float) {
        self.id = id;
        self.timestamp = timestamp
        self.sensorId = sensorId
        self.value = value
    }
}
