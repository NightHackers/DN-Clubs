//
//  Notifications.swift
//  DN Clubs
//
//  Created by Gokul Swamy on 4/30/15.
//  Copyright (c) 2015 Nighthackers. All rights reserved.
//

import UIKit
import CoreData
import CloudKit

class Notifications: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var messages = [(String, String)]()
    var tableView = UITableView()
    var indicator = UIActivityIndicatorView()
    var list = [String]()
    @IBOutlet var bar: UITabBarItem!
    
    func contains(a:[(String, String)], v:(String,String)) -> Bool {
        let (c1, c2) = v
        for (v1, v2) in a { if v1 == c1 && v2 == c2 { return true } }
        return false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        UIApplication.shared.applicationIconBadgeNumber = 0
        if messages.count > 0{
            self.indicator.stopAnimating()
            self.indicator.hidesWhenStopped = true
        }
        let container = CKContainer.default()
        let publicData = container.publicCloudDatabase
        let query = CKQuery(recordType: "Notification", predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        publicData.perform(query, inZoneWith: nil) { results, error in
            if error == nil { // There is no error
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let managedContext = appDelegate.managedObjectContext
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Club")
                do {
                    let fetchedResults = try managedContext.fetch(fetchRequest) as? [NSManagedObject]
                    let results = fetchedResults
                    for club: NSManagedObject in results!{
                        let formatted = (club.value(forKey: "name") as! String).replacingOccurrences(of: " ", with: "")
                        if !self.list.contains(formatted){
                            self.list.append(formatted)
                        }
                    }
                } catch {
                    print("whoops")
                }
                for notif in results! {
                    let name = notif["Club"] as! String
                    if (self.list.contains(name)){
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateStyle = DateFormatter.Style.medium
                        let date = dateFormatter.string(from: notif.creationDate!)
                        let text = (notif["Message"] as! String).components(separatedBy: ": ")
                        let temp = (text[0]+": "+date, text[1])
                        if(!self.contains(a: self.messages, v: temp) && self.messages.count<20){
                            self.indicator.stopAnimating()
                            self.indicator.hidesWhenStopped = true
                            self.messages.append(temp)
                            self.tableView.reloadData()
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
        tableView = UITableView()
        tableView.frame = CGRect(origin: CGPoint(x: 0,y :64), size: CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height-114))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.view.addSubview(tableView)
        if messages.count == 0 {
            indicator = UIActivityIndicatorView(frame: CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 40, height: 40)))
            indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            indicator.center = self.view.center
            self.view.addSubview(indicator)
            indicator.startAnimating()
        }
        let container = CKContainer.default()
        let publicData = container.publicCloudDatabase
        let query = CKQuery(recordType: "Notification", predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        publicData.perform(query, inZoneWith: nil) { results, error in
            if error == nil { // There is no error
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let managedContext = appDelegate.managedObjectContext
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Club")
                do {
                    let fetchedResults = try managedContext.fetch(fetchRequest) as? [NSManagedObject]
                    let results = fetchedResults
                    for club: NSManagedObject in results!{
                        let formatted = (club.value(forKey: "name") as! String).replacingOccurrences(of: " ", with: "")
                        if !self.list.contains(formatted){
                            self.list.append(formatted)
                        }
                    }
                } catch {
                    print("whoops")
                }
                for notif in results! {
                    let name = notif["Club"] as! String
                    if (self.list.contains(name)){
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateStyle = DateFormatter.Style.medium
                        let date = dateFormatter.string(from: notif.creationDate!)
                        let text = (notif["Message"] as! String).components(separatedBy: ": ")
                        let temp = (text[0]+": "+date, text[1])
                        if(!self.contains(a: self.messages, v: temp) && self.messages.count<20){
                            self.indicator.stopAnimating()
                            self.indicator.hidesWhenStopped = true
                            self.messages.append(temp)
                            self.tableView.reloadData()
                        }
                    }
                }
            }
            else {
                print(error)
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
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
        var cell : UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as UITableViewCell!
        cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: cellIdentifier)
        cell!.textLabel?.text = messages[indexPath.row].0
        cell!.textLabel?.font = UIFont.boldSystemFont(ofSize: 18.0)
        cell!.detailTextLabel?.text = messages[indexPath.row].1
        cell!.detailTextLabel?.font = UIFont.systemFont(ofSize: 15.0)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newAlert = UIAlertController(title: messages[indexPath.row].0, message: messages[indexPath.row].1, preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .cancel) { (action:UIAlertAction!) in
        }
        newAlert.addAction(cancelAction)
        self.present(newAlert, animated: true, completion: nil)
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
