//
//  MapViewController.swift
//  Bladins
//
//  Created by Richard Smith on 2017-07-31.
//  Copyright © 2017 Richard Smith. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, AlarmDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var alarm: Alarm?
    var me: User?
    
    let regionRadius: CLLocationDistance = 200

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard alarm?.coordinates != nil else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        if alarm?.location?.locationDescription() != "" {
            navigationItem.title = alarm?.location?.locationDescription()
        } else {
            navigationItem.title = "GPS-position"
        }
        
        let coordinates = alarm!.coordinates!
        let initialLocation = importCL(coordinates: coordinates)
        let annotation = Annotation()
        annotation.coordinate = initialLocation
        mapView.addAnnotation(annotation)
        centerMapOnLocation(location: initialLocation)
    
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKind(of: Annotation.self) {
            var pinAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "DefaultPinView")
            if pinAnnotationView == nil {
                pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "DefaultPinView")
            }
            return pinAnnotationView
        }
        return nil
    }
    
    func centerMapOnLocation(location: CLLocationCoordinate2D) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location, regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
        
    }
    
    func importCL(coordinates: [Double]) -> CLLocationCoordinate2D {
        var coordinate = CLLocationCoordinate2D()
        let lat = coordinates[0]
        let lon = coordinates[1]
        coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        return coordinate
    }

}
