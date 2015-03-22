//
//  logicAPI.swift
//  FindMyStuff
//
//  Created by Sinka Zoltán on 2015. 02. 25..
//  Copyright (c) 2015. Sinka Zoltán. All rights reserved.
//

import Foundation

class logicAPI {
    
    // Singleton pattern biztosítása
    class var centralInstance: logicAPI {
        struct Singleton {
            static let instance = logicAPI()
        }
        return Singleton.instance
    }
    
    // Változók
    private var beaconManager: BeaconManager
    
    // Inicializálás
    init() {
        beaconManager = BeaconManager()
    }
    
    // Funkciók
    /* func addBeaconWithStringUUID(uuid: String, identifier: String) {
 
        }
    } */
    
    func checkUUIDValidity(uuid: String) -> Bool {
        return beaconManager.isValidUUID(uuid)
    }
    
}