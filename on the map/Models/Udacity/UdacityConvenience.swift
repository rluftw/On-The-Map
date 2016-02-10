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
    func loginWithUserName(username: String, password: String) {
        // Create the JSON for the HTTP body
        let jsonBody = "{\(JSONBodyKeys.Udacity): {\(JSONBodyKeys.Username): \(username), \(JSONBodyKeys.Password): \(password)}}"
        
        // Call the task to be performed
        taskForPOSTMethod(Methods.Session, jsonBody: jsonBody) { (result, error) -> Void in
            
            // Check for any errors first
            guard (error == nil) else {
                return
            }
            
            // Store ID
            let result = result as! [String: AnyObject]
            let account = result["account"] as! [String: AnyObject]
            self.userID = account["key"] as! String
            
            // Do other stuff like print the result
            
            print(result)
        }
    }
    
    func logout() {
        taskForDELETEMethod(Methods.Session) { (result, error) -> Void in
            
            // Check for any errors first
            guard (error == nil) else {
                return
            }
            
            // Do stuff like print the result
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
            
            // Do stuff like print the result
            print(result)
        }
    }
}