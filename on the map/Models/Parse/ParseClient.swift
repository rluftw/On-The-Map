//
//  ParseClient.swift
//  on the map
//
//  Created by Xing Hui Lu on 2/11/16.
//  Copyright © 2016 Xing Hui Lu. All rights reserved.
//

import Foundation

class ParseClient {
    let session: NSURLSession
    
    init() {
        session = NSURLSession.sharedSession()
    }

    class func sharedInstance() -> ParseClient {
        struct Singleton {
            static let parseClient = ParseClient()
        }
        return Singleton.parseClient
    }
}

extension ParseClient {
    // MARK: - HTTP Request
    
    // To gather student locations
    func taskForGetMethod(method: String, parameters:[String: AnyObject]?, getRequestCompletionHandler: (success: Bool, result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        // Make the parse request
        let request = NSMutableURLRequest(URL: parseURLWithMethod(method, parameters: parameters))
        request.addValue(Constants.ApplicationID, forHTTPHeaderField: ParseHTTPHeaderField.ApplicationID)
        request.addValue(Constants.APIKey, forHTTPHeaderField: ParseHTTPHeaderField.APIKey)
        
        // Build the task
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                getRequestCompletionHandler(success: false, result: nil, error: NSError(domain: "taskForGetMethod", code: 1, userInfo: userInfo))
            }
            
            // Check if there's an error
            guard error == nil else {
                sendError("There was an error with your request: \(error!.localizedDescription)")
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
            
            self.parseJSONWithCompletionHandler(data, completionHandler: getRequestCompletionHandler)
            self.postNotification("StudentInfoLoadComplete")
        }

        // Start the task
        task.resume()
        
        return task
    }
    
    // To post a student location
    func taskForPostMethod(method: String, jsonBody: [String: AnyObject], postRequestCompletionHandler: (success: Bool, result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        let request = NSMutableURLRequest(URL: parseURLWithMethod(method, parameters: nil))
        request.HTTPMethod = "POST"
        request.addValue(Constants.APIKey, forHTTPHeaderField: ParseHTTPHeaderField.APIKey)
        request.addValue(Constants.ApplicationID, forHTTPHeaderField: ParseHTTPHeaderField.ApplicationID)
        
        do {
            request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(jsonBody, options: .PrettyPrinted)
        }
        
        // Build the task
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                postRequestCompletionHandler(success: false, result: nil, error: NSError(domain: "taskForGetMethod", code: 1, userInfo: userInfo))
            }
            
            // Check if there's an error
            guard error == nil else {
                sendError("There was an error with your request: \(error!.localizedDescription)")
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
            
            self.parseJSONWithCompletionHandler(data, completionHandler: postRequestCompletionHandler)
        }
        
        task.resume()
        
        return task
    }
    
    
    // MARK: - Helper methods
    
    func parseURLWithMethod(method: String?, parameters: [String: AnyObject]?) -> NSURL {
        let components = NSURLComponents()
        components.scheme = Constants.Scheme
        components.host = Constants.Host
        components.path = Constants.Path + (method ?? "")
        
        // No parameters? return here.
        guard let parameters = parameters else {
            return components.URL!
        }
        
        components.queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.URL!
    }
    
    func parseJSONWithCompletionHandler(data: NSData, completionHandler: (success: Bool, result: AnyObject!, error: NSError?) -> Void) {
        var parsedResults: AnyObject!
        do {
            parsedResults = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandler(success: false, result: nil, error: NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandler(success: true, result: parsedResults, error: nil)
    }
    
    // Notify the controller that something has updated.
    func postNotification(notificationName: String) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName(notificationName, object: nil, userInfo: nil)
        })
    }
}