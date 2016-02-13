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
    func getStudentLocations(completionHandler: ((success: Bool, result: AnyObject!, error: NSError?) -> Void)) {
        taskForGetMethod(Methods.StudentLocation, parameters: nil) { (success, result, error) -> Void in
            // Check for any errors first
            guard (error == nil) else {
                return
            }
            
            // Make sure this request was successful before parsing the result
            if success {
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.students = [StudentInfo]()
                
                self.prepareResults(result)
            }
            
            self.executeCompletionHandler(success, result: result, error: error, completionHandler: completionHandler)
            
            // Do other stuff like print the result
            print(result)
        }
    }
    
    func postStudentLocation(completionHandler: ((success: Bool, result: AnyObject!, error: NSError?) -> Void)) {
        

    }
    
    // MARK: - Helper methods
    func executeCompletionHandler(success: Bool, result: AnyObject!, error: NSError?, completionHandler: ((success: Bool, result: AnyObject!, error: NSError?) -> Void)) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            completionHandler(success: success, result: result, error: error)
        })
    }
    
    func prepareResults(responseDict: AnyObject) {
        // Result is an array of students
        guard let results = responseDict["results"] as? [AnyObject] else {
            return
        }
        
        results.forEach { (student) -> () in
            let studentObj = StudentInfo(studentDict: student)
            (UIApplication.sharedApplication().delegate as! AppDelegate).students.append(studentObj)
        }
    }
}