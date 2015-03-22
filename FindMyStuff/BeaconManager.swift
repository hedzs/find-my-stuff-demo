//
//  BeaconManager.swift
//  FindMyStuff
//
//  Created by Sinka Zoltán on 2015. 02. 23..
//  Copyright (c) 2015. Sinka Zoltán. All rights reserved.
//

import Foundation
import CoreLocation


class BeaconManager: NSObject, CLLocationManagerDelegate {
    
    
    // Properties
    class var beaconManager: BeaconManager {
        struct Singleton {
            static let instance = BeaconManager()
        }
        return Singleton.instance
    }

    let locationManager = CLLocationManager()
    let notificationManager = NSNotificationCenter.defaultCenter()
    var beacons = [BeaconItem]()
    var sharedBeacons = [BeaconItem]()
    
    // Inicializálás
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if let data = defaults.objectForKey("beacons") as? NSData {
            beacons = NSKeyedUnarchiver.unarchiveObjectWithData(data) as [BeaconItem]
        }
        
        
    
        
        // tesztsor
//        var uuid = NSUUID(UUIDString:"EBEFD083-70A2-47C8-9837-E7B5634DF524")
//        var tesztBeacon = BeaconItem(uuid:uuid!, major: 1, minor: 1, identifier: "Teszt Beacon")
//        beacons.append(tesztBeacon!)
//        var uuid2 = NSUUID(UUIDString:"EBEFD083-71A2-47C8-9837-E7B5634DF524")
//        println(uuid2)
//        var tesztBeacon2 = BeaconItem(uuid:uuid2!, major: 1, minor: 1, identifier: "Teszt Beacon Második")
//        beacons.append(tesztBeacon2!)
    }
    
    // Külső szolgáltatások
    
    func isValidUUID(uuid: String) -> Bool {
        let NSuuid: NSString = uuid.uppercaseString
        let uuidPattern = NSRegularExpression(pattern: "[A-F0-9]{8}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{12}", options: .CaseInsensitive , error: nil)
        var result = uuidPattern?.firstMatchInString(NSuuid, options: nil, range: NSMakeRange(0, NSuuid.length))
        if result != nil {
            return true
        }
        return false
    }
    
    func getProximityOfBeacon (numberOfBeacon: Int) -> CLProximity? {
        if numberOfBeacon >= 0 && numberOfBeacon < beacons.count {
            return beacons[numberOfBeacon].lastKnownProximity
        }
        return nil
    }
    
    
    func addBeacon (nsuuid: String, major: Int?, minor: Int?, identifier: String) -> Bool {
        let uuid = NSUUID(UUIDString:nsuuid)
        if let majorNo = major {
            if let minorNo = minor {
                if let beacon = BeaconItem(uuid: uuid!, major: UInt16(majorNo), minor: UInt16(minorNo), identifier: identifier) {
                    self.addBeacon(beacon)
                    println(beacon)
                    return true
                }
            }
            if let beacon = BeaconItem(uuid: uuid!, major: UInt16(majorNo), identifier: identifier) {
                self.addBeacon(beacon)
                return true
            }
        }
        if let beacon = BeaconItem(uuid: uuid!, identifier: identifier) {
            self.addBeacon(beacon)
            return true
        }
    return false
    }
    
    func persistData() {
        let defaults = NSUserDefaults.standardUserDefaults()
        let data = NSKeyedArchiver.archivedDataWithRootObject(beacons)
        defaults.removeObjectForKey("beacons")
        defaults.setValue(data, forKey: "beacons")
        println("data persisted")
    }

    
    func addBeacon (beacon: BeaconItem) {
        beacons.append(beacon)
        println("A BEACON HAS BEEN ADDED")
        println(beacons.count)
        let notification = NSNotification(name: "BeaconAddNotification", object: beacon)
        notificationManager.postNotification(notification)

    }
    
    func toggleRanging(numberOfBeacon: Int) {
        let beacon = beacons[numberOfBeacon]
        if beacon.isTracked {
            locationManager.stopRangingBeaconsInRegion(beacon.beaconRegion)
            beacon.isTracked = !beacon.isTracked
        } else {
            locationManager.startRangingBeaconsInRegion(beacon.beaconRegion)
            beacon.isTracked = !beacon.isTracked
        }
        
    }
    
    
    // CLLocationManager
    
    func locationManager(manager: CLLocationManager!, didRangeBeacons beacons: [AnyObject]!, inRegion region: CLBeaconRegion!) {
        let itemFound = matchBeaconRegion(region)
        let beaconsInRange = beacons as [CLBeacon]
        for beacon in beaconsInRange {
            if itemFound?.beaconRegion.proximityUUID == beacon.proximityUUID {
                if itemFound?.lastKnownProximity != beacon.proximity { // itt lehet nem kell dupla ellenőrzés mert egy beacon lesz a beaconsben, ha megvan adva a region uuid major minor is
                    itemFound?.lastKnownProximity = beacon.proximity
                    let notification = NSNotification(name: "LocationUpdateNotification", object: beacon)
                    notificationManager.postNotification(notification)
                    println("valtozott a proximity")
                    println(beacon.proximity)
                }
            }
        }
    }
    
    // privát metódusok
    
    private func matchBeaconRegion(region: CLBeaconRegion) -> BeaconItem? {
        for beacon in beacons {
            if beacon.beaconRegion == region {
                return beacon
            }
        }
        for beacon in sharedBeacons {
            if beacon.beaconRegion == region {
                return beacon
            }
        }
        return nil
    }
    
}

extension CLProximity: Printable {
    public var description: String {
        switch self {
        case .Far: return " ⚑ Far  "
        case .Immediate: return " ⚑ Immediate  "
        case .Near: return " ⚑ Near  "
        case .Unknown: return " ⚐ Unknown  "
        }
    }
}
