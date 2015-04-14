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
    
    var beaconRegion:CLBeaconRegion! {
        didSet {
            beaconRegion.notifyEntryStateOnDisplay = true
        }
    }
    
    var beaconName:String {
        get {
            return beaconRegion.identifier
        }
    }
    
    var isTracked = false
    
    var isNotificationOnWhenGetsInRange = false {
        didSet {
            if isNotificationOnWhenGetsInRange == true {
                beaconRegion.notifyOnEntry = true
                beaconRegion.notifyEntryStateOnDisplay = true // TBD
            } else {
                beaconRegion.notifyOnEntry = false
                beaconRegion.notifyEntryStateOnDisplay = true // TBD
            }
        }
    }
    var isNotificationOnWhenProximityUnknown = false {
        didSet {
            if isNotificationOnWhenProximityUnknown == true {
                beaconRegion.notifyOnExit = true
            } else {
                beaconRegion.notifyOnExit = false
            }
        }
    }
    
    var imageURL: String?
    var lastKnownProximity = CLProximity.Unknown
    var lastKnownLocation : CLLocationCoordinate2D?

    
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
        aCoder.encodeBool(isNotificationOnWhenGetsInRange, forKey: "isNotificationOnWhenGetsInRange")
        aCoder.encodeBool(isNotificationOnWhenProximityUnknown, forKey: "isNotificationOnWhenProximityUnknown")
        aCoder.encodeObject(imageURL, forKey: "imageURL")
        aCoder.encodeObject(lastKnownLocation?.latitude, forKey: "lastKnownLocationLatitude")
        aCoder.encodeObject(lastKnownLocation?.longitude, forKey: "lastKnownLocationLongitude")
    }
    
    required init(coder aDecoder: NSCoder) {
        beaconRegion = aDecoder.decodeObjectForKey("beaconRegion") as! CLBeaconRegion
        isTracked = aDecoder.decodeBoolForKey("isTracked")
        lastKnownProximity = CLProximity(rawValue: Int(aDecoder.decodeInt32ForKey("lastKnownProximity")))!
        imageURL = aDecoder.decodeObjectForKey("imageURL") as! String?
        isNotificationOnWhenProximityUnknown = aDecoder.decodeBoolForKey("isNotificationOnWhenProximityUnknown")
        isNotificationOnWhenGetsInRange = aDecoder.decodeBoolForKey("isNotificationOnWhenGetsInRange")
        if  let latitude = aDecoder.decodeObjectForKey("lastKnownLocationLatitude") as? CLLocationDegrees,
            let longitude = aDecoder.decodeObjectForKey("lastKnownLocationLongitude") as? CLLocationDegrees {
                lastKnownLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }
    
    
}