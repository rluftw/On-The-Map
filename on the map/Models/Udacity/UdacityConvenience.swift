//
//  UdacityConvenience.swift
//  on the map
//
//  Created by Xing Hui Lu on 2/10/16.
//  Copyright © 2016 Xing Hui Lu. All rights reserved.
//

import Foundation

// Convenience methods for Udacity API
extension UdacityClient {
    // MARK - Authentication
    
    func loginWithUserName(username: String, password: String, completionHandler: ((success: Bool, result: AnyObject!, error: NSError?) -> Void)) {
        
        // Create the JSON for the HTTP body
        let userinfo : [String: String] =  [JSONBodyKeys.Username : username, JSONBodyKeys.Password : password]
        let jsonBody : [String: AnyObject] = [JSONBodyKeys.Domain: userinfo]

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
            if let account = result[JSONResponseKeys.Account] as? [String: AnyObject] {
                self.userID = account[JSONResponseKeys.AccountKey] as? String
            }
            
            // Do other stuff like print the result
            print(result)
            
            self.executeCompletionHandler(success, result: result, error: error, completionHandler: completionHandler)
        }
    }
    
    func logout(completionHandler: ((success: Bool, result: AnyObject!, error: NSError?) -> Void)) {
        taskForDELETEMethod(Methods.Session) { (success, result, error) -> Void in
            
            // Check for any errors first
            guard (error == nil) else {
                self.executeCompletionHandler(success, result: result, error: error, completionHandler: completionHandler)
                return
            }
            
            // Do other stuff like print the result
            print(result)
            
            self.userID = nil
            self.executeCompletionHandler(success, result: result, error: error, completionHandler: completionHandler)
        }
    }
    
    func getUserPublicData(completionHandler: ((success: Bool, result: AnyObject!, error: NSError?) -> Void)) {
        let method = replacePlaceHolderInMethod(Methods.UserData, withKey: URLKeys.UserID, value: userID!)
    
        taskForGETRequest(method) { (success, result, error) -> Void in
            
            // Check for any errors first
            guard (error == nil) else {
                self.executeCompletionHandler(success, result: result, error: error, completionHandler: completionHandler)
                return
            }
            
            // Do other stuff like print the result
            print(result)
            
            self.executeCompletionHandler(success, result: result, error: error, completionHandler: completionHandler)
        }
    }
    
    // MARK: - Helper methods
    
    func executeCompletionHandler(success: Bool, result: AnyObject!, error: NSError? ,completionHandler: ((success: Bool, result: AnyObject!, error: NSError?) -> Void)) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            completionHandler(success: success, result: result, error: error)
        })
    }
}