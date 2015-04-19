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
    var location : CLLocationCoordinate2D?
    var beacons = [BeaconItem]()
    var sharedBeacons = [BeaconItem]()
    
    
    // Inicializálás
    override init() {
        super.init()
        setupNotification() // UTIL
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if let data = defaults.objectForKey("beacons") as? NSData {
            beacons = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [BeaconItem]
        }
        if let foreignData = defaults.objectForKey("sharedBeacons") as? NSData {
            sharedBeacons = NSKeyedUnarchiver.unarchiveObjectWithData(foreignData) as! [BeaconItem]
        }
        
    
        // TESZT
        
        for beacon in beacons {
            beacon.beaconRegion.notifyEntryStateOnDisplay = true
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
    
    deinit {
    
        
    }
    
    // Külső szolgáltatások
    
    func isValidUUID(uuid: String) -> Bool {
        let NSuuid: NSString = uuid.uppercaseString
        let uuidPattern = NSRegularExpression(pattern: "[A-F0-9]{8}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{12}", options: .CaseInsensitive , error: nil)
        var result = uuidPattern?.firstMatchInString(NSuuid as String, options: nil, range: NSMakeRange(0, NSuuid.length))
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
        if let beacon = createBeacon(nsuuid, major: major, minor: minor, identifier: identifier) {
            self.addBeacon(beacon)
            return true
        }
        return false
    }
    
    func createBeacon (nsuuid: String, major: Int?, minor: Int?, identifier: String) -> BeaconItem? {
        let uuid = NSUUID(UUIDString:nsuuid)
        if let majorNo = major {
            if let minorNo = minor {
                if let beacon = BeaconItem(uuid: uuid!, major: UInt16(majorNo), minor: UInt16(minorNo), identifier: identifier) {
                    return beacon
                }
            }
            if let beacon = BeaconItem(uuid: uuid!, major: UInt16(majorNo), identifier: identifier) {
                return beacon
            }
        }
        if let beacon = BeaconItem(uuid: uuid!, identifier: identifier) {
            return beacon
        }
        return nil
    }
    
    func persistData() {
        let defaults = NSUserDefaults.standardUserDefaults()
        let data = NSKeyedArchiver.archivedDataWithRootObject(beacons)
        let foreignData = NSKeyedArchiver.archivedDataWithRootObject(sharedBeacons)
        defaults.removeObjectForKey("beacons")
        defaults.removeObjectForKey("sharedBeacons")
        defaults.setValue(data, forKey: "beacons")
        defaults.setValue(foreignData, forKey: "sharedBeacons")
    }
    
    func addForeignBeacon (beacon: BeaconItem) {
        if !doesBeaconAlreadyExists(beacon) {
            sharedBeacons.append(beacon)
            let notification = NSNotification(name: "BeaconAddNotification", object: beacon)
            notificationManager.postNotification(notification)
            self.persistData()
        }
    }

    
    func addBeacon (beacon: BeaconItem) {
        if !doesBeaconAlreadyExists(beacon) {
            beacons.append(beacon)
            let notification = NSNotification(name: "BeaconAddNotification", object: beacon)
            notificationManager.postNotification(notification)
            self.persistData()
        }
    }
    
    func removeBeacon(numberOfBeacon: Int ) {
        if numberOfBeacon >= 0 && numberOfBeacon < beacons.count {
            beacons.removeAtIndex(numberOfBeacon)
        }
        self.persistData()
    }
    
    func removeForeignBeaconWithDescriptor(descriptor: String) {
        var counter = 0
        for beacon in sharedBeacons {
            if beacon.sharedNodeDescriptor! == descriptor {
                sharedBeacons.removeAtIndex(counter)
                let notification = NSNotification(name: "BeaconAddNotification", object: nil)
                notificationManager.postNotification(notification)
            }
            counter++
        }
        self.persistData()
    }
    
    func toggleRanging(numberOfBeacon: Int) {
        let beacon = beacons[numberOfBeacon]
        if beacon.isTracked {
            locationManager.stopRangingBeaconsInRegion(beacon.beaconRegion)
            beacon.isTracked = !beacon.isTracked
            beacon.lastKnownProximity = CLProximity.Unknown
        } else {
            locationManager.startRangingBeaconsInRegion(beacon.beaconRegion)
            beacon.isTracked = !beacon.isTracked
        }
        
    }
    
    func shutDownActiveTrackingForAllBeaconRegions() {
        for beacon in beacons {
            locationManager.stopRangingBeaconsInRegion(beacon.beaconRegion)
        }
        for beacon in sharedBeacons {
            locationManager.stopRangingBeaconsInRegion(beacon.beaconRegion)
        }
    }
    
    func toggleNotifyOnEntry(beacon: BeaconItem, toState: Bool) {
        beacon.isNotificationOnWhenGetsInRange = toState
        if !beacon.isNotificationOnWhenProximityUnknown && !beacon.isNotificationOnWhenGetsInRange {
            locationManager.stopMonitoringForRegion(beacon.beaconRegion)
        } else {
            self.restartRangingService(beacon.beaconRegion)
        }
    }
    
    func toggleNotifyOnExit(beacon: BeaconItem, toState: Bool) {
        beacon.isNotificationOnWhenProximityUnknown = toState
        if !beacon.isNotificationOnWhenProximityUnknown && !beacon.isNotificationOnWhenGetsInRange {
            locationManager.stopMonitoringForRegion(beacon.beaconRegion)
        } else {
            self.restartRangingService(beacon.beaconRegion)
        }
    }

    func restartRangingService(region: CLBeaconRegion) {
          locationManager.stopMonitoringForRegion(region)
          locationManager.startMonitoringForRegion(region)
    }
    
    
    // CLLocationManager
    
    func locationManager(manager: CLLocationManager!, didRangeBeacons beacons: [AnyObject]!, inRegion region: CLBeaconRegion!) {
        let itemFound = matchBeaconRegion(region)
        let beaconsInRange = beacons as! [CLBeacon]
        for beacon in beaconsInRange {
            if itemFound?.beaconRegion.proximityUUID == beacon.proximityUUID &&
                itemFound?.beaconRegion.major == beacon.major &&
                itemFound?.beaconRegion.minor == beacon.minor

            {
                //println(beacon)
                if itemFound?.lastKnownProximity != beacon.proximity { // itt lehet nem kell dupla ellenőrzés mert egy beacon lesz a beaconsben, ha megvan adva a region uuid major minor is
                    itemFound?.lastKnownProximity = beacon.proximity
                    let notification = NSNotification(name: "LocationUpdateNotification", object: beacon)
                    notificationManager.postNotification(notification)
                    //println("valtozott a proximity")
                    println(beacon.proximity)
                    if itemFound?.lastKnownProximity != CLProximity.Unknown {
                        itemFound?.lastKnownLocation = self.location
                        // update location of IBEACON
                    }
                }
            }
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if let newLocation = locations.last as? CLLocation {
            self.location = newLocation.coordinate
        }
    }
    
    
    func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
        scheduleSimpleNotification("\(region.identifier) is out of region!", "outOfRange") // UTIL
       println("erkezett a didExitRegion")
    }
    
    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
        scheduleSimpleNotification("\(region.identifier) is in region!", "inRegion") // UTIL
        println("erkezett a didENterRegion")
    }
    
    // Osztály privát metódusai
    
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
    
    private func doesBeaconAlreadyExists(beacon: BeaconItem) -> Bool {
        var exists = false
        for storedBeacon in beacons {
            if storedBeacon.beaconRegion == beacon.beaconRegion || storedBeacon.beaconName == beacon.beaconName {
                exists = true
                let notification = NSNotification(name: "BeaconAlreadyExists", object: beacon)
                notificationManager.postNotification(notification)

            }
        }
        
        for storedBeacon in sharedBeacons {
            if storedBeacon.beaconRegion == beacon.beaconRegion || storedBeacon.beaconName == beacon.beaconName {
                exists = true
            }
        }
        if exists {
            let notification = NSNotification(name: "BeaconAlreadyExists", object: beacon)
            notificationManager.postNotification(notification)
        }
        return exists
    }
    
}

// MARK: Kiegészítő szolgáltatások

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
