//
//  File.swift
//  on the map
//
//  Created by Xing Hui Lu on 2/10/16.
//  Copyright © 2016 Xing Hui Lu. All rights reserved.
//

import Foundation

class UdacityClient {
    let session: URLSession
//    var userID: String!
//    var firstName: String!
//    var lastName: String!
    
    init() {
        session = URLSession.shared
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
    func taskForPOSTMethod(_ method: String, jsonBody: [String: AnyObject], postRequestCompletionHandler: @escaping (_ success: Bool, _ result: AnyObject?, _ error: NSError?) -> Void) {

        // Create the Request object
        var request = URLRequest(url: udacityURLWithMethod(method))
        request.httpMethod = "POST"
        request.addValue(DataFormat.JSON, forHTTPHeaderField: HTTPHeaderField.Accept)
        request.addValue(DataFormat.JSON, forHTTPHeaderField: HTTPHeaderField.ContentType)
        
        do {
            request.httpBody = try? JSONSerialization.data(withJSONObject: jsonBody, options: .prettyPrinted)
        }
        
        // Build the task
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                postRequestCompletionHandler(false, nil, NSError(domain: "taskForPOSTMethod", code: 1, userInfo: userInfo))
            }
            
            // Check if there's an error
            guard error == nil else {
                sendError(error!.localizedDescription)
                return
            }
            
            if let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 400 && statusCode <= 499 {
                sendError("Invalid Email or Password")
                return
            }
            
            // Check for a valid response type (2XX)
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode <= 299 && statusCode >= 200 else {
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
        }) 
        
        // Start the task
        task.resume()
    }
    

    // The Udacity logout API uses the DELETE http method which takes only a method
    func taskForDELETEMethod(_ method: String, deleteRequestCompletionHandler: @escaping (_ success: Bool, _ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        // Create the Request object
        var request = URLRequest(url: udacityURLWithMethod(method))
        request.httpMethod = "DELETE"
        
        // Retrieve the shared cookie storage instance.
        let sharedCookieStorage = HTTPCookieStorage.shared
        
        // Get all the cookies (mmm... yum cookies) and find the index of the "XSRF-TOKEN" token
        let cookies = sharedCookieStorage.cookies!
        var xsrfCookie: HTTPCookie?
        if let xsrfCookieIndex = cookies.index(where: { (cookie) -> Bool in cookie.name == "XSRF-TOKEN" }) {
            xsrfCookie = cookies[xsrfCookieIndex]
            
            // If the XSRF-TOKEN cookie is found, then add it onto the request
            request.addValue(xsrfCookie!.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        // Build the task
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                deleteRequestCompletionHandler(false, nil, NSError(domain: "taskForDELETEMethod", code: 1, userInfo: userInfo))
            }

            
            // Check if there's an error
            guard error == nil else {
                sendError(error!.localizedDescription)
                return
            }
            
            // Check for a valid response type (2XX)
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode <= 299 && statusCode >= 200 else {
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
        }) 
        
        // Start the task
        task.resume()
        
        return task
    }
    
    // The Udacity logout API uses the GET http method which takes only a method (the method may need substitution)
    func taskForGETRequest(_ method: String, getRequestCompletionHandler: @escaping (_ success: Bool, _ result: AnyObject?, _ error: NSError?) -> Void) {
        
        // Create the Request object
        var request = URLRequest(url: udacityURLWithMethod(replacePlaceHolderInMethod(Methods.UserData, withKey: URLKeys.UserID, value: StudentInfoResponse.SessionID)))
        
        print(request)
        
        // Build the task
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                getRequestCompletionHandler(false, nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            // Check if there's an error
            guard error == nil else {
                sendError(error!.localizedDescription)
                return
            }
            
            // Check for a valid response type (2XX)
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode <= 299 && statusCode >= 200 else {
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
        }) 
        
        task.resume()
    }
    
    // MARK: - Helper methods
    
    // None of the API takes in parameters, therefore the 'parameters' parameter is omitted
    func udacityURLWithMethod(_ method: String?) -> URL {
        var components = URLComponents()
        components.scheme = Constants.Scheme
        components.host = Constants.Host
        components.path = Constants.Path + (method ?? "")
        
        return components.url!
    }
    
    func parseJSONWithCompletionHandler(_ data: Data, completionHandler: (_ success: Bool, _ result: AnyObject?, _ error: NSError?) -> Void) {
        var parsedResults: AnyObject!
        do {
            /*
                All responses from Udacity API skips 5 characters of response
                This is for security purposes
            */
            if let range = NSMakeRange(5, data.count - 5).toRange() {
                let newData = data.subdata(in: range)
                parsedResults = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as AnyObject!
            }
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandler(false, nil, NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
        }
                
        completionHandler(true, parsedResults, nil)
    }
    
    // Used for replacing placeholders in methods
    // i.e. user data method - /users/<user_id>
    func replacePlaceHolderInMethod(_ method: String, withKey key: String, value: String) -> String {
        guard let range = method.range(of: "<\(key)>") else {
            print("<\(key)> was not found")
            return method
        }
        
        return method.replacingCharacters(in: range, with: value)
    }
    
    func postNotification(_ notificationName: String) {
        DispatchQueue.main.async(execute: { () -> Void in
            NotificationCenter.default.post(name: Notification.Name(rawValue: notificationName), object: nil, userInfo: nil)
        })
    }
}



