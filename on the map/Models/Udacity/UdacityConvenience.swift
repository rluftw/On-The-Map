//
//  UdacityConvenience.swift
//  on the map
//
//  Created by Xing Hui Lu on 2/10/16.
//  Copyright © 2016 Xing Hui Lu. All rights reserved.
//

import Foundation
import UIKit

// Convenience methods for Udacity API
extension UdacityClient {
    // MARK - Authentication
    
    func login(_ token: String = "", username: String = "", password: String = "", completionHandler: @escaping ((_ success: Bool, _ result: AnyObject?, _ error: NSError?) -> Void)) {
        
        var jsonBody: [String: AnyObject]!
        
        // If there's no facebook token, use regular login
        if token == "" {
            let userinfo : [String: String] =  [JSONBodyKeys.Username : username, JSONBodyKeys.Password : password]
            jsonBody = [JSONBodyKeys.Domain: userinfo as AnyObject]
        } else {
            let accessTokenDict: [String: String] = [JSONBodyKeys.AccessToken: token]
            jsonBody = [JSONBodyKeys.FacebookMobile: accessTokenDict as AnyObject]
        }

        // Call the task to be performed
        taskForPOSTMethod(Methods.Session, jsonBody: jsonBody) { (success, result, error) -> Void in
            // Check for any errors first
            guard (error == nil) else {
                self.executeCompletionHandler(success, result: result, error: error, completionHandler: completionHandler)
                return
            }
        
            if !success {
                self.executeCompletionHandler(success, result: result, error: error, completionHandler: completionHandler)
                return
            }
            
            // Store ID
            if let account = result?[JSONResponseKeys.Account] as? [String: AnyObject] {
                StudentInfoResponse.SessionID = account[JSONResponseKeys.AccountKey] as! String
            }
            
            // Do other stuff like print the result
            print(result)
            
            self.executeCompletionHandler(success, result: result, error: error, completionHandler: completionHandler)
        }
    }
    
    func logout(_ completionHandler: @escaping ((_ success: Bool, _ result: AnyObject?, _ error: NSError?) -> Void)) {
        taskForDELETEMethod(Methods.Session) { (success, result, error) -> Void in
            
            // Check for any errors first
            guard (error == nil) else {
                self.executeCompletionHandler(success, result: result, error: error, completionHandler: completionHandler)
                return
            }
            
            // Do other stuff like print the result
            print(result)
            
            StudentInfoResponse.SessionID = ""
            StudentInfoResponse.FirstName = ""
            StudentInfoResponse.LastName = ""
    
            // Log out current facebook session.
            
            if (UIApplication.shared.delegate as! AppDelegate).loginManager != nil {
                (UIApplication.shared.delegate as! AppDelegate).loginManager.logOut()
                (UIApplication.shared.delegate as! AppDelegate).loginManager = nil
            }
            
            self.executeCompletionHandler(success, result: result, error: error, completionHandler: completionHandler)
        }
    }
    
    func getUserPublicData(_ completionHandler: @escaping ((_ success: Bool, _ result: AnyObject?, _ error: NSError?) -> Void)) {
        let method = replacePlaceHolderInMethod(Methods.UserData, withKey: URLKeys.UserID, value: StudentInfoResponse.SessionID)
    
        taskForGETRequest(method) { (success, result, error) -> Void in
            
            // Check for any errors first
            guard (error == nil) else {
                self.executeCompletionHandler(success, result: result, error: error, completionHandler: completionHandler)
                return
            }
            
            // Store first name and last name
            if let account = result?[JSONResponseKeys.User] as? [String: AnyObject] {
                StudentInfoResponse.FirstName = account[JSONResponseKeys.FirstName] as! String
                StudentInfoResponse.LastName = account[JSONResponseKeys.LastName] as! String
            }
            
            self.executeCompletionHandler(success, result: result, error: error, completionHandler: completionHandler)
        }
    }
    
    // MARK: - Helper methods
    
    func executeCompletionHandler(_ success: Bool, result: AnyObject!, error: NSError? ,completionHandler: @escaping ((_ success: Bool, _ result: AnyObject?, _ error: NSError?) -> Void)) {
        DispatchQueue.main.async(execute: { () -> Void in
            completionHandler(success, result, error)
        })
    }
}
