//
//  SonosFavoritesViewController.swift
//  Snooze
//
//  Created by Rob Howard on 12/12/15.
//  Copyright © 2015 Rob Howard. All rights reserved.
//

import UIKit

public class SonosFavoritesViewController: UITableViewController {
    
    private var favoritesList = [SonosPlayable]()
    private static let reuseId = "favoritesCellIdentifier"
    public var controller: SonosController?
    
    public override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: SonosFavoritesViewController.reuseId)
        
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if let controller = self.controller as SonosController! {
            controller.getFavorites({
                (favs, error) -> () in
                dispatch_async(dispatch_get_main_queue()) {
                    self.favoritesList = favs
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    public override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoritesList.count
    }
    
    public override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCellWithIdentifier(SonosFavoritesViewController.reuseId, forIndexPath: indexPath)
        
        let playable = favoritesList[(indexPath.row)]
        
        cell.textLabel?.text = playable.title
        cell.detailTextLabel?.text = playable.descriptionText
        
        return cell
    }
    
    public override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        app.selectedFavorite = favoritesList[(indexPath.row)]
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
}
