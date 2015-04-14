//
//  Utils.swift
//  FindMyStuff
//
//  Created by Sinka Zoltán on 2015. 03. 18..
//  Copyright (c) 2015. Sinka Zoltán. All rights reserved.
//

import Foundation
import UIKit

class Utils {
   
    class var core: Utils {
        struct Singleton {
            static let instance = Utils()
        }
        return Singleton.instance
    }
    
    //MARK: Notification basics
    
    
    
    class func setupNotification() {
        let notificationSettings = UIApplication.sharedApplication().currentUserNotificationSettings()
        if (notificationSettings.types == UIUserNotificationType.None){
            var notificationTypes: UIUserNotificationType = UIUserNotificationType.Alert | UIUserNotificationType.Sound
            
            
            // Specify the notification actions.
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
            
            // Register the notification settings.
            let newNotificationSettings = UIUserNotificationSettings(forTypes: notificationTypes, categories: categoriesForSettings as Set<NSObject>)
            UIApplication.sharedApplication().registerUserNotificationSettings(newNotificationSettings)
    
        }
    }
    
    class func scheduleSimpleNotification(message: String) {
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        var localNotification = UILocalNotification()
        localNotification.fireDate = nil
        localNotification.alertBody = message
        localNotification.alertAction = "Beacon"
        localNotification.category = "beaconActionCategory"
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }
    
    //MARK: Thread related
    var GlobalMainQueue: dispatch_queue_t {
        return dispatch_get_main_queue()
    }
    
    var GlobalUserInteractiveQueue: dispatch_queue_t {
        return dispatch_get_global_queue(Int(QOS_CLASS_USER_INTERACTIVE.value), 0)
    }
    
    var GlobalUserInitiatedQueue: dispatch_queue_t {
        return dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.value), 0)
    }
    
    var GlobalUtilityQueue: dispatch_queue_t {
        return dispatch_get_global_queue(Int(QOS_CLASS_UTILITY.value), 0)
    }
    
    var GlobalBackgroundQueue: dispatch_queue_t {
        return dispatch_get_global_queue(Int(QOS_CLASS_BACKGROUND.value), 0)
    }

}



