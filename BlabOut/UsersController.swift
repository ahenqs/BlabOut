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
    
    var following = [UserUID]()
    
    let userReference: FIRDatabaseReference = FIRDatabase.database().reference().child("users")
    
    lazy var blabReference: FIRDatabaseReference = {
        FIRDatabase.database().reference().child("blabs")
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        navigationController?.navigationBar.barStyle = .BlackTranslucent
        
        self.title = "Users"
        
        self.tableView.separatorInset = UIEdgeInsetsMake(0.0, 10.0, 0.0, 10.0)
        self.tableView.layoutMargins = UIEdgeInsetsMake(0.0, 10.0, 0.0, 10.0)
        
        tableView.registerClass(UserCell.self, forCellReuseIdentifier: cellID)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        following = [UserUID]()
        
        loadFollows()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    // MARK: Data
    
    func loadFollows() {
        
        if let currentUID = FIRAuth.auth()?.currentUser?.uid {
            
            userReference.child(currentUID).child("following").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                
                
                if snapshot.childrenCount > 0 {
                    
                    let c = Connection(snapshot: snapshot)
                    
                    self.following = c.users
                }
                
                self.loadUsers()
                
                }, withCancelBlock: { (error) in
                    
                    print("Error: \(error.localizedDescription)")
                    return
            })
        }
    }
    
    func loadUsers() {
        
        userReference.queryOrderedByChild("name").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
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
        
        cell.delegate = self
        
        if following.contains(users[indexPath.row].uid) {
            cell.hasFollowed = true
        } else {
            cell.hasFollowed = false
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}

extension UsersController: UserControllerDelegate {
    
    func didTapActionButton(user: User, sender: UIButton) {
        
        if let currentUID = FIRAuth.auth()?.currentUser?.uid {
            
            var hasRemoved = true
            
            if following.contains(user.uid) {
                //removes
                
                for i in 0..<following.count {
                    
                    let value = following[i]
                    
                    if value == user.uid {
                        following.removeAtIndex(i)
                        break
                    }
                }
                
            } else {
                //adds
                
                following.append(user.uid)
                
                hasRemoved = false
            }
        
            userReference.child(currentUID).updateChildValues(["following": following], withCompletionBlock: { (error, reference) in
                
                if error != nil {
                    print("Error: \(error?.localizedDescription)")
                    return
                }
                
                //get my feed
                
                self.userReference.child(currentUID).child("feed").observeSingleEventOfType(.Value, withBlock: { (snpt) in
                    
                    if error != nil {
                        print("Error: \(error?.localizedDescription)")
                        return
                    }
                    
                    var myFeed = [String: AnyObject]()
                    
                    for blab in snpt.children {
                        let blabObject = Blab(snapshot: blab as! FIRDataSnapshot)
                        
                        if (hasRemoved){
                            
                            if blabObject.user?.uid != user.uid {
                                myFeed[blabObject.key] = blabObject.toAnyObject()
                            }
                            
                        } else {
                            myFeed[blabObject.key] = blabObject.toAnyObject()
                        }
                    }
                    
                    if (!hasRemoved) { //has followed
                    
                        //my friend's feed
                        self.blabReference.queryOrderedByChild("user/uid").queryEqualToValue(user.uid).observeSingleEventOfType(.Value, withBlock: { (snpt) in
                            
                            if error != nil {
                                print("Error: \(error?.localizedDescription)")
                                return
                            }
                            
                            //merge feed
                            for blab in snpt.children {
                                let blabObject = Blab(snapshot: blab as! FIRDataSnapshot)
                                myFeed[blabObject.key] = blabObject.toAnyObject()
                            }
                            
                            self.userReference.child(currentUID).updateChildValues(["feed": myFeed], withCompletionBlock: { (error, reference) in
                                
                                
                                if error != nil {
                                    print("Error: \(error?.localizedDescription)")
                                    return
                                }
                                
                                if hasRemoved {
                                    sender.setTitle("Follow", forState: .Normal)
                                    sender.backgroundColor = UIColor.appOrange()
                                } else {
                                    sender.setTitle("Unfollow", forState: .Normal)
                                    sender.backgroundColor = UIColor.darkGrayColor()
                                }
                                
                                //update follower's list of followers - add follower

                                self.userReference.child(user.uid).child("followers").observeSingleEventOfType(.Value, withBlock: { (shot) in
                                    
                                    var followers = [UserUID]()
                                    
                                    if shot.childrenCount > 0 {
                                        
                                        let c = Connection(snapshot: shot)
                                        
                                        followers = c.users
                                    }
                                    
                                    //update
                                    
                                    if followers.count > 0 { //has followers
                                    
                                        self.userReference.child(user.uid).updateChildValues(["followers": followers], withCompletionBlock: { (error, reference) in
                                        
                                            if error != nil {
                                                print("Error: \(error?.localizedDescription)")
                                                return
                                            }
                                            
                                            print("Success ˆˆ")
                                            
                                        })
                                    } else { //first follower
                                        
                                        var followers = [UserUID]()
                                        followers.append(currentUID)
                                        
                                        self.userReference.child(user.uid).updateChildValues(["followers": followers], withCompletionBlock: { (error, reference) in
                                            
                                            if error != nil {
                                                print("Error: \(error?.localizedDescription)")
                                                return
                                            }
                                            
                                            print("Success ˆˆ")
                                            
                                        })
                                    }
                                    
                                    }, withCancelBlock: { (error) in
                                        
                                        print("Error: \(error.localizedDescription)")
                                        return
                                })
                                
                            })
                        })
                    
                    } else {
                        //update my feed
                        
                        self.userReference.child(currentUID).updateChildValues(["feed": myFeed], withCompletionBlock: { (error, reference) in
                            
                            
                            if error != nil {
                                print("Error: \(error?.localizedDescription)")
                                return
                            }
                            
                            print("Success ˆˆ")
                            
                            if hasRemoved {
                                sender.setTitle("Follow", forState: .Normal)
                                sender.backgroundColor = UIColor.appOrange()
                            } else {
                                sender.setTitle("Unfollow", forState: .Normal)
                                sender.backgroundColor = UIColor.darkGrayColor()
                            }
                            
                            //update follower's list of followers - remove follower
                            
                            self.userReference.child(user.uid).child("followers").observeSingleEventOfType(.Value, withBlock: { (shot) in
                                
                                var followers = [UserUID]()
                                
                                if shot.childrenCount > 0 {
                                    
                                    let c = Connection(snapshot: shot)
                                    
                                    followers = c.users
                                }
                                
                                // TODO: ADD map / filter / reduce here!!!
                                if followers.contains(currentUID) {
                                    
                                    for i in 0..<followers.count {
                                        followers.removeAtIndex(i)
                                    }
                                }
                                
                                //update
                                
                                if followers.count > 0 { //has followers
                                    
                                    self.userReference.child(user.uid).updateChildValues(["followers": followers], withCompletionBlock: { (error, reference) in
                                        
                                        if error != nil {
                                            print("Error: \(error?.localizedDescription)")
                                            return
                                        }
                                        
                                        print("Success ˆˆ")
                                        
                                    })
                                } else { //had last follower
                                    
                                    self.userReference.child(user.uid).child("followers").removeValueWithCompletionBlock({ (error, ref) in
                                        
                                        if error != nil {
                                            print("Error: \(error?.localizedDescription)")
                                            return
                                        }
                                        
                                        print("Success ˆˆ")
                                        
                                    })
                                }
                                
                                }, withCancelBlock: { (error) in
                                    
                                    print("Error: \(error.localizedDescription)")
                                    return
                            })
                            
                        })
                    
                    }
                    
                })
            })
        }
    }
}
