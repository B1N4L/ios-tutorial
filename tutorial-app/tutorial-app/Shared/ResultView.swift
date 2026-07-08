//
//  ResultView.swift
//  tutorial-app
//
//  Created by Student 2 on 2026-07-08.
//

import UIKit
import MapKit
import CoreLocation   // included for future use

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Static coordinate
        let latitude: CLLocationDegrees = 37.3349
        let longitude: CLLocationDegrees = -122.0090
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        // Set region
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
        
        // Add annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Apple Park"
        annotation.subtitle = "Cupertino, CA"
        mapView.addAnnotation(annotation)
    }
}
