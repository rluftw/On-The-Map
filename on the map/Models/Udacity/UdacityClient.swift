//
//  File.swift
//  on the map
//
//  Created by Xing Hui Lu on 2/10/16.
//  Copyright © 2016 Xing Hui Lu. All rights reserved.
//

import Foundation

class UdacityClient {
    let session: NSURLSession
    var userID: String!
    
    init() {
        session = NSURLSession.sharedSession()
    }
    
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static let sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
}


// NOTE: The Udacity API's does not use any parameters
extension UdacityClient {
    // MARK: - HTTP Request
    
    // The Udacity login API uses the POST HTTP method which takes a jsonBody and a method
    func taskForPOSTMethod(method: String, jsonBody: [String: AnyObject], postRequestCompletionHandler: (success: Bool, result: AnyObject!, error: NSError?) -> Void) {

        // Create the Request object
        let request = NSMutableURLRequest(URL: udacityURLWithMethod(method))
        request.HTTPMethod = "POST"
        request.addValue(DataFormat.JSON, forHTTPHeaderField: HTTPHeaderField.Accept)
        request.addValue(DataFormat.JSON, forHTTPHeaderField: HTTPHeaderField.ContentType)
        
        do {
            request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(jsonBody, options: .PrettyPrinted)
        }
        
        // Build the task
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                postRequestCompletionHandler(success: false, result: nil, error: NSError(domain: "taskForPOSTMethod", code: 1, userInfo: userInfo))
            }
            
            // Check if there's an error
            guard error == nil else {
                sendError(error!.localizedDescription)
                return
            }
            
            if let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 400 && statusCode <= 499 {
                sendError("Invalid Email or Password")
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
            self.parseJSONWithCompletionHandler(data, completionHandler: postRequestCompletionHandler)
        }
        
        // Start the task
        task.resume()
    }
    

    // The Udacity logout API uses the DELETE http method which takes only a method
    func taskForDELETEMethod(method: String, deleteRequestCompletionHandler: (success: Bool, result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        // Create the Request object
        let request = NSMutableURLRequest(URL: udacityURLWithMethod(method))
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
                deleteRequestCompletionHandler(success: false, result: nil, error: NSError(domain: "taskForDELETEMethod", code: 1, userInfo: userInfo))
            }

            
            // Check if there's an error
            guard error == nil else {
                sendError(error!.localizedDescription)
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
            self.parseJSONWithCompletionHandler(data, completionHandler: deleteRequestCompletionHandler)
        }
        
        // Start the task
        task.resume()
        
        return task
    }
    
    // The Udacity logout API uses the GET http method which takes only a method (the method may need substitution)
    func taskForGETRequest(method: String, getRequestCompletionHandler: (success: Bool, result: AnyObject!, error: NSError?) -> Void) {
        
        // Create the Request object
        let request = NSMutableURLRequest(URL: udacityURLWithMethod(replacePlaceHolderInMethod(Methods.UserData, withKey: URLKeys.UserID, value: userID)))
        
        print(request)
        
        // Build the task
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                getRequestCompletionHandler(success: false, result: nil, error: NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            
            // Check if there's an error
            guard error == nil else {
                sendError(error!.localizedDescription)
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
            self.parseJSONWithCompletionHandler(data, completionHandler: getRequestCompletionHandler)
        }
        
        task.resume()
    }
    
    // MARK: - Helper methods
    
    // None of the API takes in parameters, therefore the 'parameters' parameter is omitted
    func udacityURLWithMethod(method: String?) -> NSURL {
        let components = NSURLComponents()
        components.scheme = Constants.Scheme
        components.host = Constants.Host
        components.path = Constants.Path + (method ?? "")
        
        return components.URL!
    }
    
    func parseJSONWithCompletionHandler(data: NSData, completionHandler: (success: Bool, result: AnyObject!, error: NSError?) -> Void) {
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
            completionHandler(success: false, result: nil, error: NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
        }
                
        completionHandler(success: true, result: parsedResults, error: nil)
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
    
    func postNotification(notificationName: String) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName(notificationName, object: nil, userInfo: nil)
        })
    }
}



