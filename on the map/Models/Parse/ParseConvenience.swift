//
//  ParseConvenience.swift
//  on the map
//
//  Created by Xing Hui Lu on 2/11/16.
//  Copyright © 2016 Xing Hui Lu. All rights reserved.
//

import Foundation
import UIKit

extension ParseClient {
    func getStudentLocations(_ completionHandler: @escaping ((_ success: Bool, _ result: Any?, _ error: NSError?) -> Void)) {
        
        // Always sort by the key updatedAt with a limit of 100 results
        let parameters = [
            ParameterKeys.Limit: 100,
            ParameterKeys.Order: "-updatedAt"
        ] as [String : Any]
        
        _ = taskForGetMethod(Methods.StudentLocation, parameters: parameters) { (success, result, error) -> Void in
            // Check for any errors first
            guard (error == nil) else {
                self.executeCompletionHandler(success, result: result, error: error, completionHandler: completionHandler)
                return
            }
            
            // Make sure this request was successful before parsing the result
            if success {
                AllStudentsInfo.sharedInstance().infos.removeAll()
                
                self.prepareResults(result as AnyObject)
            }
            
            self.executeCompletionHandler(success, result: result, error: error, completionHandler: completionHandler)
            
            // Do other stuff like print the result
            print(result)
        }
    }
    
    func postStudentLocation(_ jsonBody: [String: AnyObject], completionHandler: @escaping ((_ success: Bool, _ result: Any?, _ error: NSError?) -> Void)) {
        _ = taskForPostMethod(Methods.StudentLocation, jsonBody: jsonBody) { (success, result, error) -> Void in
            // Check for any errors first
            guard (error == nil) else {
                self.executeCompletionHandler(success, result: result, error: error, completionHandler: completionHandler)
                return
            }
            
            self.executeCompletionHandler(success, result: result, error: error, completionHandler: completionHandler)
        }
    }
    
    // MARK: - Helper methods
    func executeCompletionHandler(_ success: Bool, result: Any!, error: NSError?, completionHandler: @escaping ((_ success: Bool, _ result: Any?, _ error: NSError?) -> Void)) {
        DispatchQueue.main.async(execute: { () -> Void in
            completionHandler(success, result, error)
        })
    }
    
    func prepareResults(_ responseDict: AnyObject) {
        // Result is an array of students
        guard let results = responseDict["results"] as? [AnyObject] else {
            return
        }
        
        results.forEach { (student) -> () in
            let studentObj = StudentInfo(studentDict: student)
            AllStudentsInfo.sharedInstance().infos.append(studentObj)
        }
    }
}
