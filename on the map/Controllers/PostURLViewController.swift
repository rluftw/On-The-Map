//
//  PostURLViewController.swift
//  on the map
//
//  Created by Xing Hui Lu on 2/13/16.
//  Copyright © 2016 Xing Hui Lu. All rights reserved.
//

import UIKit
import MapKit

class PostURLViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate {
    
    var location: CLLocation!
    var mapString: String!
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var URLTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var postButton: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        URLTextField.delegate = self
        
        URLTextField.frame.size.height = 0
        URLTextField.transform = CGAffineTransformMakeScale(0.1, 0.1)

        // Place the location on the map
        pinOnMap()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        UIView.animateWithDuration(1.0, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 10.0, options: [], animations: { () -> Void in
                self.URLTextField.transform = CGAffineTransformIdentity
            }, completion: nil)
    }
    
    // MARK: - Mapview delegate methods
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseIndentifier = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseIndentifier) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseIndentifier)
            pinView!.pinTintColor = UIColor(red: 1.0, green: 158/255.0, blue: 0.0, alpha: 1.0)
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    // MARK: - TextField delegate methods
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.text = "http://"
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if !textField.text!.hasPrefix("http://") {
            textField.text = "http://\(textField.text!)"
        }
    }
    
    // MARK: - IBAction methods
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func postLocation(sender: AnyObject) {
        URLTextField.resignFirstResponder()
        
        toggleUI()
        
        let app = UIApplication.sharedApplication()
        guard let text = URLTextField.text, url = NSURL(string: text) where app.canOpenURL(url) else {
            toggleUI()
            // Notify the user to enter a URL.
            showAlert("", message: "Please enter a valid URL")
            
            return
        }
        
        let jsonBody: [String: AnyObject] = [
            ParseClient.JSONBodyKeys.FirstName: UdacityClient.StudentInfoResponse.FirstName,
            ParseClient.JSONBodyKeys.LastName: UdacityClient.StudentInfoResponse.LastName,
            ParseClient.JSONBodyKeys.Latitude: location.coordinate.latitude,
            ParseClient.JSONBodyKeys.Longitude: location.coordinate.longitude,
            ParseClient.JSONBodyKeys.MapString: mapString,
            ParseClient.JSONBodyKeys.MediaURL: URLTextField.text!,
            ParseClient.JSONBodyKeys.UniqueKey: UdacityClient.StudentInfoResponse.SessionID
        ]
                
        ParseClient.sharedInstance().postStudentLocation(jsonBody) { (success, result, error) -> Void in
            
            // Check if there were any errors. i.e network
            guard (error == nil) else {
                self.toggleUI()
                self.showAlert("Post", message: error!.localizedDescription)
                return
            }
            
            if success {
                self.dismissViewControllerAnimated(true, completion: nil)
            }

            self.toggleUI()
        }
    }
    
    
    // MARK: - Helper methods
    func toggleUI() {
        activityIndicator.isAnimating() ? activityIndicator.stopAnimating(): activityIndicator.startAnimating()
        URLTextField.enabled = !URLTextField.enabled
        cancelButton.enabled = !cancelButton.enabled
        postButton.enabled = !postButton.enabled
    }
    
    func pinOnMap() {
        let pointAnnotation = MKPointAnnotation()
        pointAnnotation.coordinate = location.coordinate
        
        /* 
            This is to zoom into the region 
                - 500 meters vertically
                - 500 meeters horizontally
        */
        let region = MKCoordinateRegionMakeWithDistance(location.coordinate, 500, 500)
        
        mapView.setRegion(region, animated: true)
        mapView.addAnnotation(pointAnnotation)
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        
        presentViewController(alert, animated: true, completion: nil)
    }

}
