//
//  MapViewController.swift
//  on the map
//
//  Created by Xing Hui Lu on 2/11/16.
//  Copyright © 2016 Xing Hui Lu. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    var client = ParseClient.sharedInstance()
    
    // TODO: Model placed here
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Viewcontroller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.startAnimating()
        client.getStudentLocations()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadCompletionHandler:", name: "StudentInfoLoadComplete", object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "StudentInfoLoadComplete", object: nil)
    }
    
    // MARK: - IBAction methods
    
    @IBAction func logout(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func refresh(sender: AnyObject) {
    }
    
    @IBAction func postLocation(sender: AnyObject) {
    }
    
    // MARK: - Selector methods
    
    func loadCompletionHandler(notification: NSNotification) {
        finishLoading()
    }
    
    // MARK: - Helper methods
    
    // Allow the map to be ungreyed out.
    func finishLoading() {
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            self.mapView.alpha = 1.0
        }) { _ in
            self.activityIndicator.stopAnimating()
        }
    }
}
