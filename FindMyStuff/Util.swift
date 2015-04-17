//
//  Util.swift
//  FindMyStuff
//
//  Created by Sinka Zoltán on 2015. 04. 13..
//  Copyright (c) 2015. Sinka Zoltán. All rights reserved.
//

import Foundation
import UIKit

func setupNotification() {
    let notificationSettings = UIApplication.sharedApplication().currentUserNotificationSettings()
    if (notificationSettings.types == UIUserNotificationType.None){
        var notificationTypes: UIUserNotificationType = UIUserNotificationType.Alert | UIUserNotificationType.Sound
        
        var outOfRangeAction = UIMutableUserNotificationAction()
        outOfRangeAction.identifier = "outOfRange"
        outOfRangeAction.title = "Beacon out of range"
        outOfRangeAction.activationMode = UIUserNotificationActivationMode.Background
        outOfRangeAction.destructive = false
        outOfRangeAction.authenticationRequired = false
        
        var inRangeAction = UIMutableUserNotificationAction()
        inRangeAction.identifier = "inRange"
        inRangeAction.title = "Beacon in range"
        inRangeAction.activationMode = UIUserNotificationActivationMode.Background
        inRangeAction.destructive = false
        inRangeAction.authenticationRequired = false
        
        let actionsArray = NSArray(objects: outOfRangeAction, inRangeAction)
        let actionsArrayMinimal = NSArray(objects: outOfRangeAction, inRangeAction)
        
        var beaconActionCategory = UIMutableUserNotificationCategory()
        beaconActionCategory.identifier = "beaconActionCategory"
        beaconActionCategory.setActions(actionsArray as [AnyObject], forContext: UIUserNotificationActionContext.Default)
        beaconActionCategory.setActions(actionsArrayMinimal as [AnyObject], forContext: UIUserNotificationActionContext.Minimal)
        
        let categoriesForSettings = NSSet(objects: beaconActionCategory)
        
        let newNotificationSettings = UIUserNotificationSettings(forTypes: notificationTypes, categories: categoriesForSettings as Set<NSObject>)
        UIApplication.sharedApplication().registerUserNotificationSettings(newNotificationSettings)
        
    }
}

func scheduleSimpleNotification(message: String, identifier: String) {
    UIApplication.sharedApplication().cancelAllLocalNotifications()
    var localNotification = UILocalNotification()
    localNotification.fireDate = nil
    localNotification.alertBody = message
    localNotification.alertAction = identifier
    localNotification.category = "beaconActionCategory"
    localNotification.soundName = UILocalNotificationDefaultSoundName
    UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
}




