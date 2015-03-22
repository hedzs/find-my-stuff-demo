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
    
    
    func checkNodeAvailability(nodeName: String) -> Bool {
        var childRef = Constants.rootRef.childByAppendingPath(nodeName)
        var availability = false
        let backgroundqueue = dispatch_get_global_queue(Int(QOS_CLASS_BACKGROUND.value), 0)
        dispatch_sync(backgroundqueue) {
            dispatch_barrier_async(backgroundqueue) {
            childRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                println("Observer added")
                println(snapshot.value as NSObject)
                println(NSNull())
                if snapshot.value as NSObject == NSNull() {
                    availability = true
                    println("true lett")
                    
                }
                println("first")
            })
          }
        }
        println("second")
        return availability
    }
}
