//
//  StudentLocationTableViewController.swift
//  on the map
//
//  Created by Xing Hui Lu on 2/11/16.
//  Copyright © 2016 Xing Hui Lu. All rights reserved.
//

import UIKit
import MapKit

class StudentLocationTableViewController: UITableViewController {
    
    @IBOutlet weak var tableViewRefreshControl: UIRefreshControl!
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var postLocationButton: UIBarButtonItem!
    
    var students: [StudentInfo] {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).students
    }
    
    // MARK: - Viewcontroller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableViewRefreshControl.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.backgroundColor = UIColor(patternImage: UIImage(named: "wov")!)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        refresh()
    }
    
    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("studentLocation", forIndexPath: indexPath) as! StudentLocationCell
        let student = students[indexPath.row]
        
        cell.fullNameLabel.text = "\(student.firstName) \(student.lastName)"
        cell.mediaURLLabel.text = "\(student.mediaURL)"
        
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let app = UIApplication.sharedApplication()
        let students = (app.delegate as! AppDelegate).students
        let student = students[indexPath.row]
        var urlString = student.mediaURL
        
        if !urlString.hasPrefix("http") {
            urlString = "http://\(urlString)"
        }
        
        guard let url = NSURL(string: urlString) where app.canOpenURL(url) else {
            showAlert("", message: "Invalid URL")
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            return
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        app.openURL(url)
    }
    
    // MARK: - IBAction methods

    @IBAction func logout(sender: AnyObject) {
        toggleUI()
        
        UdacityClient.sharedInstance().logout { (success, result, error) -> Void in
            
            // Check if there were any errors. i.e network
            guard (error == nil) else {
                self.showAlert("Logout", message: error!.localizedDescription)
                return
            }
            
            if success {
                // Clear the students array and dismiss
                (UIApplication.sharedApplication().delegate as! AppDelegate).students = [StudentInfo]()
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            
            self.toggleUI()
        }
    }

    @IBAction func postLocation(sender: AnyObject) {
        refreshControl?.beginRefreshing()
    }
    
    // MARK: - Selectors
    
    func refresh() {
        toggleUI()
        retrieveLocations()
    }
    
    // MARK: - Helper methods
    
    func retrieveLocations() {
        ParseClient.sharedInstance().getStudentLocations { (success, result, error) -> Void in
            
            // Check if there were any errors. i.e network
            guard (error == nil) else {
                self.finishLoading()
                self.showAlert("Refresh", message: error!.localizedDescription)
                return
            }
            
            if success {
                self.tableView.reloadData()
            }
            
            if let refreshing = self.refreshControl?.refreshing where refreshing == true {
                self.refreshControl?.endRefreshing()
            }
            
            self.finishLoading()
        }
    }

    func finishLoading() {
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            self.tableView.alpha = 1.0
        }) { _ in
            self.toggleUI()
        }
    }
    
    func toggleUI() {
        logoutButton.enabled = !logoutButton.enabled
        postLocationButton.enabled = !postLocationButton.enabled
        tabBarController!.tabBar.userInteractionEnabled = !tabBarController!.tabBar.userInteractionEnabled
        view.userInteractionEnabled = !view.userInteractionEnabled
        
        if logoutButton.enabled {
            tableViewRefreshControl.endRefreshing()
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        
        presentViewController(alert, animated: true, completion: nil)
    }

}
