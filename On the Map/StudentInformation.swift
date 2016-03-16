//
//  StudentInformation.swift
//  On the Map
//
//  Created by Venkata Palakodety on 10/30/15.
//  Copyright © 2015 Venkata Palakodety. All rights reserved.
//

import Foundation
import MapKit

struct StudentInformation {
    var latitude: Double?
    var longitude: Double?
    var firstName: String
    var lastName: String
    var mediaURL: String
    
    var title: String?
    var subtitle: String?
    
    init(data: NSDictionary) {
        latitude = data["latitude"] as? Double
        longitude = data["longitude"] as? Double
        firstName = data["firstName"] as! String
        lastName = data["lastName"] as! String
        mediaURL = data["mediaURL"] as! String
        
        title = "\(firstName) \(lastName)"
        subtitle = mediaURL
    }
    
    //Check if data is valid.
    static func isDataValid(data: NSDictionary) -> Bool {
        if let _ = data["latitude"] as? Double,
            let _ = data["longitude"] as? Double,
            let _ = data["firstName"] as? String,
            let _ = data["lastName"] as? String,
            let _ = data["mediaURL"] as? String
        {
            return true
        }
        return false
    }
}
