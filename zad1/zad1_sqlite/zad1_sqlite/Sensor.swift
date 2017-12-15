//
//  Sensor.swift
//  zad1_sqlite
//
//  Created by Użytkownik Gość on 08.12.2017.
//  Copyright © 2017 Waclawik. All rights reserved.
//

import Foundation

class Sensor {
    var id: Int;
    var name: String;
    var description: String;
    
    init(id: Int, name:String, description:String) {
        self.id = id;
        self.name = name;
        self.description = description;
    }
}
