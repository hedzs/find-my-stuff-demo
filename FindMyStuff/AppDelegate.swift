//
//  AppDelegate.swift
//  FindMyStuff
//
//  Created by Sinka Zoltán on 2015. 02. 20..
//  Copyright (c) 2015. Sinka Zoltán. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let isDeviceCapableOfMonitoring = CLLocationManager.isRangingAvailable()
    let isAppAuthorizedToLocate = CLLocationManager.authorizationStatus()
    let beaconManager = BeaconManager.beaconManager
    let persistanceManager = OnlinePersistanceManager()
    
    
    func application(application: UIApplication, willFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        /* TODO: check backgroundRefreshStatus ha szükséges lesz rá + redirect to Settings
        if !isDeviceCapableOfMonitoring || isAppAuthorizedToLocate != CLAuthorizationStatus.Authorized {
            return false
        }
        */
        return true
    }
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let appearance = UINavigationBar.appearance()
        appearance.barTintColor = UIColor(red: CGFloat(0.1328), green: CGFloat(0.3242), blue: CGFloat(0.46875), alpha: CGFloat(1.0))
        appearance.tintColor = UIColor.whiteColor()
        appearance.barStyle = UIBarStyle.Black
        persistanceManager.startupCheckForForeignBeacons()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        beaconManager.persistData()
        CLLocationManager().stopUpdatingLocation()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        CLLocationManager().startUpdatingLocation()
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        beaconManager.persistData()
        beaconManager.shutDownActiveTrackingForAllBeaconRegions()
        
        CLLocationManager().stopUpdatingLocation()
        //NSNotificationCenter.removeObserver(self)
    }


}

