//
//  MapViewController.swift
//  on the map
//
//  Created by Xing Hui Lu on 2/11/16.
//  Copyright © 2016 Xing Hui Lu. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    var studentsInfo: [StudentInfo] {
        return AllStudentsInfo.sharedInstance().infos
    }
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var postLocationButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    // MARK: - Viewcontroller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        mapView.alpha = 0.5
        toggleUI()
        
        retrieveLocations()
    }
    
    // MARK: - IBAction methods
    
    @IBAction func logout(_ sender: AnyObject) {
        toggleUI()
        
        UdacityClient.sharedInstance().logout { (success, result, error) -> Void in
            
            // Check if there were any errors. i.e network
            guard (error == nil) else {
                self.showAlert("Logout", message: error!.localizedDescription)
                return
            }
            
            if success {
                // Clear the students array and dismiss
                AllStudentsInfo.sharedInstance().infos.removeAll()
                self.dismiss(animated: true, completion: nil)
            }

            
            self.toggleUI()
        }
    }
    
    @IBAction func refresh(_ sender: AnyObject) {
        // Can't be placed onto toggle because the animation completion handler uses a toggle.
        mapView.alpha = 0.5
        
        toggleUI()
        retrieveLocations()
    }
    
    @IBAction func postLocation(_ sender: AnyObject) {
    }
    
    // MARK: - Mapview delegate methods
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseIndentifier = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIndentifier) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseIndentifier)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor(red: 1.0, green: 158/255.0, blue: 0.0, alpha: 1.0)
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            var urlString = view.annotation!.subtitle!!

            if !urlString.hasPrefix("http") {
                urlString = "http://\(urlString)"
            }
            
            guard let url = URL(string: urlString), app.canOpenURL(url) else {
                showAlert("", message: "Invalid URL")
                return
            }

            app.openURL(url)
        }
    }
    
    // MARK: - Helper methods
    
    func retrieveLocations() {
        
        ParseClient.sharedInstance().getStudentLocations { (success, result, error) -> Void in
            
            // Check if there were any errors. i.e network
            guard (error == nil) else {
                self.finishLoading()
                self.showAlert("Load", message: error!.localizedDescription)
                return
            }
            
            if success {
                // Clear the previous pins
                let annotations = self.mapView.annotations
                self.mapView.removeAnnotations(annotations)
                
                // Place the pins on the map
                self.pinThePinsOnTheMap()
            }
            
            self.finishLoading()
        }
    }
    
    func pinThePinsOnTheMap() {        
        let students = AllStudentsInfo.sharedInstance().infos
        var annotations: [MKPointAnnotation]!
        if students.count > 0 {
            annotations = [MKPointAnnotation]()
        } else {
            return
        }

        for student in students {
            let annotation = MKPointAnnotation()
            annotation.coordinate = student.studentLocation.getCoordinates()
            annotation.title = "\(student.firstName) \(student.lastName)"
            annotation.subtitle = student.mediaURL
            
            annotations.append(annotation)
        }
        
        mapView.addAnnotations(annotations)
    }
    
    func toggleUI() {
        activityIndicator.isAnimating ? self.activityIndicator.stopAnimating(): self.activityIndicator.startAnimating()
        
        // enable/disable controls
        refreshButton.isEnabled = !refreshButton.isEnabled
        logoutButton.isEnabled = !logoutButton.isEnabled
        postLocationButton.isEnabled = !postLocationButton.isEnabled
        
        tabBarController!.tabBar.isUserInteractionEnabled = !tabBarController!.tabBar.isUserInteractionEnabled
        view.isUserInteractionEnabled = !view.isUserInteractionEnabled
    }
    
    // Allow the map to be ungreyed out.
    func finishLoading() {
        UIView.animate(withDuration: 1.0, animations: { () -> Void in
            self.mapView.alpha = 1.0
        }, completion: { _ in
            self.toggleUI()
        }) 
    }
    
    func showAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
}
