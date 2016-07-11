//
//  UsersController.swift
//  BlabOut
//
//  Created by André Henrique da Silva on 11/07/2016.
//  Copyright © 2016 André Henrique da Silva. All rights reserved.
//

import UIKit
import Firebase

let cellID = "UserCell"

class UsersController: UITableViewController {
    
    var users = [User]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    let userReference: FIRDatabaseReference = FIRDatabase.database().reference().child("users")

    override func viewDidLoad() {
        super.viewDidLoad()
     
        navigationController?.navigationBar.barStyle = .BlackTranslucent
        
        self.title = "Users"
        
        self.tableView.separatorInset = UIEdgeInsetsMake(0.0, 10.0, 0.0, 10.0)
        self.tableView.layoutMargins = UIEdgeInsetsMake(0.0, 10.0, 0.0, 10.0)
        
        tableView.registerClass(UserCell.self, forCellReuseIdentifier: cellID)
        
        loadUsers()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    // MARK: Data
    
    func loadUsers() {
        
        userReference.queryOrderedByChild("name").observeEventType(.Value, withBlock: { (snapshot) in
            
            var newUsers = [User]()
            
            let loggedUserID = FIRAuth.auth()?.currentUser?.uid
            
            for snap in snapshot.children {
                
                let user = User(snapshot: snap as! FIRDataSnapshot)
                
                if user.uid != loggedUserID {
                
                    newUsers.append(user)
                }
            }
            
            self.users = newUsers
            
            }) { (error) in
                print("Error: \(error.localizedDescription)")
                return
        }
        
    }
    
    // MARK: Table View
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath) as! UserCell
        
        let user = users[indexPath.row]
        
        cell.user = user
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}
