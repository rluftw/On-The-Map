//
//  PostLocationViewController.swift
//  on the map
//
//  Created by Xing Hui Lu on 2/12/16.
//  Copyright © 2016 Xing Hui Lu. All rights reserved.
//

import UIKit
import MapKit

class ChooseLocationViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var locationTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationTextField.delegate = self
        locationTextField.becomeFirstResponder()
    }

    // MARK: - IBAction methods
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func findOnTheMap(sender: AnyObject) {
        // If the location is valid
        

    }
    
    // MARK: - TextField delegate methods
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }

}
