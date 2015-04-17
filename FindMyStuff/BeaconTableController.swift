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
    let persistanceManager = OnlinePersistanceManager()
    var editedBeacon: BeaconItem?
    
    
    // MARK: Table Delegate functions
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return beaconManager.beacons.count
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
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
                println("valtas a kepben")
                cell.changeImage(image)
                cell.beaconBackground.hidden = false
            }
        } else {
            cell.beaconImage.image = nil
        }
        
        //TESZTSOR:
            //persistanceManager.testBeaconUpload(beacon)
            //persistanceManager.testBeaconDownload()
        // EDDIG
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    override func tableView(tableView: UITableView, canPerformAction action: Selector, forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject) -> Bool {
        //return ( action == Selector("delete:") || action == Selector("edit:"))
        return true
    }
    
    override func tableView(tableView: UITableView, performAction action: Selector, forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject!) {
        // kell a menühöz
    }
    
    override func tableView(tableView: UITableView, shouldShowMenuForRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        return true
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        let beacon = beaconManager.beacons[indexPath.row]
        var returnedMenuItem:[AnyObject]?
        
        if let sharedNode = beacon.sharedNodeDescriptor {
            returnedMenuItem = self.createHiddenMenuItem(.Unshare, forBeaconItem: beacon)
        } else {
            returnedMenuItem =  self.createHiddenMenuItem(.Share, forBeaconItem: beacon)
            self.editedBeacon = beacon
        }
        
        return returnedMenuItem
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        beaconManager.toggleRanging(indexPath.row)
        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return CGFloat(0.01)
        } else {
            return CGFloat(15)
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

extension BeaconTableController {
    enum menuItemType {
        case Share
        case Unshare
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
                
                let sharePopUp = UIAlertController(title: "Unshare beacon UUID", message: "You can remove your shared beacon information by pressing Ok", preferredStyle: .Alert )
                
                let shareAction = UIAlertAction(title: "Unshare", style: UIAlertActionStyle.Default, handler: { (alert) -> Void in
                    self.persistanceManager.removeNode(forBeaconItem.sharedNodeDescriptor!)
                    forBeaconItem.sharedNodeDescriptor = nil
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
    func locationUpdate(cell: BeaconItemCell) -> String {
        return ""
    }
    
    func nameUpdate(cell: BeaconItemCell) -> String {
       return ""
    }
    
    func deleteCell(cell: BeaconItemCell) {
        if let indexPath = self.tableView.indexPathForCell(cell) {
            beaconManager.removeBeacon(indexPath.row)
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
            println("Jött egy notification az updatere!")
        }
        
        notificationCenter.addObserverForName("BeaconAddNotification", object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
            self.tableView.reloadData()
            self.tableView.setNeedsDisplay()
            //self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
            println("Jött egy notification az updatere!")
        }
        
        
        
        notificationCenter.addObserverForName("SharedNameIsAvailable", object: nil , queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
            println("Elérhető a kért név")
            if let userInfo = notification.userInfo as? [String:String] {
                if let destination = userInfo["destination"], beacon = self.editedBeacon {
                    self.persistanceManager.uploadBeacon(beacon, destination: destination)
                    println("feltöltjük a beacon infot!")
                }
            }
        }

        notificationCenter.addObserverForName("SharedNameIsNOTAvailable", object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
            println("Nem elérhető a kért név")
        }

        notificationCenter.addObserverForName("SharedBeaconCannotBeFound", object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
            println("Nem található a megosztot beacon")
        }

        let editMenu = UIMenuItem(title: "Edit", action: "edit:")
        var menuController = UIMenuController()
        menuController.setMenuVisible(true, animated: true)
        menuController.menuItems = [UIMenuItem]()
        menuController.menuItems?.append(editMenu)
        menuController.update()
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
        //TESZTSOR:
        //persistanceManager.testBeaconUpload(beacon)
        //persistanceManager.testBeaconDownload()
        // EDDIG

    }
}


