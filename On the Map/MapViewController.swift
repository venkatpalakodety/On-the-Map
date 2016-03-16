//
//  MapViewController.swift
//  On the Map
//
//  Created by Venkata Palakodety on 10/29/15.
//  Copyright © 2015 Venkata Palakodety. All rights reserved.
//

import UIKit
import MapKit
import FBSDKCoreKit
import FBSDKLoginKit

class MapViewController: LocationViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var selectedView: MKAnnotationView?
    var tapGesture: UITapGestureRecognizer!
    var annotations = [MKPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        tapGesture = UITapGestureRecognizer(target: self, action: "calloutTapped:")
        loadLocationData() {
            self.loadAnnotations()
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didRefreshLocationData", name: refreshNotificationName, object: nil)
    }
    
    func didRefreshLocationData() {
        self.mapView.removeAnnotations(annotations)
        self.loadAnnotations()
    }
    
    //Add annotations to the mapview.
    func loadAnnotations() {
        let lat = StudentLocation.locations[0].latitude
        let long  = StudentLocation.locations[0].longitude
        let initialLocation = CLLocation(latitude: lat!, longitude: long!)
        centerMapOnLocation(initialLocation)
        /*for location in StudentLocation.locations {
            mapView.addAnnotation(location)
        }*/
        
        for s in StudentLocation.locations{
            let location = CLLocationCoordinate2D(
                latitude: s.latitude!,
                longitude: s.longitude!
            )
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            annotation.title = s.firstName + " " + s.lastName
            annotation.subtitle = s.mediaURL
            self.annotations += [annotation]
            self.mapView.addAnnotation(annotation)
        }
    }
    
    //Centers the map on a specified location
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 2000000, 2000000)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Open browser with annotation URL
    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == annotationView.rightCalloutAccessoryView {
            
            let request = NSURLRequest(URL: NSURL(string: annotationView.annotation!.subtitle!!)!)
            UIApplication.sharedApplication().openURL(request.URL!)
            
        }
    }
    
    //Create an annotation for each Pin. This annotation will have an info button. Clicking on the info button should open default browser.
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
}
