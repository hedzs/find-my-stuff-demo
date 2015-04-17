//
//  EditBeaconViewController.swift
//  FindMyStuff
//
//  Created by Sinka Zoltán on 2015. 03. 26..
//  Copyright (c) 2015. Sinka Zoltán. All rights reserved.
//

import UIKit
import MapKit

class EditBeaconViewController: UITableViewController, MKMapViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
   
    lazy var imagePicker = UIImagePickerController()
    let beaconManager = BeaconManager.beaconManager
    var beacon: BeaconItem?
    
    @IBOutlet weak var beaconLocationUpdateLabel: UILabel!
    @IBOutlet weak var cameraIcon: UIButton!
    @IBOutlet weak var photoLibraryIcon: UIButton!
    @IBOutlet weak var removeBeaconImage: UIButton!
    @IBOutlet weak var beaconName: UITextField!
    @IBOutlet weak var beaconImage: UIImageView!
    @IBOutlet weak var beaconMapView: MKMapView! {
        didSet {
            beaconMapView.delegate = self
        }
    }
    @IBOutlet weak var beaconInRangeSwitch: UISwitch!
    @IBOutlet weak var beaconUnknownSwitch: UISwitch!
    
    
    @IBAction func useCamera(sender: UIButton) {
        imagePicker.delegate = self
        imagePicker.sourceType = .Camera
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func choosePhoto(sender: UIButton) {
        imagePicker.delegate = self
        imagePicker.sourceType = .PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    
    @IBAction func removeBeaconPic() {
        if let deleteURL = beacon?.imageURL {
            let fileManager = NSFileManager.defaultManager()
            fileManager.removeItemAtPath(deleteURL, error: nil)
        }
        beacon?.imageURL = nil
        updateUIObjectsContent()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        cameraIcon.imageView?.tintColor = UIColor.whiteColor()
        photoLibraryIcon.imageView?.tintColor = UIColor.whiteColor()
        removeBeaconImage.imageView?.tintColor = UIColor.whiteColor()
        
        let addBarItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: "doneEditing")
        self.navigationItem.rightBarButtonItem = addBarItem
        updateUIObjectsContent()
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        println("teszt")
        beaconImage.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        println("Documents/\(beacon!.beaconName).jpeg")
        let saveURL = NSHomeDirectory().stringByAppendingPathComponent("Documents/\(beacon!.beaconName).jpeg")
        beacon?.imageURL = saveURL
        if UIImageJPEGRepresentation(beaconImage.image, CGFloat(0.85)).writeToFile(saveURL, atomically: true) {
            println("UIImage elmentve")
        }
    }
    
    
    func doneEditing() {
        if let beacon = self.beacon {
            beaconManager.toggleNotifyOnEntry(beacon, toState: beaconInRangeSwitch.on)
            beaconManager.toggleNotifyOnExit(beacon, toState: beaconUnknownSwitch.on)
        }
//        beacon?.isNotificationOnWhenGetsInRange = beaconInRangeSwitch.on
//        beacon?.isNotificationOnWhenProximityUnknown = beaconUnknownSwitch.on
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func updateUIObjectsContent() {
        if let beacon = self.beacon {
            beaconName.text = beacon.beaconName
            beaconInRangeSwitch.on = beacon.isNotificationOnWhenGetsInRange
            beaconUnknownSwitch.on = beacon.isNotificationOnWhenProximityUnknown
            if let coordinate = beacon.lastKnownLocation {
                let mapPoint = MKPointAnnotation()
                mapPoint.coordinate = coordinate
                beaconMapView.addAnnotation(mapPoint)
                //beaconMapView.centerCoordinate = coordinate
                beaconMapView.setRegion(MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan()), animated: true)
            }
            if let imageURL = beacon.imageURL {
                println("van imageURL")
                if let image = UIImage(contentsOfFile: imageURL) {
                    let orientedImage = UIImage(CIImage: CIImage(image: image), scale: CGFloat(1), orientation: .Right)
                    println("megtaláltam a képet")
                    
                    beaconImage.image = orientedImage
                }
            } else {
                beaconImage.backgroundColor = UIColor(red: CGFloat(0.097), green: CGFloat(0.515), blue: CGFloat(0.57), alpha: CGFloat(1))
                beaconImage.image = nil
            }
            beaconImage.setNeedsDisplay()
            if beacon.isTracked {
                beaconManager.restartRangingService(beacon.beaconRegion)
            }
        }
        
    }
    
    
    
}
