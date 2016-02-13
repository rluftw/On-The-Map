//
//  StudentLocation.swift
//  on the map
//
//  Created by Xing Hui Lu on 2/11/16.
//  Copyright © 2016 Xing Hui Lu. All rights reserved.
//

import Foundation
import MapKit

struct StudentLocation {
    var latitude: Double
    var longitude: Double
    
    func getCoordinates() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

