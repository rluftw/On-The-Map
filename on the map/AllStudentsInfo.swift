//
//  AllStudentsInfo.swift
//  on the map
//
//  Created by Xing Hui Lu on 2/14/16.
//  Copyright © 2016 Xing Hui Lu. All rights reserved.
//

import Foundation

class AllStudentsInfo {
    var infos = [StudentInfo]()
    
    class func sharedInstance() -> AllStudentsInfo {
        struct Singleton {
            static let allStudents = AllStudentsInfo()
        }
        return Singleton.allStudents
    }
}