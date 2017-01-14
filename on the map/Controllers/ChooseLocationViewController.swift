//
//  PostLocationViewController.swift
//  on the map
//
//  Created by Xing Hui Lu on 2/12/16.
//  Copyright © 2016 Xing Hui Lu. All rights reserved.
//

import UIKit
import MapKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


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
        
        locationTextField.transform = CGAffineTransform(translationX: -view.frame.width, y: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1.0, options: [], animations: { () -> Void in
            self.locationTextField.transform = CGAffineTransform.identity
            }, completion: nil)
    }

    
    // MARK: - TextField delegate methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    // MARK: - IBAction methods
    
    @IBAction func cancel(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func findOnTheMap(_ sender: AnyObject) {
        view.endEditing(true)
        toggleUI()
        
        guard let text = locationTextField.text, text != "" else {
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
                self.performSegue(withIdentifier: "postURL", sender: self)
            } else {
                self.showAlert("", message: "Invalid Location")
            }
            
            self.toggleUI()
        }

    }
    
    // MARK: - Helper methods
    
    func showAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    func toggleUI() {
        // Enable/Disable controls
        cancelButton.isEnabled = !cancelButton.isEnabled
        findOnMapButton.isEnabled = !findOnMapButton.isEnabled
        
        // Transparency
        titleLabel.alpha = titleLabel.alpha == 1.0 ? 0.5: 1.0
        cancelButton.alpha = cancelButton.alpha == 1.0 ? 0.5: 1.0
        findOnMapButton.alpha = findOnMapButton.alpha == 1.0 ? 0.5: 1.0
        mapView.alpha = mapView.alpha == 1.0 ? 0.5: 1.0
        
        // Animation
        activityIndicator.isAnimating ? activityIndicator.stopAnimating(): activityIndicator.startAnimating()
    }
    
    // MARK: - Navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard let _ = location else {
            return false
        }
        
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "postURL" {
            let postURLVC = segue.destination as! PostURLViewController
            postURLVC.location = location
            postURLVC.mapString = locationTextField.text!
        }
    }
}
