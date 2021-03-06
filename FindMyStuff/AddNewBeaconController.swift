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
    let persistanceManager = OnlinePersistanceManager()
    
    
    
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
                if let text = sharedIDText.text {
                    persistanceManager.downloadBeacon(text)
                    self.navigationController?.popToRootViewControllerAnimated(true)
                }
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
            let validity = !field.text.isEmpty
            if !validity {
                shootAlertWithMessage("You must add a name to a beacon")
            }
            return validity
        } else if field.isEqual(newBeaconUUID) {
            let validity = beaconManager.isValidUUID(field.text)
            if !validity {
                shootAlertWithMessage("Invalid UUID!")
            }
            return validity
        } else if field.isEqual(newBeaconMajor) {
            let validity = (field.text.toInt() < 256 && field.text.toInt() >= 0 || field.text.isEmpty) ? true : false
            if !validity {
                shootAlertWithMessage("The Major must be between 0 and 255")
            }
            return validity
        } else if field.isEqual(newBeaconMinor) {
            let validity = (field.text.toInt() < 256 && field.text.toInt() >= 0 || field.text.isEmpty) ? true : false
            if !validity {
                shootAlertWithMessage("The Major must be between 0 and 255")
            }
            return validity
        }
      return false
    }
    
    func shootAlertWithMessage(message: String) {
        let alert = UIAlertView(title: "Error", message: message, delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "OK")
        alert.show()
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
