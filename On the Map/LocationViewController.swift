//
//  LocationViewController.swift
//  On the Map
//
//  Created by Venkata Palakodety on 10/30/15.
//  Copyright © 2015 Venkata Palakodety. All rights reserved.
//

import UIKit
import MapKit
import FBSDKCoreKit
import FBSDKLoginKit

//One class to allow sharing between Map and Table View.
class LocationViewController: FacebookUserViewController {
    
    @IBOutlet var pinButtonItem: UIBarButtonItem!
    @IBOutlet var refreshButtonItem: UIBarButtonItem!
    
    //Refresh notification
    let refreshNotificationName = "Location Data Refresh"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.setRightBarButtonItems([refreshButtonItem, pinButtonItem], animated: false)
    }
    
    //Reload locations when refresh button is clicked.
    @IBAction func refreshButtonTouch(sender: UIBarButtonItem) {
        self.loadLocationData(true) {
            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: self.refreshNotificationName, object: self))
        }
    }
    
    //Detect logout type and perform Facebook logout or Udacity logout accordingly. This way, we can have only one logout button instead of two in our view.
    @IBAction func logoutButtonTouch(sender: UIBarButtonItem) {
        sender.enabled = false
        if(FBSDKAccessToken.currentAccessToken() != nil)
        {
            self.completeFacebookUserLogout()
        }
        else
        {
            User.logOut() { success in
                sender.enabled = true
                if !success {
                    self.showErrorAlert("Logout Failed", defaultMessage: "Unable to log out", errors: User.errors)
                }else {
                    dispatch_async(dispatch_get_main_queue()) {
                        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController")
                        self.presentViewController(controller, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    //Show Post screen upon Pin Button Click
    @IBAction func pinButtonTouch(sender: UIBarButtonItem) {
        dispatch_async(dispatch_get_main_queue()) {
            self.performSegueWithIdentifier("showPost", sender: self)
        }
    }
    
    //Load location data or display an error message if the data cannot be loaded.
    internal func loadLocationData(forceRefresh: Bool = false, didComplete: (() -> Void)?) {
        StudentLocation.getRecent(forceRefresh) { success in
            if !success {
                self.showErrorAlert("Error Loading Locations", defaultMessage: "Loading failed.", errors: StudentLocation.errors)
            } else if !StudentLocation.locations.isEmpty && didComplete != nil {
                didComplete!()
            }
        }
    }
    
}
