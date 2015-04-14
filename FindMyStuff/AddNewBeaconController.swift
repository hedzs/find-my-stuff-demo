//
//  AddNewBeaconController.swift
//  FindMyStuff
//
//  Created by Sinka Zoltán on 2015. 03. 11..
//  Copyright (c) 2015. Sinka Zoltán. All rights reserved.
//

import UIKit

class AddNewBeaconController: UIViewController {
    
    let beaconManager = BeaconManager.beaconManager
    lazy var imagePicker = UIImagePickerController()
    
    
    
    @IBOutlet weak var sharedIDText: UITextField! {
        didSet {
            sharedIDText.delegate = self
        }
    }
    
    @IBOutlet weak var newBeaconName: UITextField! {
        didSet {
            newBeaconName.delegate = self
        }
    }
    
    @IBOutlet weak var newBeaconUUID: UITextField! {
        didSet {
            newBeaconUUID.delegate = self
        }
    }
    
    @IBOutlet weak var newBeaconMajor: UITextField! {
        didSet {
            newBeaconMajor.delegate = self
        }
    }
    
    @IBOutlet weak var newBeaconMinor: UITextField! {
        didSet {
            newBeaconMinor.delegate = self
        }
    }
    
    private var newBeaconGroup: [UITextField] {
        return [newBeaconName,newBeaconUUID,newBeaconMajor,newBeaconMinor]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let addBarItem = UIBarButtonItem(title: "Add", style: UIBarButtonItemStyle.Plain, target: self, action: "addBeacon:")
        self.navigationItem.rightBarButtonItem = addBarItem
        let tap = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        self.view.addGestureRecognizer(tap)
        

    }
    
    func addBeacon(button: UIBarButtonItem) {
        if !sharedIDText.text.isEmpty {
            // SHAREDID alapján add beacon
            if isTheUserInputIsValidForTextField(sharedIDText) {
//                beaconManager.addSharedBeacon(sharedIDText.text)
            }
        } else if UITextField.countFilledUITextFieldInGroup(newBeaconGroup) > 0 {
            if  isTheUserInputIsValidForTextField(newBeaconName) &&
                isTheUserInputIsValidForTextField(newBeaconUUID) &&
                isTheUserInputIsValidForTextField(newBeaconMajor) &&
                isTheUserInputIsValidForTextField(newBeaconMinor) {
                    let name = newBeaconName.text
                    let UUID = newBeaconUUID.text
                    let major = newBeaconMajor.text.toInt() ?? nil
                    let minor = newBeaconMinor.text.toInt() ?? nil
                    if beaconManager.addBeacon(UUID, major: major, minor: minor, identifier: name) {
                        self.navigationController?.popToRootViewControllerAnimated(true)
                    }
            }
        }
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    
    func disableSharedGroup() {
        sharedIDText.setDisabled()
    }
    
    func disableManualGroup() {
        for element in newBeaconGroup {
            element.setDisabled()
        }
    }
    
    func enableSharedGroup() {
        sharedIDText.setEnabled()
    }
    
    func enableManualGroup() {
        for element in newBeaconGroup {
            element.setEnabled()
        }

    }
    
    func isTheUserInputIsValidForTextField(field: UITextField) -> Bool {
        if field.isEqual(sharedIDText) {
            return true
        } else if field.isEqual(newBeaconName) {
            return !field.text.isEmpty
        } else if field.isEqual(newBeaconUUID) {
            return beaconManager.isValidUUID(field.text)
        } else if field.isEqual(newBeaconMajor) {
            return (field.text.toInt() < 256 && field.text.toInt() >= 0 || field.text.isEmpty) ? true : false
        } else if field.isEqual(newBeaconMinor) {
            return (field.text.toInt() < 256 && field.text.toInt() >= 0 || field.text.isEmpty) ? true : false
        }
      return false
    }
    
}


extension AddNewBeaconController:UITextFieldDelegate {
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.isEqual(sharedIDText) {
            disableManualGroup()
        } else {
            disableSharedGroup()
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField.text.isEmpty && textField.isEqual(sharedIDText) {
            enableManualGroup()
            return
        } else if UITextField.countFilledUITextFieldInGroup(newBeaconGroup) == 0 {
            enableSharedGroup()
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension UITextField {
    func setDisabled() {
        self.enabled = false
        self.backgroundColor = UIColor.lightGrayColor()
    }
    func setEnabled() {
        self.enabled = true
        self.backgroundColor = UIColor.whiteColor()
    }
    
    class func countFilledUITextFieldInGroup(textFields: [UITextField]) -> Int {
        let numberOfFilledTextFields = textFields.reduce(0)
            { (var counter, textFieldToBeChecked) in
                if (!textFieldToBeChecked.text.isEmpty) {
                    ++counter
                }
                return counter
        }
        return numberOfFilledTextFields
    }
}
