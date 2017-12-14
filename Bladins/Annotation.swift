//
//  Annotation.swift
//  Bladins
//
//  Created by Adam Alfredsson on 2017-07-31.
//  Copyright © 2017 Richard Smith. All rights reserved.
//

import UIKit
import MapKit

class Annotation : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var image: UIImage?
    
    override init() {
        self.coordinate = CLLocationCoordinate2D()
        self.title = nil
        self.subtitle = nil
        self.image = nil
    }
}
