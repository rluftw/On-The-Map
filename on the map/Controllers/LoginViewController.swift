//
//  LoginViewController.swift
//  on the map
//
//  Created by Xing Hui Lu on 2/10/16.
//  Copyright © 2016 Xing Hui Lu. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let client = UdacityClient.sharedInstance()
    
    // MARK: - Viewcontroller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "completeLogin:", name: "CompleteLogin", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "networkFailureHandler:", name: "NetworkFailure", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "credentialFailureHandler:", name: "CredentialFailure", object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "CompleteLogin", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "NetworkFailure", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "CredentialFailure", object: nil)
    }
    
    // MARK: - Textfield Delegates
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    // MARK: - Login methods
    
    @IBAction func login(sender: UIButton) {
        view.endEditing(true)
        
        if usernameTextField.text == "" || passwordTextField.text == "" {
            
            // Alert the user and prompt for a username and password
            let alert = UIAlertController(title: "Login", message: "Please login with your Udacity Credentials", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
            
            presentViewController(alert, animated: true, completion: nil)
        } else {
            toggleUI()
            client.loginWithUserName(usernameTextField.text!, password: passwordTextField.text!) {
                self.toggleUI()
            }
        }
    }
    
    // MARK: - Selector methods
    
    func networkFailureHandler(notification: NSNotification) {
        let alert = UIAlertController(title: "Network Error", message: "Please check your network connection.", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func credentialFailureHandler(notification: NSNotification) {
        let alert = UIAlertController(title: "Invalid Email or Password", message: "", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func completeLogin(notification: NSNotification) {
        let mapAndTableView = self.storyboard!.instantiateViewControllerWithIdentifier("MapAndTableView")
        self.presentViewController(mapAndTableView, animated: true, completion: nil)
    }
    
    // MARK: - Helper methods
    
    func toggleUI() {
        activityIndicator.isAnimating() ? activityIndicator.stopAnimating(): activityIndicator.startAnimating()
        loginButton.enabled = !loginButton.enabled
        usernameTextField.enabled = !usernameTextField.enabled
        passwordTextField.enabled = !passwordTextField.enabled
    }
}
