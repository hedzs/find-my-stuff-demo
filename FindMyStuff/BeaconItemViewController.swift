//
//  ViewController.swift
//  FindMyStuff
//
//  Created by Sinka Zoltán on 2015. 02. 20..
//  Copyright (c) 2015. Sinka Zoltán. All rights reserved.
//

import UIKit
import CoreLocation

class BeaconItemViewController: UIViewController {

    
    var beaconManager = BeaconManager()
    
    var rangingOn = false
    

    @IBOutlet weak var proximityLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
       
    }

    @IBAction func proximityUpdate(sender: UIButton){
        if rangingOn {
            beaconManager.stopRanging()
            rangingOn = !rangingOn
        } else {
            beaconManager.startRanging()
            rangingOn = !rangingOn

        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

