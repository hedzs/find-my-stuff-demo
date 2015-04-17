//
//  OnlinePersistanceManager.swift
//  FindMyStuff
//
//  Created by Sinka Zoltán on 2015. 03. 17..
//  Copyright (c) 2015. Sinka Zoltán. All rights reserved.
//

import Foundation

class OnlinePersistanceManager {
    
    enum Constants {
        static let rootRef = Firebase(url: "https://find-my-stuff.firebaseio.com")
    }
    
    func checkNodeAvailability(nodeName: String) {
        var childRef = Constants.rootRef.childByAppendingPath(nodeName)
        var availability = false
        childRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                println(snapshot.value as! NSObject)
                println(NSNull())
                if snapshot.value as! NSObject == NSNull() {
                    availability = true
                }
            dispatch_async(dispatch_get_main_queue()) {
                let notificationManager = NSNotificationCenter.defaultCenter()
                if availability {
                    notificationManager.postNotificationName("SharedNameIsAvailable", object: nil, userInfo: ["destination":nodeName])  
                } else {
                    let notification = NSNotification(name: "SharedNameIsNOTAvailable", object: nil)
                    notificationManager.postNotification(notification)
                }
            }
        })
    }
    
    func removeNode(nodeName: String) {
        let childRef = Constants.rootRef.childByAppendingPath(nodeName)
        childRef.removeValue()
    }
    
    func uploadBeacon(beacon: BeaconItem, destination: String) {
        let childRef = Constants.rootRef.childByAppendingPath(destination)
        beacon.sharedNodeDescriptor = destination
        childRef.setValue(Packager.wrapBeaconItemIntoJSON(beacon))
    }
    
    func downloadBeacon(source: String) {
        let childRef = Constants.rootRef.childByAppendingPath(source)
        childRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if snapshot.value as! NSObject != NSNull() {
                
            let name = snapshot.value.objectForKey("beaconName") as! String
            let uuid = snapshot.value.objectForKey("UUID") as! String
            let major = snapshot.value.objectForKey("Major") as? Int
            let minor = snapshot.value.objectForKey("Minor") as? Int
            let bmr = BeaconManager.beaconManager
            if let beacon = bmr.createBeacon(uuid, major: major, minor: minor, identifier: name) {
                dispatch_async(dispatch_get_main_queue()) {
                    bmr.addBeacon(beacon)
                }
            }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    let notificationManager = NSNotificationCenter.defaultCenter()
                    let notification = NSNotification(name: "SharedBeaconCannotBeFound", object: nil)
                    notificationManager.postNotification(notification)
                }

            }
        })
        
    }
    
    func startObservingForBeaconInfoUpdates(source: String) {
        
    }
    
    
    // TESZTEK
    func testBeaconUpload(beacon: BeaconItem) {
        var childRef = Constants.rootRef.childByAppendingPath("teszt")
        childRef.setValue(Packager.wrapBeaconItemIntoJSON(beacon))
    }
    
    func testBeaconDownload() {
        var childRef = Constants.rootRef.childByAppendingPath("teszt")
        childRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            let name = snapshot.value.objectForKey("beaconName") as! String
            let uuid = snapshot.value.objectForKey("UUID") as! String
            let major = snapshot.value.objectForKey("Major") as? Int
            let minor = snapshot.value.objectForKey("Minor") as? Int
            let bmr = BeaconManager.beaconManager
            if let beacon = bmr.createBeacon(uuid, major: major, minor: minor, identifier: name) {
                dispatch_async(dispatch_get_main_queue()) {
                bmr.addBeacon(beacon)
                }
            }
        })
    }
}
