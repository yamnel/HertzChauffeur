//
//  Car.swift
//  HertzChauffeur
//
//  Created by Stephen Lomangino on 4/2/17.
//  Copyright © 2017 Yamnel. All rights reserved.
//

import Foundation

class Car {
    var name: String
    var engine: Bool = false
    var volume: Double = 0.5
    var fanSpeed: Double = 0.0
    var temp: Int = 72 // b/c I like it cool
    var doorLock: Bool =  true
    
    
    init(name: String) {
        self.name = name
    }
    
    func getName() -> String {
        return self.name
    }
    
    func setName(name: String) {
        self.name = name
    }
    
    func getEngine() -> Bool {
        return self.engine
    }
    
    func setEngine(engine: Bool) {
        self.engine = engine
    }
    
    func getVolume() -> Double {
        return self.volume
    }
    
    func setVolume(volume: Double) {
        self.volume = volume
    }
    
    func getFanSpeed() -> Double {
        return self.fanSpeed
    }
    
    func setFanSpeed(fanSpeed: Double) {
        self.fanSpeed = fanSpeed
    }
    
    func getTemp() -> Int {
        return self.temp
    }
    
    func setTemp(temp: Int) {
        self.temp = temp
    }
    
    func getDoorLock() -> Bool {
        return self.doorLock
    }
    
    func setDoorLock(doorLock: Bool) {
        self.doorLock = doorLock
    }
}
