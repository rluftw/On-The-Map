//
//  ParseConstants.swift
//  on the map
//
//  Created by Xing Hui Lu on 2/11/16.
//  Copyright © 2016 Xing Hui Lu. All rights reserved.
//

import Foundation

extension ParseClient {
    struct Constants {
        static let ApplicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let APIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let Scheme = "https"
        static let Host = "api.parse.com"
        static let Path = "/1/classes"
    }
    
    struct Methods {
        static let StudentLocation = "/StudentLocation"
    }
    
    struct ParameterKeys {
        static let Limit = "limit"
        static let Skip = "skip"
        static let Order = "order"
    }
    
    struct ParseHTTPHeaderField {
        static let ApplicationID = "X-Parse-Application-Id"
        static let APIKey = "X-Parse-REST-API-Key"
        static let ContentType = "Content-Type"
    }
    
    struct JSONBodyKeys {
        static let UniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
    }
}