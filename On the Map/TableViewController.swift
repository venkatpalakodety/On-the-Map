//
//  TableViewController.swift
//  On the Map
//
//  Created by Venkata Palakodety on 10/29/15.
//  Copyright © 2015 Venkata Palakodety. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class TableViewController: LocationViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Note: I wanted to implement a "Pull to Refresh" functionality on the TableView, as it is so common with UIs these days. This is apart from the refresh button ofcourse.
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
        
        loadLocationData() {
            self.tableView.reloadData()
        }
        tableView.delegate = self
        tableView.dataSource = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didRefreshLocationData", name: refreshNotificationName, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Reload Table Data
    func didRefreshLocationData() {
        tableView.reloadData()
    }
    
    //Reload Table Data only if "Pull to Refresh" is performed on the tableview. Need this to end refreshing as well.
    func refresh(refreshControl: UIRefreshControl) {
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    //Display Student Info with a map pin icon in the tableview.
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("tableCell")! as UITableViewCell
        if  StudentLocation.locations.count > indexPath.row {
            let studentInfo = StudentLocation.locations[indexPath.row]
            cell.textLabel!.text = studentInfo.title
            cell.imageView!.image = UIImage(named: "map-pin")
            
            if indexPath.row % 2 == 0 { //alternating row backgrounds
                cell.backgroundColor = UIColor(red:0.91, green:0.55, blue:0.48, alpha:1.0)
            } else {
                cell.backgroundColor = UIColor(red:0.93, green:0.93, blue:0.93, alpha:1.0)
            }
        }
        return cell
    }
    
    //Get the count of student locations
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentLocation.locations.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if  StudentLocation.locations.count > indexPath.row {
            let studentInfo = StudentLocation.locations[indexPath.row]
            if let url = NSURL(string: studentInfo.mediaURL) {
                UIApplication.sharedApplication().openURL(url)
            }
        }
    }
    
}
