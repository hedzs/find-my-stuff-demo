//
//  BeaconTableController.swift
//  FindMyStuff
//
//  Created by Sinka Zoltán on 2015. 03. 01..
//  Copyright (c) 2015. Sinka Zoltán. All rights reserved.
//

import UIKit

class BeaconTableController: UITableViewController {
    
    let beaconManager = BeaconManager.beaconManager
    let notificationCenter = NSNotificationCenter.defaultCenter()
    
    
    // MARK: Table Delegate functions
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return beaconManager.beacons.count
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BeaconCell", forIndexPath: indexPath) as BeaconItemCell
        let beacon = beaconManager.beacons[indexPath.row]
        cell.beaconNameLabel.text = "  \(beacon.beaconName)  "
        cell.beaconLocationLabel.text  = beacon.lastKnownProximity.description
        switch beacon.lastKnownProximity {
            case .Far: cell.beaconLocationLabel.textColor = UIColor.redColor()
            case .Immediate: cell.beaconLocationLabel.textColor = UIColor.greenColor()
            case .Near: cell.beaconLocationLabel.textColor = UIColor.yellowColor()
            case .Unknown: cell.beaconLocationLabel.textColor = UIColor.grayColor()
            default: break
        }
        cell.isTracked = beacon.isTracked
        cell.cellDelegate = self // TBD
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    override func tableView(tableView: UITableView, shouldShowMenuForRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        var shareAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "Share", handler: { (action: UITableViewRowAction!, indexPath: NSIndexPath!) -> Void in
            
                let sharePopUp = UIAlertController(title: "Share beacon UUID", message: "By using this identifier, you can share you beacon's uuid with anyone. \n Privacy disclaimer", preferredStyle: .Alert )
                let shareAction = UIAlertAction(title: "Share", style: UIAlertActionStyle.Default, handler: nil)
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
            
                sharePopUp.addTextFieldWithConfigurationHandler({ (textField: UITextField!) -> Void in
                    var randomText = NSProcessInfo.processInfo().globallyUniqueString
                    let index = advance(randomText.startIndex,8)
                    randomText = randomText.substringToIndex(index)
                    textField.text = randomText
                })
            
                sharePopUp.addAction(shareAction)
                sharePopUp.addAction(cancelAction)
                self.presentViewController(sharePopUp, animated: true, completion: nil)
            }
        )
        return [shareAction]
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        beaconManager.toggleRanging(indexPath.row)
        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return CGFloat(1)
        } else {
            return CGFloat(15)
        }
    }
    
}

// MARK: - Initial setup




// MARK: - Delegate Functions
extension BeaconTableController: BeaconItemCellDelegate {
    func locationUpdate(cell: BeaconItemCell) -> String {
        return ""
    }
    
    func nameUpdate(cell: BeaconItemCell) -> String {
       return ""
    }
}

// MARK: Notification management

extension BeaconTableController {
    override func viewDidLoad() {
        notificationCenter.addObserverForName("LocationUpdateNotification", object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
            self.tableView.reloadData()
            println("Jött egy notification az updatere!")
        }
        
        notificationCenter.addObserverForName("BeaconAddNotification", object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
            self.tableView.reloadData()
            self.tableView.setNeedsDisplay()
            println("Jött egy notification az updatere!")
        }

        
        let testPersistence = OnlinePersistanceManager()
        let test = testPersistence.checkNodeAvailability("Nodelee")
        println("A teszt eredménye: \(test)")
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.title = "Cancel"
    }
    
    override func viewWillAppear(animated: Bool) {
        self.title = "Find my stuff"
    }
}


