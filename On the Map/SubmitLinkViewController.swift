//
//  SubmitLinkViewController.swift
//  On the Map
//
//  Created by Venkata Palakodety on 11/1/15.
//  Copyright © 2015 Venkata Palakodety. All rights reserved.
//

import UIKit
import WebKit

//View Controller class to Share URL
//Reference: http://stackoverflow.com/questions/26436050/how-do-i-connect-the-search-bar-with-the-uiwebview-in-xcode-6-using-swift?rq=1
class SubmitLinkViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var webView: UIWebView!
    
    @IBAction func shareUrlButtonTouch(sender: AnyObject) {
        let applicationDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        if let sl = self.webView.request?.URL!.absoluteString{
            applicationDelegate.shareLink = sl
        }
        else
        {
            applicationDelegate.shareLink = ""
        }
        dismissViewControllerAnimated(true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchBar.delegate = self
    }
    
    @IBAction func cancelButtonTouch(sender: AnyObject) {
        let applicationDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        applicationDelegate.shareLink = ""
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
        let text = searchBar.text
        let url = NSURL(string: text!)  // User needs to type a URL with http in it
        let req = NSURLRequest(URL:url!)
        self.webView!.loadRequest(req)
    }
}
