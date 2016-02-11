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
        // NOTE: This is a very messy format, I've provided a cleaner way to approach this.
        let jsonBody = "{\"\(JSONBodyKeys.Domain)\": {\"\(JSONBodyKeys.Username)\": \"\(username)\", \"\(JSONBodyKeys.Password)\": \"\(password)\" }}"
        
        /*
            Using a dictionary to write the jsonBody (Cleaner)
            =================================================
        
            let userinfo : [String: String] =  [JSONBodyKeys.Username : username, JSONBodyKeys.Password : password]
            let jsonBody : [String: AnyObject] = [JSONBodyKeys.Domain: userinfo]
        */
        
        // Call the task to be performed
        taskForPOSTMethod(Methods.Session, jsonBody: jsonBody) { (result, error) -> Void in
            
            // Check for any errors first
            guard (error == nil) else {
                return
            }
            
            // Store ID
            if let account = result[JSONResponseKeys.Account] as? [String: AnyObject] {
                self.userID = account[JSONResponseKeys.AccountKey] as? String
            } else {
                //TODO: Do something if there's no Key!
            }
            
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