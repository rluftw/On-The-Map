//
//  ParseConvenience.swift
//  on the map
//
//  Created by Xing Hui Lu on 2/11/16.
//  Copyright © 2016 Xing Hui Lu. All rights reserved.
//

import Foundation

extension ParseClient {
    func getStudentLocations() {
        taskForGetMethod(Methods.StudentLocation, parameters: nil) { (result, error) -> Void in
            // Check for any errors first
            guard (error == nil) else {
                return
            }
            
            // Do other stuff like print the result
            print(result)
        }
    }
}