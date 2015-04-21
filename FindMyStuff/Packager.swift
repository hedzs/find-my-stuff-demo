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
    
    class func wrapBeaconItemIntoJSON (beacon: BeaconItem) -> NSMutableDictionary {
        var data: NSMutableDictionary = ["beaconName": beacon.beaconRegion.identifier,
                    "UUID":beacon.beaconRegion.proximityUUID.UUIDString
        ]
        if let major = beacon.beaconRegion.major {
            data["Major"] = major
        }
        
        if let minor = beacon.beaconRegion.minor {
            data["Minor"] = minor
        }
        if let location = beacon.lastKnownLocation {
            data["Latitude"] = location.latitude
            data["Longitude"] = location.longitude
        }
        return data
    }
    
    class func wrapBeaconItemIntoJSON2 (beacon: BeaconItem) -> [String:String] {
        var wrappedBeacon = [String:String]()
        wrappedBeacon["beaconName"] = beacon.beaconRegion.identifier
        wrappedBeacon["UUID"] = beacon.beaconRegion.proximityUUID.UUIDString
        if let major = beacon.beaconRegion.major?.description {
            wrappedBeacon["Major"] = major
        }
        
        if let minor = beacon.beaconRegion.minor?.description {
            wrappedBeacon["Minor"] = minor
        }
        
        if let location = beacon.lastKnownLocation {
            wrappedBeacon["Latitude"] = location.latitude.description
            wrappedBeacon["Longitude"] = location.longitude.description
        }
        return wrappedBeacon
    }
    
    class func extractJSONIntoBeaconItem(data: NSMutableDictionary) -> BeaconItem? {
        println(data)
        let beaconName = data["beaconName"] as! String
        let uuid = data["UUID"] as! String
        let major = data["Major"] as? NSNumber
        let minor = data["Minor"] as? NSNumber
        let latitude = data["Latitude"] as? NSNumber
        let longitude = data["Longitude"] as? NSNumber
        if latitude != nil && longitude != nil {
            let location = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude!), longitude: CLLocationDegrees(longitude!))
        }
        let beaconManager = BeaconManager()
        return beaconManager.createBeacon(uuid, major: major?.integerValue, minor: minor?.integerValue, identifier: beaconName)
        
    }
    
    class func anonymizeLocationalData(inout data:NSMutableDictionary) {
        data.removeObjectForKey("Latitude")
        data.removeObjectForKey("Longitude")
    }
    
    class func extractJSONIntoBeaconItem2(data: [String:String]) -> BeaconItem? {
        let beaconName = data["beaconName"]!
        let uuid = data["UUID"]!
        let major = data["Major"]!.toInt() ?? nil
        let minor = data["Minor"]!.toInt() ?? nil
//        let latitude = data["Latitude"]!. ?? nil
//        let longitude = data["Longitude"]!.toDouble() ?? nil
//        var location : CLLocationCoordinate2D?
//        if latitude != nil && longitude != nil {
//            location = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLlocationlongitude)
//        }
        let beaconManager = BeaconManager()
        return beaconManager.createBeacon(uuid, major: major, minor: minor, identifier: beaconName)
    }
    
}