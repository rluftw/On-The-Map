//
//  File.swift
//  on the map
//
//  Created by Xing Hui Lu on 2/10/16.
//  Copyright © 2016 Xing Hui Lu. All rights reserved.
//

import Foundation

class UdacityClient {
    let session = NSURLSession.sharedSession()
    var userID: String!
    
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static let sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
}


// NOTE: The Udacity API's does not use any parameters
extension UdacityClient {
    // MARK: - Authentication
    
    /*
        The Udacity API POST method takes the following:
        

    
        1. Method name - /session
        2. HTTPBody structured as JSON
    
        Current methods that uses POST request: /session
    */
    func taskForPOSTMethod(method: String, jsonBody: String, postRequestCompletionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        // Create the Request object
        let request = NSMutableURLRequest(URL: udacityURLForParameters(method))
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)
        
        
        // Build the task
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                postRequestCompletionHandler(result: nil, error: NSError(domain: "taskForPOSTMethod", code: 1, userInfo: userInfo))
            }
            
            // Check if there's an error
            guard error == nil else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            // Check for a valid response type (2XX)
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode <= 299 && statusCode >= 200 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            // Check for data
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            // Work with the data
            self.convertDataWithCompletionHandler(data, completionHandler: postRequestCompletionHandler)
        }
        
        // Start the task
        task.resume()
    }
    
    /*
        The Udacity API DELETE method takes the following:
        
        1. Method name - /session
    
        Current methods that uses POST request: /session
    */

    func taskForDELETEMethod(method: String, deleteRequestCompletionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        // Create the Request object
        let request = NSMutableURLRequest(URL: udacityURLForParameters(method))
        request.HTTPMethod = "DELETE"
        
        // Retrieve the shared cookie storage instance.
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        
        // Get all the cookies (mmm... yum cookies) and find the index of the "XSRF-TOKEN" token
        let cookies = sharedCookieStorage.cookies!
        var xsrfCookie: NSHTTPCookie?
        if let xsrfCookieIndex = cookies.indexOf({ (cookie) -> Bool in cookie.name == "XSRF-TOKEN" }) {
            xsrfCookie = cookies[xsrfCookieIndex]
            
            // If the XSRF-TOKEN cookie is found, then add it onto the request
            request.addValue(xsrfCookie!.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        // Build the task
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                deleteRequestCompletionHandler(result: nil, error: NSError(domain: "taskForDELETEMethod", code: 1, userInfo: userInfo))
            }

            
            // Check if there's an error
            guard error == nil else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            // Check for a valid response type (2XX)
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode <= 299 && statusCode >= 200 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            // Check for data
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            // Work with the data
            self.convertDataWithCompletionHandler(data, completionHandler: deleteRequestCompletionHandler)
        }
        
        // Start the task
        task.resume()
        
        return task
    }
    
    /*
        The Udacity API GET method takes the following:
    
        1. Method name - /users/<user_id>
        
        Current methods that uses GET request: /users/<user_id>
    */
 
    func taskForGETRequest(method: String, getRequestCompletionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        // Create the Request object
        let request = NSMutableURLRequest(URL: udacityURLForParameters(replacePlaceHolderInMethod(Methods.UserData, withKey: URLKeys.UserID, value: userID)))
        
        // Build the task
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                getRequestCompletionHandler(result: nil, error: NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            
            // Check if there's an error
            guard error == nil else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            // Check for a valid response type (2XX)
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode <= 299 && statusCode >= 200 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            // Check for data
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            // Work with the data
            self.convertDataWithCompletionHandler(data, completionHandler: getRequestCompletionHandler)
        }
        
        task.resume()
    }
    
    // MARK: - Helper methods
    
    func udacityURLForParameters(method: String?) -> NSURL {
        let components = NSURLComponents()
        components.scheme = Constants.Scheme
        components.host = Constants.Host
        components.path = Constants.Path + (method ?? "")
        
        print(components.URL!)
        
        return components.URL!
    }
    
    func convertDataWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        var parsedResults: AnyObject!
        do {
            /*
            All responses from Udacity API skips 5 characters of response
            This is for security purposes
            */
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            parsedResults = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandler(result: nil, error: NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandler(result: parsedResults, error: nil)
    }
    
    // Used for replacing placeholders in methods
    // i.e. user data method - /users/<user_id>
    func replacePlaceHolderInMethod(method: String, withKey key: String, value: String) -> String {
        guard let range = method.rangeOfString("<\(key)>") else {
            print("<\(key)> was not found")
            return method
        }
        
        return method.stringByReplacingCharactersInRange(range, withString: value)
    }

}



