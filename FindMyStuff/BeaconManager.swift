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
    
    
    // MARK: Properties
    class var beaconManager: BeaconManager {
        struct Singleton {
            static let instance = BeaconManager()
        }
        return Singleton.instance
    }
    
    let maxBeaconCount = 20
    let locationManager = CLLocationManager()
    let notificationManager = NSNotificationCenter.defaultCenter()
    var location : CLLocationCoordinate2D?
    var beacons = [BeaconItem]()
    var sharedBeacons = [BeaconItem]()
    
    
    // MARK: Inicializálás
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
        for beacon in beacons {
            println(beacon.imageURL)
        }
    }
    
    deinit {
        locationManager.stopUpdatingLocation()
        persistData()
    }
    
    
    
    // MARK: Külső szolgáltatások
    
    func getForeignBeaconSharedNodeDescriptors() -> [String] {
        var nodes = [String]()
        for beacon in sharedBeacons {
            nodes.append(beacon.sharedNodeDescriptor!)
        }
        return nodes
    }
    
    func getBeaconsSharedNodeDescriptors() -> [String] {
        var nodes = [String]()
        for beacon in beacons {
            nodes.append(beacon.sharedNodeDescriptor!)
        }
        return nodes
    }
    
    
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
    
    func addBeacon (beacon: BeaconItem) {
        if !doesBeaconAlreadyExists(beacon) && beacons.count + sharedBeacons.count < maxBeaconCount {
            beacons.append(beacon)
            let notification = NSNotification(name: "BeaconAddNotification", object: beacon)
            notificationManager.postNotification(notification)
            self.persistData()
        } else {
            let notification = NSNotification(name: "CannotAddBeacon", object: beacon)
            notificationManager.postNotification(notification)
        }
    }
    
    func addForeignBeacon (beacon: BeaconItem) {
        if !doesBeaconAlreadyExists(beacon) && beacons.count + sharedBeacons.count < maxBeaconCount {
            sharedBeacons.append(beacon)
            let notification = NSNotification(name: "BeaconAddNotification", object: beacon)
            notificationManager.postNotification(notification)
            self.persistData()
        } else {
            let notification = NSNotification(name: "CannotAddBeacon", object: beacon)
            notificationManager.postNotification(notification)
        }
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
    
    func toggleRangingForForeignBeacon(numberOfBeacon: Int) {
        let beacon = sharedBeacons[numberOfBeacon]
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
    
    
    // MARK: CLLocationManager delegált
    
    func locationManager(manager: CLLocationManager!, didRangeBeacons beacons: [AnyObject]!, inRegion region: CLBeaconRegion!) {
        let itemFound = matchBeaconRegion(region)
        let beaconsInRange = beacons as! [CLBeacon]
        for beacon in beaconsInRange {
            if itemFound?.beaconRegion.proximityUUID == beacon.proximityUUID &&
                itemFound?.beaconRegion.major == beacon.major &&
                itemFound?.beaconRegion.minor == beacon.minor

            {
                if itemFound?.lastKnownProximity != beacon.proximity {
                    itemFound?.lastKnownProximity = beacon.proximity
                    let notification = NSNotification(name: "LocationUpdateNotification", object: beacon)
                    notificationManager.postNotification(notification)
                    println(beacon.proximity)
                    if itemFound?.lastKnownProximity != CLProximity.Unknown {
                        itemFound?.lastKnownLocation = self.location
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
    }
    
    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
        scheduleSimpleNotification("\(region.identifier) is in region!", "inRegion") // UTIL
    }
    
    // MARK: Osztály privát metódusai
    
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
            if (storedBeacon.beaconRegion == beacon.beaconRegion ) || storedBeacon.beaconName == beacon.beaconName {
                exists = true
            }
        }
        
        for storedBeacon in sharedBeacons {
            if (storedBeacon.beaconRegion == beacon.beaconRegion ) || storedBeacon.beaconName == beacon.beaconName {
                                exists = true
            }

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