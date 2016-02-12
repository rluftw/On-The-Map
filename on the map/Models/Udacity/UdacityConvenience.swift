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
    
    func loginWithUserName(username: String, password: String, completionHandler: (() -> Void)) {
        
        // Create the JSON for the HTTP body
        let userinfo : [String: String] =  [JSONBodyKeys.Username : username, JSONBodyKeys.Password : password]
        let jsonBody : [String: AnyObject] = [JSONBodyKeys.Domain: userinfo]

        // Call the task to be performed
        taskForPOSTMethod(Methods.Session, jsonBody: jsonBody) { (result, error) -> Void in
            // Check for any errors first - probably means that there was no network
            guard (error == nil) else {
                self.completeLogin(completionHandler)
                return
            }
            
            // Store ID
            if let account = result[JSONResponseKeys.Account] as? [String: AnyObject] {
                self.userID = account[JSONResponseKeys.AccountKey] as? String
            }
            
            self.completeLogin(completionHandler)
        }
    }
    
    func logout() {
        taskForDELETEMethod(Methods.Session) { (result, error) -> Void in
            
            // Check for any errors first
            guard (error == nil) else {
                return
            }
            
            // Do other stuff like print the result
            print(result)
        }
    }
    
    func getUserPublicData() {
        let method = replacePlaceHolderInMethod(Methods.UserData, withKey: URLKeys.UserID, value: userID!)
    
        taskForGETRequest(method) { (result, error) -> Void in
            
            // Check for any errors first
            guard (error == nil) else {
                return
            }
            
            // Do other stuff like print the result
            print(result)
        }
    }
    
    // MARK: - Helper methods
    
    func completeLogin(completionHandler: (() -> Void)) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            completionHandler()
        })
    }
}