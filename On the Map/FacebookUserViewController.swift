//
//  FacebookUserViewController.swift
//  On the Map
//
//  Created by Venkata Palakodety on 10/29/15.
//  Copyright © 2015 Venkata Palakodety. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class FacebookUserViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Perform Facebook login only if the current access token is not present or expired.
    func completeFacebookUserLogIn() {
        dispatch_async(dispatch_get_main_queue(), {
            if(FBSDKAccessToken.currentAccessToken() != nil)
            {
                dispatch_async(dispatch_get_main_queue()) {
                    let controller = self.storyboard!.instantiateViewControllerWithIdentifier("TabBarController")
                    self.presentViewController(controller, animated: true, completion: nil)
                }
            }
        })
    }
    
    //Perform Facebook logout if the FB token is present.
    func completeFacebookUserLogout() {
        dispatch_async(dispatch_get_main_queue(), {
            if(FBSDKAccessToken.currentAccessToken() != nil)
            {
                let loginManager = FBSDKLoginManager()
                loginManager.logOut()
            
                let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController")
                self.presentViewController(controller, animated: true, completion: nil)
            }
        })
    }
    
    //Generic function to show the alert dialog whereever an error occurs and this function is called.
    func showErrorAlert(title: String, defaultMessage: String, errors: [NSError]) {
        var message = defaultMessage
        if !errors.isEmpty {
            message = errors[0].localizedDescription
        }
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let OkAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
        alertController.addAction(OkAction)
        dispatch_async(dispatch_get_main_queue(), {
            self.presentViewController(alertController, animated: true, completion: nil)
        })
    }
    
    //Generic function to show the alert dialog whereever an error occurs and this function is called.
    func showErrorAlertAndAnimate(title: String, defaultMessage: String, errors: [NSError], didComplete: (success: Bool) -> Void) {
        var message = defaultMessage
        if !errors.isEmpty {
            message = errors[0].localizedDescription
        }
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let OkAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
        alertController.addAction(OkAction)
        dispatch_async(dispatch_get_main_queue(), {
            self.presentViewController(alertController, animated: true, completion: nil)
            didComplete(success: true)
        })
        didComplete(success: false)
    }
    
    func animateTextFieldAndShowError(textfield:UITextField, errorMessage: String, errorLabel: UILabel)
    {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(CGPoint: CGPointMake(textfield.center.x - 10, textfield.center.y))
        animation.toValue = NSValue(CGPoint: CGPointMake(textfield.center.x + 10, textfield.center.y))
        textfield.layer.addAnimation(animation, forKey: "position")
        errorLabel.text = errorMessage
        
    }

}
