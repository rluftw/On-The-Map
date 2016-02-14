//
//  LoginViewController.swift
//  on the map
//
//  Created by Xing Hui Lu on 2/10/16.
//  Copyright © 2016 Xing Hui Lu. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var facebookLoginButton: UIButton!

    // MARK: - Viewcontroller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        
        facebookLoginButton.addTarget(self, action: "loginWithFB", forControlEvents: .TouchUpInside)
    }
    
    // MARK: - Textfield Delegates
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    // MARK: - IBAction methods
    
    @IBAction func login(sender: UIButton) {
        view.endEditing(true)
        
        if usernameTextField.text == "" || passwordTextField.text == "" {
            showAlert("Login", message: "Please login with your Udacity credentials")
        } else {
            toggleUI()

            UdacityClient.sharedInstance().login(username: usernameTextField.text!, password: passwordTextField.text!, completionHandler: { (success, result, error) -> Void in
                
                
                // If successful, gather the public user data (REQUIRED FOR POSTING)
                if success {
                    self.getUserPublicData()
                } else {
                    self.showAlert("Login", message: error!.localizedDescription)
                    self.toggleUI()
                    return
                }
            })
        }
    }
    
    // MARK: - Selectors
    
    func loginWithFB() {
        view.endEditing(true)
        
        toggleUI()
        
        (UIApplication.sharedApplication().delegate as! AppDelegate).loginManager = FBSDKLoginManager()
        let loginManager = (UIApplication.sharedApplication().delegate as! AppDelegate).loginManager

        loginManager.logInWithReadPermissions(["public_profile"], fromViewController: self) { (result, error) -> Void in
            guard error == nil else {
                print("Process error, \(error.localizedDescription)")
                self.toggleUI()
                return
            }
            
            if result.isCancelled {
                self.showAlert("Login", message: "Facebook authorization failed")
                self.toggleUI()
            } else {
                let tokenString = result.token.tokenString
                UdacityClient.sharedInstance().login(tokenString, completionHandler: { (success, result, error) -> Void in
                    if success {
                        self.getUserPublicData()
                    } else {
                        self.showAlert("Login", message: error!.localizedDescription)
                        self.toggleUI()
                        return
                    }
                })
            }
        }
    }
    
    // MARK: - Helper methods
    
    // No helper methods are suppose to be toggling, the only exception is this one!
    func getUserPublicData() {
        UdacityClient.sharedInstance().getUserPublicData({ (success, result, error) -> Void in
            if success {
                self.toggleUI()
                let tabBarController = self.storyboard?.instantiateViewControllerWithIdentifier("MapAndTableView") as! UITabBarController
                self.presentViewController(tabBarController, animated: true, completion: nil)
            } else {
                self.toggleUI()
                self.showAlert("Login", message: error!.localizedDescription)
                return
            }
        })
    }
    
    func toggleUI() {
        activityIndicator.isAnimating() ? activityIndicator.stopAnimating(): activityIndicator.startAnimating()
        loginButton.enabled = !loginButton.enabled
        usernameTextField.enabled = !usernameTextField.enabled
        passwordTextField.enabled = !passwordTextField.enabled
        facebookLoginButton.enabled = !facebookLoginButton.enabled
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        
        presentViewController(alert, animated: true, completion: nil)
    }
}
