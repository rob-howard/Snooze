//
//  ControllerDetailsViewController.swift
//  Snooze
//
//  Created by Rob Howard on 12/2/15.
//  Copyright © 2015 Rob Howard. All rights reserved.
//

import UIKit

public class ControllerDetailsViewController: UIViewController {
    
    @IBOutlet
    private var titleLabel:UILabel?
    
    public var controller:SonosController?
    
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = controller?.name
    }
    
    @IBAction
    func snoozeButtonPresssed(sender: UIButton!){
        
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        app.selectedSnoozeController = self.controller
        self.navigationController?.popToRootViewControllerAnimated(true)       
        
        /*  Just testing some stuff.  Will remove later...
            self.controller?.currentTrackInfo({
            (response:[NSObject : AnyObject]!, error:NSError!) -> Void in
            print(response);
            print("info!");
        });**/
    }
}
