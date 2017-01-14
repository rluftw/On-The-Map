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
        
        facebookLoginButton.addTarget(self, action: #selector(LoginViewController.loginWithFB), for: .touchUpInside)
    }
    
    // MARK: - Textfield Delegates
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    // MARK: - IBAction methods
    
    @IBAction func login(_ sender: UIButton) {
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
        
        (UIApplication.shared.delegate as! AppDelegate).loginManager = FBSDKLoginManager()
        let loginManager = (UIApplication.shared.delegate as! AppDelegate).loginManager

        loginManager?.logIn(withReadPermissions: ["public_profile"], from: self) { (result, error) -> Void in
            guard error == nil else {
                print("Process error, \(error?.localizedDescription)")
                self.toggleUI()
                return
            }
            
            if (result?.isCancelled)! {
                self.showAlert("Login", message: "Facebook authorization failed")
                self.toggleUI()
            } else {
                let tokenString = result?.token.tokenString ?? ""
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
                let tabBarController = self.storyboard?.instantiateViewController(withIdentifier: "MapAndTableView") as! UITabBarController
                self.present(tabBarController, animated: true, completion: nil)
            } else {
                self.toggleUI()
                self.showAlert("Login", message: error!.localizedDescription)
                return
            }
        })
    }
    
    func toggleUI() {
        activityIndicator.isAnimating ? activityIndicator.stopAnimating(): activityIndicator.startAnimating()
        loginButton.isEnabled = !loginButton.isEnabled
        usernameTextField.isEnabled = !usernameTextField.isEnabled
        passwordTextField.isEnabled = !passwordTextField.isEnabled
        facebookLoginButton.isEnabled = !facebookLoginButton.isEnabled
    }
    
    func showAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
}
