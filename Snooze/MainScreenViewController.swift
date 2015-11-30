//
//  MainScreenViewController.swift
//  Snooze
//
//  Created by Rob Howard on 12/3/15.
//  Copyright © 2015 Rob Howard. All rights reserved.
//

import UIKit

public class MainScreenViewController: UIViewController, SnoozeBandControllerDelegate {

    
    private var snoozeBandController: SnoozeBandController?
    
    @IBOutlet
    private var statusLabel:UILabel?
    
    @IBOutlet
    private var controllerButton:UIButton?
    
    @IBAction
    func controllerButtonPressed(sender: UIButton!){
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("SonosControllersViewController") as! SonosControllerViewController
        
        navigationController!.pushViewController(vc, animated: true)
    }
    
    @IBAction
    func musicButtonPressed(sender: UIButton!){
        
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        
        if let controller = app.selectedSnoozeController {
            let vc = self.storyboard!.instantiateViewControllerWithIdentifier("SonosFavoritesViewController") as! SonosFavoritesViewController
            
            vc.controller = controller
            
            navigationController!.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction
    func testButtonPressed(sender:UIButton!){
    
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        
        if let controller = app.selectedSnoozeController {
            if let playable = app.selectedFavorite {
            
                controller.playPlayable(playable, completion: {
                    (error)->() in
                if(error != nil){
                    print(error)
                    }                
                })
            }
        }       
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.setStatusText("Initializing...")
        
        snoozeBandController = SnoozeBandController()
        snoozeBandController?.snoozebandControllerDelegate = self
    }
    
    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        
        if let controller = app.selectedSnoozeController {
            controllerButton?.setTitle(controller.name, forState: UIControlState.Normal)
        }
        else{
            controllerButton?.setTitle("None", forState: UIControlState.Normal)
        }
    }
        
    private func setStatusText(text:String){
        dispatch_async(dispatch_get_main_queue()) {
            self.statusLabel?.text = text
        }
    }
    
    public func statusUpdate(controller:SnoozeBandController, status:String){
        setStatusText(status)
    }
    
    public func bandTileOpened(controller:SnoozeBandController, handled:(Bool)->()){
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        
        if (app.selectedSnoozeController == nil){
            controller.setTilePage("Please pick a controller to use in the app", buttonText: nil)
            handled(false)
        }
        else if(app.selectedFavorite == nil){
            controller.setTilePage("Please pick music to play in the app", buttonText:nil)
            handled(false)
        }
        else{
            controller.setTilePage("Ready to sleep?", buttonText: "Go!")
            handled(true);
        }
    }
    
    public func bandTileClosed(controller:SnoozeBandController, handled:(Bool)->()){
        controller.setTilePage("Initializing...", buttonText: nil)
        handled(true);
    }
    
    public func bandButtonPressed(controller:SnoozeBandController, handled:(Bool)->()){
        
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        
        if let snoozeController = app.selectedSnoozeController, let music = app.selectedFavorite {
            snoozeController.playPlayable(music, completion: {
                (error)->() in
                if(error != nil){
                    handled(false)
                    controller.setTilePage("Error in setting music to play.", buttonText:nil)
                    return
                }
                else{
                    snoozeController.setSleepTimer(60*30, completion:{
                        (response: [NSObject : AnyObject]!, error:NSError!) -> Void in
                        
                        handled(true)
                        controller.setTilePage("Goodnight!", buttonText:nil)
                        return
                    })
                }
            })
        }
        else{
            handled(false)
            if(app.selectedFavorite == nil){
                controller.setTilePage("Please pick music to play in the app", buttonText:nil)
            } else if (app.selectedSnoozeController == nil){
                controller.setTilePage("Please pick a controller to use in the app", buttonText: nil)
            }
            return
        }
    }
}
