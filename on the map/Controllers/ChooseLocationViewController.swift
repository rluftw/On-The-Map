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

    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var findOnMapButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var location: CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationTextField.delegate = self
        locationTextField.becomeFirstResponder()
        
        locationTextField.transform = CGAffineTransformMakeTranslation(-view.frame.width, 0)
    }
    
    override func viewWillAppear(animated: Bool) {
        UIView.animateWithDuration(1.0, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1.0, options: [], animations: { () -> Void in
            self.locationTextField.transform = CGAffineTransformIdentity
            }, completion: nil)
    }

    
    // MARK: - TextField delegate methods
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    // MARK: - IBAction methods
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func findOnTheMap(sender: AnyObject) {
        view.endEditing(true)
        toggleUI()
        
        guard let text = locationTextField.text where text != "" else {
            self.showAlert("", message: "Please enter a location")
            toggleUI()
            return
        }
        
        // If the location is valid
        CLGeocoder().geocodeAddressString(locationTextField.text!) { (placemarks, error) -> Void in
            guard error == nil else {
                self.toggleUI()
                self.showAlert("", message: "Failed to fetch the coordinates")
                return
            }
            
            if placemarks?.count > 0 {
                self.location = placemarks!.first!.location!
                self.performSegueWithIdentifier("postURL", sender: self)
            } else {
                self.showAlert("", message: "Invalid Location")
            }
            
            self.toggleUI()
        }

    }
    
    // MARK: - Helper methods
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func toggleUI() {
        // Enable/Disable controls
        cancelButton.enabled = !cancelButton.enabled
        findOnMapButton.enabled = !findOnMapButton.enabled
        
        // Transparency
        titleLabel.alpha = titleLabel.alpha == 1.0 ? 0.5: 1.0
        cancelButton.alpha = cancelButton.alpha == 1.0 ? 0.5: 1.0
        findOnMapButton.alpha = findOnMapButton.alpha == 1.0 ? 0.5: 1.0
        mapView.alpha = mapView.alpha == 1.0 ? 0.5: 1.0
        
        // Animation
        activityIndicator.isAnimating() ? activityIndicator.stopAnimating(): activityIndicator.startAnimating()
    }
    
    // MARK: - Navigation
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        guard let _ = location else {
            return false
        }
        
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "postURL" {
            let postURLVC = segue.destinationViewController as! PostURLViewController
            postURLVC.location = location
        }
    }
}
