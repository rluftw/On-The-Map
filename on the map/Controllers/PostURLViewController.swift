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
        URLTextField.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)

        // Place the location on the map
        pinOnMap()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 10.0, options: [], animations: { () -> Void in
                self.URLTextField.transform = CGAffineTransform.identity
            }, completion: nil)
    }
    
    // MARK: - Mapview delegate methods
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseIndentifier = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIndentifier) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseIndentifier)
            pinView!.pinTintColor = UIColor(red: 1.0, green: 158/255.0, blue: 0.0, alpha: 1.0)
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    // MARK: - TextField delegate methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = "http://"
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if !textField.text!.hasPrefix("http") {
            textField.text = "http://\(textField.text!)"
        }
    }
    
    // MARK: - IBAction methods
    @IBAction func cancel(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func postLocation(_ sender: AnyObject) {
        view.endEditing(true)
        
        toggleUI()
        
        let app = UIApplication.shared
        guard let text = URLTextField.text, let url = URL(string: text), app.canOpenURL(url) else {
            toggleUI()
            // Notify the user to enter a URL.
            showAlert("", message: "Please enter a valid URL")
            
            return
        }
        
        let jsonBody: [String: AnyObject] = [
            ParseClient.JSONBodyKeys.FirstName: UdacityClient.StudentInfoResponse.FirstName as AnyObject,
            ParseClient.JSONBodyKeys.LastName: UdacityClient.StudentInfoResponse.LastName as AnyObject,
            ParseClient.JSONBodyKeys.Latitude: location.coordinate.latitude as AnyObject,
            ParseClient.JSONBodyKeys.Longitude: location.coordinate.longitude as AnyObject,
            ParseClient.JSONBodyKeys.MapString: mapString as AnyObject,
            ParseClient.JSONBodyKeys.MediaURL: URLTextField.text! as AnyObject,
            ParseClient.JSONBodyKeys.UniqueKey: UdacityClient.StudentInfoResponse.SessionID as AnyObject
        ]
                
        ParseClient.sharedInstance().postStudentLocation(jsonBody) { (success, result, error) -> Void in
            
            // Check if there were any errors. i.e network
            guard (error == nil) else {
                self.toggleUI()
                self.showAlert("Post", message: error!.localizedDescription)
                return
            }
            
            if success {
                self.dismiss(animated: true, completion: nil)
            }

            self.toggleUI()
        }
    }
    
    
    // MARK: - Helper methods
    func toggleUI() {
        activityIndicator.isAnimating ? activityIndicator.stopAnimating(): activityIndicator.startAnimating()
        
        // enable/disable controls
        URLTextField.isEnabled = !URLTextField.isEnabled
        cancelButton.isEnabled = !cancelButton.isEnabled
        postButton.isEnabled = !postButton.isEnabled
        
        // transparency
        
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
        
        // Set the view angle
        mapView.camera.pitch = 45
    }
    
    func showAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }

}
