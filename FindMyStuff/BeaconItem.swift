//
//  BeaconItem.swift
//  FindMyStuff
//
//  Created by Sinka Zoltán on 2015. 02. 20..
//  Copyright (c) 2015. Sinka Zoltán. All rights reserved.
//

import Foundation
import CoreLocation

class BeaconItem: NSObject, NSCoding {
    
    var beaconRegion:CLBeaconRegion!
    var beaconName:String {
        get {
            return beaconRegion.identifier
        }
    }
    var isTracked = false
    var lastKnownProximity = CLProximity.Unknown
    
    
    init?(uuid: NSUUID, major: CLBeaconMajorValue! = nil, minor: CLBeaconMinorValue! = nil, identifier: String){
        
        //TODO: minor van, major nincs check and fail
        if minor == nil && major == nil {
                beaconRegion = CLBeaconRegion(proximityUUID: uuid, identifier: identifier)
                return
        } else if minor == nil {
            beaconRegion = CLBeaconRegion(proximityUUID: uuid, major: major, identifier: identifier)
            return
        } else {
            beaconRegion = CLBeaconRegion(proximityUUID: uuid, major: major, minor: minor, identifier: identifier)
        }
        
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(beaconRegion, forKey: "beaconRegion")
        aCoder.encodeBool(isTracked, forKey: "isTracked")
        aCoder.encodeInt(Int32(lastKnownProximity.rawValue), forKey: "lastKnownProximity")
    }
    
    required init(coder aDecoder: NSCoder) {
        beaconRegion = aDecoder.decodeObjectForKey("beaconRegion") as CLBeaconRegion
        isTracked = aDecoder.decodeBoolForKey("isTracked")
        lastKnownProximity = CLProximity(rawValue: Int(aDecoder.decodeInt32ForKey("lastKnownProximity")))!
    }
    
    
}