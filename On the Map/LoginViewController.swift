//
//  ViewController.swift
//  On the Map
//
//  Created by Venkata Palakodety on 10/29/15.
//  Copyright © 2015 Venkata Palakodety. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class LoginViewController: FacebookUserViewController, FBSDKLoginButtonDelegate, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var signupButton: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var loginwithfacebookButton: FBSDKLoginButton!
    
    var keyboardAdjusted = false
    var lastKeyboardOffset : CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Assign delegates and makesure the FB login button is requesting permissions, when needed
        //Note: FB will not re-request permissions until FB determines the need.
        //In order to simulate a re-request, please reset the simulator settings.
        emailTextField.delegate = self
        passwordTextField.delegate = self
        loginwithfacebookButton.delegate = self
        loginwithfacebookButton.readPermissions = ["public_profile", "email", "user_friends"]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.subscribeToKeyboardNotifications()
        
        //This step ensures that if a valid FB token is present, it redirects to the tab view controller.
        //If there is no FB token or if the user is logging in through username and password, this step does not do anything.
        completeFacebookUserLogIn()
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.unsubscribeToKeyboardNotifications()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    //Login to Udacity if the user is logging in through email and password.
    @IBAction func loginButtonTouch(sender: AnyObject) {
        if let username = emailTextField.text, password = passwordTextField.text {
            if (username.isEmpty || (username.isEmail == false))
            {
                self.showErrorAlert("Authentication Error", defaultMessage: "Please enter a valid Email", errors: [])
                self.animateTextFieldAndShowError(emailTextField, errorMessage: "Please enter a valid Email", errorLabel: errorLabel)
            }
            else if (password.isEmpty)
            {
                self.showErrorAlert("Authentication Error", defaultMessage: "Please enter a Password", errors: [])
                self.animateTextFieldAndShowError(passwordTextField, errorMessage: "Please enter a valid Password", errorLabel: errorLabel)
            }
            else
            {
                errorLabel.text = ""
                User.logIn(username, password: password) { (success, errorMessage) in
                    if success {
                        NSOperationQueue.mainQueue().addOperationWithBlock {
                        self.performSegueWithIdentifier("showTabs", sender: self)
                        }
                    }
                    else
                    {
                        if let message = errorMessage {
                            self.showErrorAlertAndAnimate("Authentication Error", defaultMessage: message, errors: []) { (success) in
                                if success {
                                    self.animateTextFieldAndShowError(self.emailTextField, errorMessage: "Authentication Error", errorLabel: self.errorLabel)
                                    self.animateTextFieldAndShowError(self.passwordTextField, errorMessage: "Authentication Error", errorLabel: self.errorLabel)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    //Open Safari and redirect the user to Udacity's Sign Up Page, when the sign up button is clicked.
    @IBAction func signupButtonTouch(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.udacity.com/account/auth#!/signup")!)
    }
    
    //For Facebook Login Button - Overridden functions from FBSDKLoginButtonDelegate
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if (error != nil)
        {
            return
        }
    }
    
    //For Facebook Logout Button - Overridden functions from FBSDKLoginButtonDelegate
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        completeFacebookUserLogout()
    }
    
}

//Extensions for keyboard notifications. Not sure how I can move this to a model instead. It seems to be needed in each view controller where a textfield is present. Note: Please let me know if you have a tip for me :)
extension LoginViewController {
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if keyboardAdjusted == false {
            lastKeyboardOffset = getKeyboardHeight(notification) / 2
            self.view.superview?.frame.origin.y -= lastKeyboardOffset
            keyboardAdjusted = true
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        if keyboardAdjusted == true {
            self.view.superview?.frame.origin.y += lastKeyboardOffset
            keyboardAdjusted = false
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
}

//Reference: http://stackoverflow.com/questions/27998409/email-phone-validation-in-swift
//Reference 2: https://github.com/jpotts18/SwiftValidator
extension String {
    //Validate Email
    var isEmail: Bool {
        do {
            let regex = try NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}", options: .CaseInsensitive)
            return regex.firstMatchInString(self, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, self.characters.count)) != nil
        } catch {
            return false
        }
    }
}
