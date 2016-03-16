//
//  User.swift
//  On the Map
//
//  Created by Venkata Palakodety on 10/30/15.
//  Copyright © 2015 Venkata Palakodety. All rights reserved.
//

import Foundation

class User {
    //username of the logged in user
    static var username = ""
    
    //key for the logged in user
    static var key = ""
    
    //session id for the logged in user
    static var sessionId = ""
    
    //Set to false when all user data is finished loading
    static var loading = true
    
    static var firstName = ""
    static var lastName = ""
    
    static var errors: [NSError] = []
    
    //Login to Udacity with Username and password.
    class func logIn(username: String, password: String, didComplete: (success: Bool, errorMessage: String?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let bodyString = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}"
        request.HTTPBody = bodyString.dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                self.errors.append(error!)
                didComplete(success: false, errorMessage: "A network error has occurred.")
                return
            }
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
            let success = User.parseUserData(newData)
            let errorMessage: String? = success ? nil : "The email or password was not valid."
            didComplete(success: success, errorMessage: errorMessage)
        }
        task.resume()
    }
    
    //Parse the data elements for the logged in user and store them as properties for User class
    class func parseUserData(data: NSData) -> Bool {
        var success = true;
        if let userData = (try? NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers)) as? NSDictionary,
            let account = userData["account"] as? [String: AnyObject],
            let session = userData["session"] as? [String: String]
        {
            User.key = account["key"] as! String
            User.sessionId = session["id"]!
            User.getUserDetail() { success in
                if success {
                    self.loading = false
                }
            }
        } else {
            success = false
        }
        return success;
    }
    
    //Get the User Detail
    class func getUserDetail(didComplete: (success: Bool) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/users/\(User.key)")!)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error...
                self.errors.append(error!)
                didComplete(success: false)
                return
            }
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
            if let userData = (try? NSJSONSerialization.JSONObjectWithData(newData, options: .MutableContainers)) as? NSDictionary,
                let user = userData["user"] as? [String: AnyObject],
                let firstName = user["first_name"] as? String,
                let lastName = user["last_name"] as? String
            {
                self.firstName = firstName
                self.lastName = lastName
                didComplete(success: true)
            }
        }
        task.resume()
    }
    
    //Logout the User by issuing a DELETE request to the Udacity Session API
    class func logOut(didComplete: (success: Bool) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! as [NSHTTPCookie] {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.addValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-Token")
        }
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                self.errors.append(error!)
                didComplete(success: false)
                return
            }
            didComplete(success: true)
        }
        task.resume()
    }
}