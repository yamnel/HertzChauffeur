//
//  Customer.swift
//  HertzChauffeur
//
//  Created by Stephen Lomangino on 4/2/17.
//  Copyright © 2017 Yamnel. All rights reserved.
//

import Foundation

class Customer {
    var name: String
    var rental: Car? = nil
    
    init (name: String) {
        self.name = name;
    }

    func setCar(car: Car) {
        self.rental = car
    }
    
    func getCar() -> Car {
        return self.rental!
    }
    
    func setName(name: String) {
        self.name = name
    }
    
    func getName() -> String {
        return self.name
    }
}
