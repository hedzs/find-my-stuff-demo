//
//  Packager.swift
//  FindMyStuff
//
//  Created by Sinka Zoltán on 2015. 04. 16..
//  Copyright (c) 2015. Sinka Zoltán. All rights reserved.
//

import Foundation
import CoreLocation

class Packager {
    
    class func wrapBeaconItemIntoJSON (beacon: BeaconItem) -> [String:String] {
        var wrappedBeacon = [String:String]()
        wrappedBeacon["beaconName"] = beacon.beaconRegion.identifier
        wrappedBeacon["UUID"] = beacon.beaconRegion.proximityUUID.UUIDString
        if let major = beacon.beaconRegion.major?.description {
            wrappedBeacon["Major"] = major
        }
        if let minor = beacon.beaconRegion.minor?.description {
            wrappedBeacon["Minor"] = minor
        }
        return wrappedBeacon
    }
    
    class func extractJSONIntoBeaconItem(data: [String:String]) -> BeaconItem? {
        let beaconName = data["beaconName"]!
        let uuid = data["UUID"]!
        let major = data["Major"]!.toInt() ?? nil
        let minor = data["Minor"]!.toInt() ?? nil
        let beaconManager = BeaconManager()
        return beaconManager.createBeacon(uuid, major: major, minor: minor, identifier: beaconName)
    }
    
}