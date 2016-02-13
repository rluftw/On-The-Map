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
    

    
    // MARK: - Viewcontroller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
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

            UdacityClient.sharedInstance().loginWithUserName(usernameTextField.text!, password: passwordTextField.text!, completionHandler: { (success, result, error) -> Void in
                
                if success {
                    let tabBarController = self.storyboard?.instantiateViewControllerWithIdentifier("MapAndTableView") as! UITabBarController
                    self.presentViewController(tabBarController, animated: true, completion: nil)
                } else {
                    self.showAlert("Login", message: error!.localizedDescription)
                    return
                }
                
                self.toggleUI()
            })
        }
    }
    
    // MARK: - Helper methods
    
    func toggleUI() {
        activityIndicator.isAnimating() ? activityIndicator.stopAnimating(): activityIndicator.startAnimating()
        loginButton.enabled = !loginButton.enabled
        usernameTextField.enabled = !usernameTextField.enabled
        passwordTextField.enabled = !passwordTextField.enabled
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        toggleUI()
        
        presentViewController(alert, animated: true, completion: nil)
    }
}
