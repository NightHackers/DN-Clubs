//
//  Notifications.swift
//  DN Clubs
//
//  Created by Gokul Swamy on 4/30/15.
//  Copyright (c) 2015 Nighthackers. All rights reserved.
//

import UIKit
import CoreData
import Parse
import CloudKit

class Notifications: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var messages = [(String, String)]()
    var tableView = UITableView()
    @IBOutlet var bar: UITabBarItem!
    
    func contains(a:[(String, String)], v:(String,String)) -> Bool {
        let (c1, c2) = v
        for (v1, v2) in a { if v1 == c1 && v2 == c2 { return true } }
        return false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        let currentInstallation = PFInstallation.current()
        if  currentInstallation.badge != 0 {
            currentInstallation.badge = 0
            currentInstallation.saveEventually()
        }
        
        let container = CKContainer.default()
        let publicData = container.publicCloudDatabase
        let query = CKQuery(recordType: "Notification", predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        publicData.perform(query, inZoneWith: nil) { results, error in
            if error == nil { // There is no error
                var channels = PFInstallation.current().channels
                if(channels != nil){
                    print(channels)
                    for notif in results! {
                        let name = notif["Club"] as! String
                        for channel in channels!{
                            if (channel as! String == name){
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateStyle = DateFormatter.Style.medium
                                let date = dateFormatter.string(from: notif.creationDate!)
                                let text = (notif["Message"] as! String).components(separatedBy: ": ")
                                let temp = (text[0]+": "+date, text[1])
                                if(!self.contains(a: self.messages, v: temp) && self.messages.count<20){
                                    self.messages.append(temp)
                                    self.tableView.reloadData()
                                    
                                }
                                break
                            }
                        }
                    }
                }
            }
            else {
                print(error)
            }
        }

        
        tableView.reloadData()

    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        //messages+=[("Hello", "World")]
        let currentInstallation = PFInstallation.current()
        if currentInstallation.badge != 0 {
            currentInstallation.badge = 0
            currentInstallation.saveEventually()
        }
        tableView = UITableView()
        tableView.frame = CGRect(origin: CGPoint(x: 0,y :64), size: CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height-114))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.view.addSubview(tableView)
        let container = CKContainer.default()
        let publicData = container.publicCloudDatabase
        let query = CKQuery(recordType: "Notification", predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        publicData.perform(query, inZoneWith: nil) { results, error in
            if error == nil { // There is no error
                var channels = PFInstallation.current().channels
                if(channels != nil){
                    for notif in results! {
                        let name = notif["Club"] as! String
                        for channel in channels!{
                            if (channel as! String == name){
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateStyle = DateFormatter.Style.medium
                                let date = dateFormatter.string(from: notif.creationDate!)
                                let text = (notif["Message"] as! String).components(separatedBy: ": ")
                                let temp = (text[0]+": "+date, text[1])
                                if(!self.contains(a: self.messages, v: temp) && self.messages.count<20){
                                    self.messages.append(temp)
                                    self.tableView.reloadData()
                                }
                                break
                            }
                        }
                    }
                }
            }
            else {
                print(error)
            }
        }
        tableView.reloadData()


                // Do any additional setup after loading the view.
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat
    {
        return 80.0;//Choose your custom row height
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "cell"
        var cell : UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? UITableViewCell!
        cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: cellIdentifier)
        cell!.textLabel?.text = messages[indexPath.row].0
        cell!.textLabel?.font = UIFont.boldSystemFont(ofSize: 18.0)
        cell!.detailTextLabel?.text = messages[indexPath.row].1
        cell!.detailTextLabel?.font = UIFont.systemFont(ofSize: 15.0)
        return cell!
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let alert = UIAlertView(title: messages[indexPath.row].0, message: messages[indexPath.row].1, delegate: self, cancelButtonTitle: "Ok")
        alert.cancelButtonIndex = 0
        alert.show()

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
