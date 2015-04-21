//
//  BeaconTableController.swift
//  FindMyStuff
//
//  Created by Sinka Zoltán on 2015. 03. 01..
//  Copyright (c) 2015. Sinka Zoltán. All rights reserved.
//

import UIKit

class BeaconTableController: UITableViewController {
    
    // MARK: Properties
    let beaconManager = BeaconManager.beaconManager
    let notificationCenter = NSNotificationCenter.defaultCenter()
    let persistanceManager = OnlinePersistanceManager()
    var editedBeacon: BeaconItem?
    
    deinit {
        notificationCenter.removeObserver(self)
    }
    
    // MARK: Table Delegate functions
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if beaconManager.sharedBeacons.count == 0 {
            return 1
        }
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return beaconManager.beacons.count
        } else if section == 1 {
            return beaconManager.sharedBeacons.count
        } else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            case 1: return "Foreign beacons"
            default: return nil
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            // OWNED BEACONS
            let cell = tableView.dequeueReusableCellWithIdentifier("BeaconCell", forIndexPath: indexPath) as! BeaconItemCell
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
            cell.cellDelegate = self
            cell.beaconBackground.hidden = true
            if let imageURL = beacon.imageURL {
                if let image = UIImage(contentsOfFile: imageURL) {
                    cell.changeImage(image)
                    cell.beaconBackground.hidden = false
                }
            } else {
                cell.beaconImage.image = nil
            }
            
            if let uploaded = beacon.sharedNodeDescriptor {
                cell.beaconUploadedIcon.hidden = false
            } else {
                cell.beaconUploadedIcon.hidden = true
            }
            return cell
        } else {
            // FOREIGN BEACONS
            let cell = tableView.dequeueReusableCellWithIdentifier("BeaconCell", forIndexPath: indexPath) as! BeaconItemCell
            let beacon = beaconManager.sharedBeacons[indexPath.row]
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
            cell.beaconImage.image = nil
            cell.cellDelegate = self
            cell.beaconBackground.hidden = true
            cell.beaconUploadedIcon.hidden = true
         return cell
        }
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    override func tableView(tableView: UITableView, canPerformAction action: Selector, forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, performAction action: Selector, forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject!) {
        // kell a menühöz
    }
    
    override func tableView(tableView: UITableView, shouldShowMenuForRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.section == 0 {
            return true
        } else {
            return false
        }
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        if indexPath.section == 0 {
            let beacon = beaconManager.beacons[indexPath.row]
            var returnedMenuItem:[AnyObject]?
            
            if let sharedNode = beacon.sharedNodeDescriptor {
                returnedMenuItem = self.createHiddenMenuItem(.Unshare, forBeaconItem: beacon)
            } else {
                returnedMenuItem =  self.createHiddenMenuItem(.Share, forBeaconItem: beacon)
                self.editedBeacon = beacon
            }
            return returnedMenuItem
        } else {
            let beacon = beaconManager.sharedBeacons [indexPath.row]
            var returnedMenuItem = self.createHiddenMenuItem(.Delete, forBeaconItem: beacon)
            return returnedMenuItem
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            beaconManager.toggleRanging(indexPath.row)
        } else {
           beaconManager.toggleRangingForForeignBeacon(indexPath.row)
        }
        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return CGFloat(0.01)
        } else {
            return CGFloat(20)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EditBeaconSegue" {
            if let destinationVC = segue.destinationViewController as? EditBeaconViewController {
                if let beacon = self.editedBeacon {
                    destinationVC.beacon = beacon
                }
            }
        }
    }
}

// MARK: Menu item creator
extension BeaconTableController {
    enum menuItemType {
        case Share
        case Unshare
        case Delete
    }
    
    func createHiddenMenuItem(type: menuItemType, forBeaconItem: BeaconItem) -> [AnyObject]? {
        switch type {
        case .Share:
            var shareAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "Share", handler: { (action: UITableViewRowAction!, indexPath: NSIndexPath!) -> Void in
                
                let sharePopUp = UIAlertController(title: "Share beacon UUID", message: "By using this identifier, you can share you beacon's uuid with anyone. \n Please not that by using this feature, your beacon UUID becomes public", preferredStyle: .Alert )
                
                sharePopUp.addTextFieldWithConfigurationHandler({ (textField: UITextField!) -> Void in
                    var randomText = NSProcessInfo.processInfo().globallyUniqueString
                    let index = advance(randomText.startIndex,8)
                    randomText = randomText.substringToIndex(index)
                    textField.text = randomText
                })
                
                let shareAction = UIAlertAction(title: "Share", style: UIAlertActionStyle.Default, handler: { (alert) -> Void in
                    if let uiTextField = sharePopUp.textFields?.first as? UITextField where !uiTextField.text.isEmpty {
                        println(uiTextField.text)
                        self.persistanceManager.checkNodeAvailability(uiTextField.text)
                    }
                })
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
                
                sharePopUp.addAction(shareAction)
                sharePopUp.addAction(cancelAction)
                self.presentViewController(sharePopUp, animated: true, completion: nil)
                }
            )
            return [shareAction]
        
        case .Unshare:
            var shareAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "Unshare", handler: { (action: UITableViewRowAction!, indexPath: NSIndexPath!) -> Void in
                
                let sharePopUp = UIAlertController(title: "Unshare beacon UUID", message: "You can remove your shared beacon information by pressing Unshare \nShared id: \(forBeaconItem.sharedNodeDescriptor!)", preferredStyle: .Alert )
                
                let shareAction = UIAlertAction(title: "Unshare", style: UIAlertActionStyle.Default, handler: { (alert) -> Void in
                    self.persistanceManager.removeNode(forBeaconItem.sharedNodeDescriptor!)
                    forBeaconItem.sharedNodeDescriptor = nil
                    self.tableView.reloadData()
                })
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
                
                sharePopUp.addAction(shareAction)
                sharePopUp.addAction(cancelAction)
                self.presentViewController(sharePopUp, animated: true, completion: nil)
                }
            )
            return [shareAction]
            
        case .Delete:
            var shareAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "Delete", handler: { (action: UITableViewRowAction!, indexPath: NSIndexPath!) -> Void in
                
                let sharePopUp = UIAlertController(title: "Delete foreign beacon", message: "You can remove your foreign beacon information by pressing Delete", preferredStyle: .Alert )
                
                let shareAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Destructive, handler: { (alert) -> Void in
                    self.persistanceManager.stopObservingForBeacon(forBeaconItem.sharedNodeDescriptor!)
                    self.beaconManager.removeForeignBeaconWithDescriptor(forBeaconItem.sharedNodeDescriptor!)
                    self.tableView.reloadData()
                })
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
                
                sharePopUp.addAction(shareAction)
                sharePopUp.addAction(cancelAction)
                self.presentViewController(sharePopUp, animated: true, completion: nil)
                }
            )
            return [shareAction]
            
        default:
            return nil
        }
    }
}



// MARK: - Delegate Functions
extension BeaconTableController: BeaconItemCellDelegate {
    
    // unused atm, TBD
    func locationUpdate(cell: BeaconItemCell) -> String {
        return ""
    }
    
    // unused atm, TBD
    func nameUpdate(cell: BeaconItemCell) -> String {
       return ""
    }
    
    func deleteCell(cell: BeaconItemCell) {
        if let indexPath = self.tableView.indexPathForCell(cell) {
        let beacon = beaconManager.beacons[indexPath.row]
            if beacon.sharedNodeDescriptor == nil {
                beaconManager.removeBeacon(indexPath.row)
            } else {
                self.shootAlertWithMessage("Please unshare before removing beacon")
            }
            
        }
        self.tableView.reloadData()
    }
    
    func editCell(cell: BeaconItemCell) {
        if let indexPath = self.tableView.indexPathForCell(cell) {
            self.editedBeacon = beaconManager.beacons[indexPath.row]
            performSegueWithIdentifier("EditBeaconSegue", sender: self)
        }
    }
}

// MARK: Notification management and initial setup

extension BeaconTableController {
    override func viewDidLoad() {
        
        notificationCenter.addObserverForName("LocationUpdateNotification", object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
            self.tableView.reloadData()
        }
        
        notificationCenter.addObserverForName("BeaconAddNotification", object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
            self.tableView.reloadData()
            self.tableView.setNeedsDisplay()
            //self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
        
        notificationCenter.addObserverForName("SharedNameIsAvailable", object: nil , queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
            if let userInfo = notification.userInfo as? [String:String] {
                if let destination = userInfo["destination"], beacon = self.editedBeacon {
                    self.persistanceManager.uploadBeacon(beacon, destination: destination)
                }
            }
            self.tableView.reloadData()
        }

        notificationCenter.addObserverForName("SharedNameIsNOTAvailable", object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
            self.shootAlertWithMessage("The requested share id is not available")
        }

        notificationCenter.addObserverForName("SharedBeaconCannotBeFound", object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
            self.shootAlertWithMessage("Shared beacon cannot be found!")
        }
        
        notificationCenter.addObserverForName("CannotAddBeacon", object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
            self.shootAlertWithMessage("Beacon cannot be added because it already exists or you have reached the max beacon limit")
        }

        let editMenu = UIMenuItem(title: "Edit", action: "edit:")
        var menuController = UIMenuController()
        menuController.setMenuVisible(true, animated: true)
        menuController.menuItems = [UIMenuItem]()
        menuController.menuItems?.append(editMenu)
        menuController.update()
    }
    
    func shootAlertWithMessage(message: String) {
        let alert = UIAlertView(title: "Error", message: message, delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "OK")
        alert.show()
    }
    
    override func viewWillDisappear(animated: Bool) {
        beaconManager.persistData()
        self.title = "Cancel"
    }
    
    override func viewWillAppear(animated: Bool) {
        beaconManager.persistData()
        self.title = "Find my stuff"
        self.tableView.reloadData()
        self.tableView.setNeedsDisplay()
    }
}


