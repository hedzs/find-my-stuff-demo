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
    //func isTheBeaconTracked(cell: BeaconItemCell) ->Bool
}

class BeaconItemCell: UITableViewCell {
    
    var cellDelegate: BeaconItemCellDelegate!
   
    
    @IBOutlet weak var beaconNameLabel: UILabel!
    @IBOutlet weak var beaconLocationLabel: UILabel!
        
    
    var isTracked:Bool = false {
        didSet {
            beaconLocationLabel.hidden = !isTracked
        }
    }
        

    var backgroundImage: UIImage? {
        didSet {
            self.backgroundImage = backgroundImage!
            
        }
    }

    
}
