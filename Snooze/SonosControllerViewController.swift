//
//  SonosControllerViewController.swift
//  Snooze
//
//  Created by Rob Howard on 12/2/15.
//  Copyright © 2015 Rob Howard. All rights reserved.
//

import UIKit


class SonosControllerViewController : UITableViewController{
    
    private var controllerList = [SonosController]()
    private static let reuseId = "controllerCellIdentifier"
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: SonosControllerViewController.reuseId)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        SonosDiscover.discoverControllers({
            (controllers, error) in
            if(controllers == nil){
                return
            }
            dispatch_async(dispatch_get_main_queue()) {
                self.controllerList = controllers
                self.tableView.reloadData()
            }
        })
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return controllerList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCellWithIdentifier(SonosControllerViewController.reuseId, forIndexPath: indexPath)
        
        let controller = controllerList[(indexPath.row)]
        
        cell.textLabel?.text = controller.name
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        app.selectedSnoozeController = controllerList[(indexPath.row)]
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
}