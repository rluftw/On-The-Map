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
        return AllStudentsInfo.sharedInstance().infos
    }
    
    // MARK: - Viewcontroller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableViewRefreshControl.addTarget(self, action: #selector(StudentLocationTableViewController.refresh), for: .valueChanged)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.backgroundColor = UIColor(patternImage: UIImage(named: "wov")!)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refresh()
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentLocation", for: indexPath) as! StudentLocationCell
        let student = students[indexPath.row]
        
        cell.fullNameLabel.text = "\(student.firstName) \(student.lastName)"
        cell.mediaURLLabel.text = "\(student.mediaURL)"
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let app = UIApplication.shared
        let studentsInfo = AllStudentsInfo.sharedInstance().infos
        let info = studentsInfo[indexPath.row]
        var urlString = info.mediaURL
        
        if !urlString.hasPrefix("http") {
            urlString = "http://\(urlString)"
        }
        
        guard let url = URL(string: urlString), app.canOpenURL(url) else {
            showAlert("", message: "Invalid URL")
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        app.openURL(url)
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

    @IBAction func postLocation(_ sender: AnyObject) {
        refreshControl?.beginRefreshing()
    }
    
    // MARK: - Selectors
    
    func refresh() {
        // Can't be placed onto toggle because the animation completion handler uses a toggle.
        tableView.alpha = 0.5
        
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
            
            if let refreshing = self.refreshControl?.isRefreshing, refreshing == true {
                self.refreshControl?.endRefreshing()
            }
            
            self.finishLoading()
        }
    }

    func finishLoading() {
        UIView.animate(withDuration: 1.0, animations: { () -> Void in
            self.tableView.alpha = 1.0
        }, completion: { _ in
            self.toggleUI()
        }) 
    }
    
    func toggleUI() {
        logoutButton.isEnabled = !logoutButton.isEnabled
        postLocationButton.isEnabled = !postLocationButton.isEnabled
        tabBarController!.tabBar.isUserInteractionEnabled = !tabBarController!.tabBar.isUserInteractionEnabled
        view.isUserInteractionEnabled = !view.isUserInteractionEnabled
        
        if logoutButton.isEnabled {
            tableViewRefreshControl.endRefreshing()
        }
    }
    
    func showAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }

}
