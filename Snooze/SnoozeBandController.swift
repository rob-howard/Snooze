//
//  SnoozeBandController.swift
//  Snooze
//
//  Created by Rob Howard on 12/7/15.
//  Copyright © 2015 Rob Howard. All rights reserved.
//

import UIKit

public protocol SnoozeBandControllerDelegate : class {
    func statusUpdate(controller:SnoozeBandController, status:String)
    func bandTileOpened(controller:SnoozeBandController, handled:(Bool) -> ())
    func bandTileClosed(controller:SnoozeBandController, handled:(Bool) -> ())
    func bandButtonPressed(controller:SnoozeBandController, handled:(Bool) -> ())
}

public class SnoozeBandController : NSObject, MSBClientManagerDelegate, MSBClientTileDelegate {

    public let UUID = "51b7353e-8bad-423f-aa91-a5f4c235680a"
    
    private static let PromptPageIndex = 1 as UInt
    private static let ButtonPageIndex = 0 as UInt

    public var msbClient : MSBClient?
    
    public weak var snoozebandControllerDelegate: SnoozeBandControllerDelegate?
    
    public var statusText : String?
    
    private var theme : MSBTheme?
    
    public override init() {
        super.init()
        MSBClientManager.sharedManager().delegate = self
        
        self.msbClient = MSBClientManager.sharedManager().attachedClients().first as? MSBClient
        
        if(self.msbClient == nil){
            self.setStatusText("No Bands attached")
        }
        else{
            self.setStatusText("Connecting...")
            self.msbClient?.tileDelegate = self
            MSBClientManager.sharedManager().connectClient(self.msbClient)
        }
    }
    
    private func setStatusText(text:String){
        statusText = text
        snoozebandControllerDelegate?.statusUpdate(self, status: text)
    }
    
    private func vibrateError(){
        //error case / nothing to handle it
        self.msbClient?.notificationManager.vibrateWithType(MSBNotificationVibrationType.ThreeToneHigh, completionHandler: {
            (error) -> () in
        })
    }
    
    public func client(client: MSBClient!, buttonDidPress event: MSBTileButtonEvent!) {
        
        if let delegate = snoozebandControllerDelegate {
            delegate.bandButtonPressed(self, handled:{
                (success)->() in
                
                if(success == true){
                    self.msbClient?.notificationManager.vibrateWithType(MSBNotificationVibrationType.TwoTone, completionHandler: {
                        (error) -> () in
                    })
                }
                else{
                    self.vibrateError()
                }
            })
        }
        else{
            vibrateError()
        }
        
    }
    
    public func client(client: MSBClient!, tileDidOpen event: MSBTileEvent!) {
        
        if let delegate = snoozebandControllerDelegate {
            delegate.bandTileOpened(self, handled:{
                (success)->() in
                
                if(success == true){
                    self.msbClient?.notificationManager.vibrateWithType(MSBNotificationVibrationType.RampDown, completionHandler: {
                        (error) -> () in
                    })
                }
                else{
                    self.vibrateError()
                }
            })
        }
        else{
            vibrateError()
        }
    }
    
    public func client(client: MSBClient!, tileDidClose event: MSBTileEvent!) {
        
        if let delegate = snoozebandControllerDelegate {
            delegate.bandTileClosed(self, handled:{
                (success)->() in
                
                if(success == true){
                    self.msbClient?.notificationManager.vibrateWithType(MSBNotificationVibrationType.RampDown, completionHandler: {
                        (error) -> () in
                    })
                }
                else{
                    self.vibrateError()
                }
            })
        }
        else{
            vibrateError()
        }
    }
    
    public func clientManager(clientManager: MSBClientManager!, clientDidConnect client: MSBClient!) {
        setStatusText("Band Connected")
        
        self.msbClient?.personalizationManager.themeWithCompletionHandler(
            {
                (theme, error) -> () in
                if(error != nil){
                    self.setStatusText("Couldn't Load Theme")
                }
                else
                {
                    self.theme = theme
                    self.addTile()
                }
        })
    }
    
    public func clientManager(clientManager: MSBClientManager!, clientDidDisconnect client: MSBClient!) {
        setStatusText("Band Disconnected")
    }
    
    public func clientManager(clientManager: MSBClientManager!, client: MSBClient!, didFailToConnectWithError error: NSError!) {
        setStatusText("Failed to connect")
    }
    
    private func addTile(){
        
        // get a list of tiles to see if we have already installed this one
        self.msbClient?.tileManager.tilesWithCompletionHandler({
            (tiles, error) -> () in
            
            if(error != nil){
                self.setStatusText("Error fetching tiles")
                return
            }
            
            for tile in tiles {
                if(tile.tileId!.UUIDString == self.UUID){
                    self.setTilePage("Initializing...", buttonText:nil)
                    return
                }
            }
            
            // got here, so the tile isn't there, now to check to see if we have space for a new tile
            self.setStatusText("Checking tile space")
            
            self.msbClient?.tileManager.remainingTileCapacityWithCompletionHandler({
                (remainingCapacity, error) -> () in
                if(error != nil){
                    self.setStatusText("Capacity Failed")
                    return
                }
                
                if(remainingCapacity > 0){
                    if let tile = self.createTile(){
                        self.installTile(tile)
                    }
                    else{
                        self.setStatusText("Error creating tile")
                    }
                }
                else{
                    self.setStatusText("No Tile Capacity")
                    return
                }
            })
        })
    }
    
    
    private func createTile() -> MSBTile? {
        
        let tileIcon = try? MSBIcon(UIImage: UIImage(named: "A.png"))
        let smallIcon = try? MSBIcon(UIImage: UIImage(named: "Aa.png"))
        
        let tileId = NSUUID(UUIDString: self.UUID)
        
        let tile = try? MSBTile(id: tileId, name: "Snooze", tileIcon: tileIcon, smallIcon: smallIcon)
        
        let textBlock = MSBPageTextBlock(rect: MSBPageRect(x: 0, y: 0, width: 200, height: 40), font: MSBPageTextBlockFont.Small)
        textBlock.elementId = 10
        textBlock.baseline = 25
        textBlock.baselineAlignment = MSBPageTextBlockBaselineAlignment.Relative
        textBlock.horizontalAlignment = MSBPageHorizontalAlignment.Left
        textBlock.autoWidth = false
        textBlock.color = self.theme?.baseColor
        textBlock.margins = MSBPageMargins(left: 5, top: 2, right: 5, bottom: 2)
        
        let button = MSBPageTextButton(rect: MSBPageRect(x: 0, y: 0, width: 200, height: 40))
        button.elementId = 11
        button.horizontalAlignment = MSBPageHorizontalAlignment.Center
        button.pressedColor = self.theme?.baseColor
        button.margins = MSBPageMargins(left: 5, top: 2, right: 5, bottom: 2)
        
        let flowPanel = MSBPageFlowPanel(rect: MSBPageRect(x: 15, y: 0, width: 230, height: 105))
        
        flowPanel.addElements([textBlock, button])
        
        let buttonLayout = MSBPageLayout(root: flowPanel)
        
        tile?.pageLayouts.addObject(buttonLayout)
        
        let messagePanel = MSBPageFlowPanel(rect: MSBPageRect(x: 15, y: 0, width: 230, height: 105))
        
        let wrappedTextBlock = MSBPageWrappedTextBlock(rect: MSBPageRect(x: 0, y: 0, width: 200, height: 105), font: MSBPageWrappedTextBlockFont.Small)
        
        wrappedTextBlock.elementId = 10
        wrappedTextBlock.horizontalAlignment = MSBPageHorizontalAlignment.Left
        wrappedTextBlock.color = self.theme?.baseColor
        wrappedTextBlock.margins = MSBPageMargins(left: 5, top: 2, right: 5, bottom: 2)
        
        messagePanel.addElement(wrappedTextBlock)
        
        let messageLayout = MSBPageLayout(root: messagePanel)
        
        tile?.pageLayouts.addObject(messageLayout)
        
        return tile
    }
    
    private func createPage(prompt:String, buttonText:String?) -> MSBPageData {
        let pageId = NSUUID(UUIDString: "60d0b43b-f973-4e85-b67b-2a8b83dbb920")
        
        if let text = buttonText{
            
            let buttonData = try? MSBPageTextButtonData(elementId: 11, text: text)
            let textData = try? MSBPageTextBlockData(elementId: 10, text: prompt)
            
            let pageValues = [buttonData! as MSBPageTextButtonData, textData! as MSBPageTextBlockData]
            
            return MSBPageData(id: pageId, layoutIndex: SnoozeBandController.ButtonPageIndex , value: pageValues)
        }
        else{
            
            let textData = try? MSBPageTextBlockData(elementId: 10, text: prompt)
            
            let pageValues = [textData! as MSBPageTextBlockData]
            
            return MSBPageData(id: pageId, layoutIndex: SnoozeBandController.PromptPageIndex , value: pageValues)
        }
    }
    
    public func setTilePage(prompt:String, buttonText:String?){
        self.msbClient?.tileManager.setPages([createPage(prompt,buttonText: buttonText)], tileId: NSUUID(UUIDString: self.UUID), completionHandler:{
                (error) -> () in
                
                if(error != nil){
                    self.setStatusText("Error Setting tile")
                }
                else{
                    self.setStatusText("Ready")
                }
        })
    }
    
    private func installTile(tile:MSBTile){
        setStatusText("Adding tile...")
        
        self.msbClient?.tileManager.addTile(tile, completionHandler: {
            (error) -> () in
            if(error == nil || error.code == MSBErrorType.TileAlreadyExist.rawValue){
                self.setTilePage("Initializing...", buttonText:nil)
            }
            else
            {
                self.setStatusText("Error adding tile")
            }
            
        })
    }
}
