//
//  StudentInformation.swift
//  on the map
//
//  Created by Xing Hui Lu on 2/11/16.
//  Copyright © 2016 Xing Hui Lu. All rights reserved.
//

import Foundation

// Store individual locations and links downloaded from the service
struct StudentInfo {
    var dateCreated: String
    var objectID: String
    var uniqueKey: String
    var firstName: String
    var lastName: String
    var mapString: String
    var mediaURL: String
    var updatedAt: String
    var studentLocation: StudentLocation
    
    init(studentDict: AnyObject) {
        let studentDict = studentDict as! [String: AnyObject]
        
        let latitude = studentDict[StudentResponseKeys.Latitude] as! Double
        let longitude = studentDict[StudentResponseKeys.Longitude] as! Double
        
        // Initialize
        dateCreated = studentDict[StudentResponseKeys.CreatedAt] as! String
        firstName = studentDict[StudentResponseKeys.FirstName] as! String
        lastName = studentDict[StudentResponseKeys.LastName] as! String
        mapString = studentDict[StudentResponseKeys.MapString] as! String
        mediaURL = studentDict[StudentResponseKeys.MediaURL] as! String
        objectID = studentDict[StudentResponseKeys.ObjectId] as! String
        uniqueKey = studentDict[StudentResponseKeys.UniqueKey] as! String
        updatedAt = studentDict[StudentResponseKeys.MediaURL] as! String
        studentLocation = StudentLocation(latitude: latitude, longitude: longitude)
    }
}
