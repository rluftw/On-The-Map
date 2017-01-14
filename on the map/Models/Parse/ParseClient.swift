//
//  ParseClient.swift
//  on the map
//
//  Created by Xing Hui Lu on 2/11/16.
//  Copyright © 2016 Xing Hui Lu. All rights reserved.
//

import Foundation

class ParseClient {
    let session: URLSession!
    
    init() {
        session = URLSession.shared
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
    func taskForGetMethod(_ method: String, parameters:[String: Any]?, getRequestCompletionHandler: @escaping (_ success: Bool, _ result: Any?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        // Make the parse request
        var request = URLRequest(url: parseURLWithMethod(method, parameters: parameters))
        request.addValue(Constants.ApplicationID, forHTTPHeaderField: ParseHTTPHeaderField.ApplicationID)
        request.addValue(Constants.APIKey, forHTTPHeaderField: ParseHTTPHeaderField.APIKey)
        
        let mutableRequest = NSURLRequest()
        
        // Build the task
        let task = self.session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                getRequestCompletionHandler(false, nil, NSError(domain: "taskForGetMethod", code: 1, userInfo: userInfo))
            }
            
            // Check if there's an error
            guard error == nil else {
                sendError(error!.localizedDescription)
                return
            }
            
            // Check for a valid response type (2XX)
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode <= 299 && statusCode >= 200 else {
                print("Your request returned a status code other than 2xx! - \((response as! HTTPURLResponse).statusCode)")
                sendError("Failed to load")
                return
            }
            
            // Check for data
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            self.parseJSONWithCompletionHandler(data, completionHandler: getRequestCompletionHandler)
            self.postNotification("StudentInfoLoadComplete")
        }) 

        // Start the task
        task.resume()
        
        return task
    }
    
    // To post a student location
    func taskForPostMethod(_ method: String, jsonBody: [String: Any], postRequestCompletionHandler: @escaping (_ success: Bool, _ result: Any?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        var request = URLRequest(url: parseURLWithMethod(method, parameters: nil))
        request.httpMethod = "POST"
        request.addValue(Constants.APIKey, forHTTPHeaderField: ParseHTTPHeaderField.APIKey)
        request.addValue(Constants.ApplicationID, forHTTPHeaderField: ParseHTTPHeaderField.ApplicationID)
        
        do {
            request.httpBody = try? JSONSerialization.data(withJSONObject: jsonBody, options: .prettyPrinted)
        }
        
        // Build the task
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                postRequestCompletionHandler(false, nil, NSError(domain: "taskForGetMethod", code: 1, userInfo: userInfo))
            }
            
            // Check if there's an error
            guard error == nil else {
                sendError(error!.localizedDescription)
                return
            }
            
            // Check for a valid response type (2XX)
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode <= 299 && statusCode >= 200 else {
                print("Your request returned a status code other than 2xx!")
                sendError("Failed to post")
                return
            }
            
            // Check for data
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            self.parseJSONWithCompletionHandler(data, completionHandler: postRequestCompletionHandler)
        }) 
        
        task.resume()
        
        return task
    }
    
    
    // MARK: - Helper methods
    
    func parseURLWithMethod(_ method: String?, parameters: [String: Any]?) -> URL {
        var components = URLComponents()
        components.scheme = Constants.Scheme
        components.host = Constants.Host
        components.path = Constants.Path + (method ?? "")
        
        // No parameters? return here.
        guard let parameters = parameters else {
            return components.url!
        }
        
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    func parseJSONWithCompletionHandler(_ data: Data, completionHandler: (_ success: Bool, _ result: Any?, _ error: NSError?) -> Void) {
        var parsedResults: Any!
        do {
            parsedResults = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandler(false, nil, NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandler(true, parsedResults, nil)
    }
    
    // Notify the controller that something has updated.
    func postNotification(_ notificationName: String) {
        DispatchQueue.main.async(execute: { () -> Void in
            NotificationCenter.default.post(name: Notification.Name(rawValue: notificationName), object: nil, userInfo: nil)
        })
    }
}
