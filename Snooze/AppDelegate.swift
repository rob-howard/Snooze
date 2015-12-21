//
//  AppDelegate.swift
//  Snooze
//
//  Created by Rob Howard on 12/2/15.
//  Copyright © 2015 Rob Howard. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, SnoozeBandControllerDelegate {

    var window: UIWindow?
    
    var selectedSnoozeController : SonosController? {
        didSet {
            let defaults = NSUserDefaults.standardUserDefaults()
            if let controller = selectedSnoozeController {
                defaults.setObject(controller.uuid, forKey: "selectedController")
            }
        }
    }
    
    var selectedFavorite : SonosPlayable? {
        didSet {
            let defaults = NSUserDefaults.standardUserDefaults()
            if let favorite = selectedFavorite {
                defaults.setObject(favorite.resText, forKey: "selectedFavorite")
            }
        }
    }

    
    private var snoozeBandController: SnoozeBandController?
    private var mainScreenViewController : MainScreenViewController?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        snoozeBandController = SnoozeBandController()
        snoozeBandController?.snoozebandControllerDelegate = self
        
        let storyboard = UIStoryboard(name:"Main", bundle:nil)
        
        let controller = storyboard.instantiateViewControllerWithIdentifier("LoadingViewController")
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.rootViewController = controller
        window?.makeKeyAndVisible()
        
        backgroundThread(background: { self.loadPrefs() })
        
        return true
    }
    
    private func loadPrefs(){
    
        // find the controller in the networks
        let defaults = NSUserDefaults.standardUserDefaults()
        if let controller = defaults.stringForKey("selectedController"){
            SonosDiscover.discoverControllers({
                (controllers, error) in
                if(controllers == nil){
                    self.loadMainScreen()
                    return
                }
                for currentController in controllers {
                    if(currentController.uuid == controller)
                    {
                        self.selectedSnoozeController = currentController
                        break
                    }
                }
                if let currentContoller = self.selectedSnoozeController,
                    favorite = defaults.stringForKey("selectedFavorite"){
                    
                        currentContoller.getFavorites({
                            (favs, error) -> () in
                            
                            if let favsList = favs {
                                for playable in favsList {
                                    if(playable.resText == favorite){
                                        self.selectedFavorite = playable
                                    }
                                }
                            }
                            
                            self.loadMainScreen()
                        })
                }
                else{
                    self.loadMainScreen()
                }
            })
        }
        else{
            self.loadMainScreen()
        }
    }
    
    private func loadMainScreen(){
        
        dispatch_async(dispatch_get_main_queue()) {
            
            let storyboard = UIStoryboard(name:"Main", bundle:nil)
            
            let navController = storyboard.instantiateInitialViewController() as? UINavigationController
            
            self.mainScreenViewController = navController?.viewControllers.first as? MainScreenViewController
            
            self.window?.rootViewController = navController
        }
    }   

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func bandButtonPressed(controller:SnoozeBandController, handled:(Bool)->()){
        
        if let snoozeController = selectedSnoozeController, let music = selectedFavorite {
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
            if(selectedFavorite == nil){
                controller.setTilePage("Please pick music to play in the app", buttonText:nil)
            } else if (selectedSnoozeController == nil){
                controller.setTilePage("Please pick a controller to use in the app", buttonText: nil)
            }
            return
        }
    }
    
    func statusUpdate(controller:SnoozeBandController, status:String){
        mainScreenViewController?.setStatusText(status)
    }
    
    func bandTileOpened(controller:SnoozeBandController, handled:(Bool)->()){
        
        if (selectedSnoozeController == nil){
            controller.setTilePage("Please pick a controller to use in the app", buttonText: nil)
            handled(false)
        }
        else if(selectedFavorite == nil){
            controller.setTilePage("Please pick music to play in the app", buttonText:nil)
            handled(false)
        }
        else{
            controller.setTilePage("Ready to sleep?", buttonText: "Go!")
            handled(true);
        }
    }
    
    func bandTileClosed(controller:SnoozeBandController, handled:(Bool)->()){
        controller.setTilePage("Initializing...", buttonText: nil)
        handled(true);
    }
}

func backgroundThread(delay: Double = 0.0, background: (() -> Void)? = nil, completion: (() -> Void)? = nil) {
    dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)) {
        if(background != nil){ background!(); }
        
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
        dispatch_after(popTime, dispatch_get_main_queue()) {
            if(completion != nil){ completion!(); }
        }
    }
}

