//
//  MapKitView.swift
//  tutorial-app
//
//  Created by Student 2 on 2026-07-08.
//

import SwiftUI
import MapKit

struct MapKitView: UIViewRepresentable {
    
    // Your static coordinates
    let latitude: CLLocationDegrees = 37.3349
    let longitude: CLLocationDegrees = -122.0090

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        
        mapView.setRegion(region, animated: false)
        
        // Add the annotation (pin)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Apple Park"
        annotation.subtitle = "Cupertino, CA"
        mapView.addAnnotation(annotation)
        
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Leave empty since we are using static coordinates
    }
}
