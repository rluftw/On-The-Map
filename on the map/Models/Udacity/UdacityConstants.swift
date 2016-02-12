//
//  UdacityConstants.swift
//  on the map
//
//  Created by Xing Hui Lu on 2/10/16.
//  Copyright © 2016 Xing Hui Lu. All rights reserved.
//

import Foundation

extension UdacityClient {
    struct Constants {
        static let Scheme = "https"
        static let Host = "www.udacity.com"
        static let Path = "/api"
    }
    
    struct Methods {
        static let Session = "/session"
        static let UserData = "/users/<user_id>"
    }
    
    struct URLKeys {
        static let UserID = "user_id"
    }
    
    struct JSONResponseKeys {
        static let Account = "account"
        static let Registered = "Registered"
        static let AccountKey = "key"
        static let Session = "session"
        static let ID = "id"
        static let expiration = "expiration"
    }
    
    struct JSONBodyKeys {
        static let Domain = "udacity"
        static let Username = "username"
        static let Password = "password"
    }
    
    struct DataFormat {
        static let JSON = "application/json"
    }
    
    struct HTTPHeaderField {
        static let Accept = "Accept"
        static let ContentType = "Content-Type"
    }
}