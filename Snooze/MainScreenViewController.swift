//
//  MainScreenViewController.swift
//  Snooze
//
//  Created by Rob Howard on 12/3/15.
//  Copyright © 2015 Rob Howard. All rights reserved.
//

import UIKit

public class MainScreenViewController: UIViewController {

    @IBOutlet
    private var statusLabel:UILabel?
    
    @IBOutlet
    private var controllerButton:UIButton?
    
    @IBOutlet
    private var musicButton:UIButton?
    
    @IBAction
    func controllerButtonPressed(sender: UIButton!){
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("SonosControllersViewController") as! SonosControllerViewController
        
        navigationController!.pushViewController(vc, animated: true)
    }
    
    @IBAction
    func musicButtonPressed(sender: UIButton!){
        
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        
        guard let controller = app.selectedSnoozeController else { return; }
        
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("SonosFavoritesViewController") as! SonosFavoritesViewController
        
        vc.controller = controller
        
        navigationController!.pushViewController(vc, animated: true)
    }
    
    @IBAction
    func testButtonPressed(sender:UIButton!){
    
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        
        guard let controller = app.selectedSnoozeController else { return; }
        guard let playable = app.selectedFavorite else { return; }
            
        controller.playPlayable(playable, completion: {
            (error)->() in
        if(error != nil){
            print(error)
            }                
        })
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.setStatusText("Initializing...")        
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
        
        if let music = app.selectedFavorite {
            musicButton?.setTitle(music.title, forState: UIControlState.Normal)
        }
        else{
            musicButton?.setTitle("None", forState: UIControlState.Normal)
        }
    }
        
    public func setStatusText(text:String){
        dispatch_async(dispatch_get_main_queue()) {
            self.statusLabel?.text = text
        }
    }
}
