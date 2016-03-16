//
//  PostLocationViewController.swift
//  On the Map
//
//  Created by Venkata Palakodety on 10/30/15.
//  Copyright © 2015 Venkata Palakodety. All rights reserved.
//

import UIKit
import MapKit

class PostLocationViewController: FacebookUserViewController, MKMapViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var locationEntryView: UIView!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var geocodingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var mapContainerView: UIView!
    @IBOutlet weak var urlTextContainer: UIView!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    var location: CLLocation?
    var mapString: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Assign delegates and tap recognizers
        mapView.delegate = self
        locationTextField.delegate = self
        urlTextField.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: "didTapTextContainer:")
        urlTextContainer.addGestureRecognizer(tapGesture)
        
    }

    override func viewWillAppear(animated: Bool) {
        let applicationDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        if let sl = applicationDelegate.shareLink{
            urlTextField.text = sl
        }
    }

    @IBAction func browseButtonTouch(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue()) {
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("SubmitLinkViewController")
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    //Dissmiss the View Controller upon Cancel button click
    @IBAction func cancelButtonTouch(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //Geocode the location, when find on the map button is clicked.
    @IBAction func findButtonTouch(sender: AnyObject) {
        let text = locationTextField.text
        if !text!.isEmpty {
            startGeoLoading()
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(text!, completionHandler: didCompleteGeocoding)
        }
        else
        {
            self.showErrorAlert("Missing location", defaultMessage: "Please enter a location", errors: [])
        }
    }
    
    //Post a new location upon Submit button click
    @IBAction func submitButtonTouch(sender: AnyObject) {
        if !urlTextField.text!.isEmpty && location != nil {
            let coord = location!.coordinate
            let text = urlTextField.text
            StudentLocation.postNewLocation(coord.latitude, longitude: coord.longitude, mediaURL: text!, mapString: mapString) { (success, errorMessage) in
                if success {
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
                else
                {
                    if let message = errorMessage {
                        self.showErrorAlert("Post Failed", defaultMessage: message, errors: [])
                    }
                }
            }
        }
    }
    
    //Make sure the keyboard is hidden when user presses the enter key or return button.
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //Recognize taps on text field
    func didTapTextContainer(sender: AnyObject) {
        urlTextField.becomeFirstResponder()
    }
    
    //Perform Geocoding
    func didCompleteGeocoding(placemarks:[CLPlacemark]?, error:NSError?) {
        stopGeoLoading()
        
        if error == nil && placemarks!.count > 0 {
            // show the map
            locationEntryView.hidden = true
            mapContainerView.hidden = false
            
            // center the map and set the pin
            let placemark = placemarks![0]
            let geocodedLocation = placemark.location!
            centerMapOnLocation(geocodedLocation)
            
            let studentInfo = StudentInformation(data: [
                "firstName": User.firstName,
                "lastName": User.lastName,
                "latitude": geocodedLocation.coordinate.latitude,
                "longitude": geocodedLocation.coordinate.longitude,
                "mediaURL": ""
                ])
            
            let studentlocation = CLLocationCoordinate2D(
                latitude: studentInfo.latitude!,
                longitude: studentInfo.longitude!
            )
            let annotation = MKPointAnnotation()
            annotation.coordinate = studentlocation
            annotation.title = studentInfo.firstName + " " + studentInfo.lastName
            annotation.subtitle = studentInfo.mediaURL
            mapView.addAnnotation(annotation)
            
            // save for use during submit
            mapString = locationTextField.text!
            location = geocodedLocation
        } else {
            self.showErrorAlert("Error Geocoding", defaultMessage: "Unable to find the provided location", errors: [error!])
        }
    }
    
    //Show the Geocode Animation
    func startGeoLoading() {
        geocodingIndicator.startAnimating()
        locationEntryView.alpha = 0.5
    }
    
    //Stop the Geocode Animation
    func stopGeoLoading() {
        geocodingIndicator.stopAnimating()
        locationEntryView.alpha = 1
    }
    
    //Show the student information on the map
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
    
    //Center the map on a location
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 20000, 20000)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
}
