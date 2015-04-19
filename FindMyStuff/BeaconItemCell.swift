//
//  BeaconItemCell.swift
//  FindMyStuff
//
//  Created by Sinka Zoltán on 2015. 03. 02..
//  Copyright (c) 2015. Sinka Zoltán. All rights reserved.
//

import UIKit

protocol BeaconItemCellDelegate {
    func locationUpdate(cell: BeaconItemCell) -> String
    func nameUpdate(cell: BeaconItemCell) -> String
    func deleteCell(cell: BeaconItemCell)
    func editCell(cell: BeaconItemCell)
}

class BeaconItemCell: UITableViewCell {
    
    var cellDelegate: BeaconItemCellDelegate!
   
    
    @IBOutlet weak var beaconUploadedIcon: UIButton!
    @IBOutlet weak var beaconBackground: UIView!
    @IBOutlet weak var beaconNameLabel: UILabel!
    @IBOutlet weak var beaconLocationLabel: UILabel!
    @IBOutlet weak var beaconImage: UIImageView! {
        didSet {
            beaconImage.contentMode = UIViewContentMode.ScaleAspectFill
        }
    }
    
    
    var isTracked:Bool = false {
        didSet {
            beaconLocationLabel.hidden = !isTracked
        }
    }
        
    func changeImage(image: UIImage) {
        beaconImage.image = image
        setNeedsDisplay()
    }

    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        return (action == Selector("edit:") || action == Selector("delete:"))
    }
    
    func edit(sender: AnyObject?) {
        cellDelegate.editCell(self)
        println("edit has been hit")
    }
    
    override func delete(sender: AnyObject?) {
        cellDelegate.deleteCell(self)
        println("delete has been hit")
    }
}
