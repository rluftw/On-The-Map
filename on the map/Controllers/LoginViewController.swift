//
//  LoginViewController.swift
//  on the map
//
//  Created by Xing Hui Lu on 2/10/16.
//  Copyright © 2016 Xing Hui Lu. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    let client = UdacityClient.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func login(sender: AnyObject) {
        client.loginWithUserName("username", password: "password")
    }
    
    @IBAction func logout(sender: AnyObject) {
        client.logout()
    }
    
    @IBAction func getUserData(sender: AnyObject) {
        client.getUserPublicData()
    }

}
