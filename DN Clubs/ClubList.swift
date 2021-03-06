//
//  Notifications.swift
//  DN Clubs
//
//  Created by Gokul Swamy on 4/30/15.
//  Copyright (c) 2015 Nighthackers. All rights reserved.
//

import UIKit

class ClubList: UIViewController, UITableViewDataSource, UISearchResultsUpdating {
    var list:[(clubName: String, description: String)] = []
    var filteredList:[(clubName: String, description: String)]!
    var searchController: UISearchController!
    @IBOutlet var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let endpoint = NSURL(string: "https://dl.dropboxusercontent.com/u/17375564/clubs.json")
        let data = NSData(contentsOfURL: endpoint!)
        do{
            let json: NSDictionary = try (NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary)!
            let items = json["clubs"] as! NSArray
            for item in items {
                let name: String = item["clubName"] as! String
                let desc: String = item["description"] as! String
                list+=[(clubName: name, description: desc)]
            }
        } catch {
            print("broken link")
        }
        list.sortInPlace {$0.0 == $1.0 ? $0.1 < $1.1 : $0.0 < $1.0}
        tableView.dataSource = self
        filteredList = list
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        searchController.definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        definesPresentationContext = true
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        // Do any additional setup after loading the view.
        //
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Club", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = filteredList[indexPath.row].clubName
        cell.detailTextLabel?.text = filteredList[indexPath.row].description
        return cell
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchText = searchController.searchBar.text?.lowercaseString
        if (searchText!.isEmpty){
            filteredList = list
        }
        else{
            filteredList = list.filter({ (dataString: (clubName: String, description: String)) -> Bool in
                return dataString.clubName.lowercaseString.rangeOfString(searchText!) != nil
            })
        }
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showAddClub" {
            if let destinationVC = segue.destinationViewController as? addClub{
                let row = self.tableView.indexPathForSelectedRow?.row
                var imageOfUnderlyingView = self.view.convertViewToImage()
                let backView = UIImageView(frame: self.view.frame)
                backView.image = imageOfUnderlyingView
                backView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
                var lightBlur = UIBlurEffect(style: UIBlurEffectStyle.Light)
                var blurView = UIVisualEffectView(effect: lightBlur)
                blurView.frame =  backView.bounds
                backView.addSubview(blurView)
                destinationVC.view.addSubview(backView)
                destinationVC.view.sendSubviewToBack(backView)
                destinationVC.text1 = filteredList[row!].clubName
                destinationVC.text2 = filteredList[row!].description
            }
        }
    }
 
    
    //
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
