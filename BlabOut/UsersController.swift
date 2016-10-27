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

class UsersController: UITableViewController, AlertMessage {
    
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
     
        navigationController?.navigationBar.barStyle = .blackTranslucent
        
        self.title = "Users"
        
        self.tableView.separatorInset = UIEdgeInsetsMake(0.0, 10.0, 0.0, 10.0)
        self.tableView.layoutMargins = UIEdgeInsetsMake(0.0, 10.0, 0.0, 10.0)
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellID)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        following = [UserUID]()
        
        loadFollows()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: Data
    
    func loadFollows() {
        
        if let currentUID = FIRAuth.auth()?.currentUser?.uid {
            
            userReference.child(currentUID).child("following").observeSingleEvent(of: .value, with: { (snapshot) in
                
                
                if snapshot.childrenCount > 0 {
                    
                    let c = Connection(snapshot: snapshot)
                    
                    self.following = c.users
                }
                
                self.loadUsers()
                
                }, withCancel: { (error) in
                    
                    self.showAlert(viewController: self, title: oopsTitle, message: error.localizedDescription, buttonTitle: okTitle)
                    return
            })
        }
    }
    
    func loadUsers() {
        
        userReference.queryOrdered(byChild: "name").observeSingleEvent(of: .value, with: { (snapshot) in
            
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
                self.showAlert(viewController: self, title: oopsTitle, message: error.localizedDescription, buttonTitle: okTitle)
                
                return
        }
        
    }
    
    // MARK: Table View
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! UserCell
        
        let user = users[(indexPath as NSIndexPath).row]
        
        cell.user = user
        
        cell.delegate = self
        
        if following.contains(users[(indexPath as NSIndexPath).row].uid) {
            cell.hasFollowed = true
        } else {
            cell.hasFollowed = false
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension UsersController: UserControllerDelegate {
    
    func didTapActionButton(_ user: User, sender: UIButton) {
        
        if let currentUID = FIRAuth.auth()?.currentUser?.uid {
            
            var hasRemoved = true
            
            if following.contains(user.uid) {
                //removes
                
                for i in 0..<following.count {
                    
                    let value = following[i]
                    
                    if value == user.uid {
                        following.remove(at: i)
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
                    self.showAlert(viewController: self, title: oopsTitle, message: error!.localizedDescription, buttonTitle: okTitle)
                    return
                }
                
                //get my feed
                
                self.userReference.child(currentUID).child("feed").observeSingleEvent(of: .value, with: { (snpt) in
                    
                    if error != nil {
                        self.showAlert(viewController: self, title: oopsTitle, message: error!.localizedDescription, buttonTitle: okTitle)
                        return
                    }
                    
                    var myFeed = [String: AnyObject]()
                    
                    for blab in snpt.children {
                        let blabObject = Blab(snapshot: blab as! FIRDataSnapshot)
                        
                        if (hasRemoved){
                            
                            if blabObject.user?.uid != user.uid {
                                myFeed[blabObject.key] = blabObject.toAnyObject() as AnyObject?
                            }
                            
                        } else {
                            myFeed[blabObject.key] = blabObject.toAnyObject() as AnyObject?
                        }
                    }
                    
                    if (!hasRemoved) { //has followed
                    
                        //my friend's feed
                        self.blabReference.queryOrdered(byChild: "user/uid").queryEqual(toValue: user.uid).observeSingleEvent(of: .value, with: { (snpt) in
                            
                            if error != nil {
                                self.showAlert(viewController: self, title: oopsTitle, message: error!.localizedDescription, buttonTitle: okTitle)
                                return
                            }
                            
                            //merge feed
                            for blab in snpt.children {
                                let blabObject = Blab(snapshot: blab as! FIRDataSnapshot)
                                myFeed[blabObject.key] = blabObject.toAnyObject() as AnyObject?
                            }
                            
                            self.userReference.child(currentUID).updateChildValues(["feed": myFeed], withCompletionBlock: { (error, reference) in
                                
                                
                                if error != nil {
                                    self.showAlert(viewController: self, title: oopsTitle, message: error!.localizedDescription, buttonTitle: okTitle)
                                    return
                                }
                                
                                if hasRemoved {
                                    sender.setTitle("Follow", for: UIControlState())
                                    sender.backgroundColor = UIColor.appOrange()
                                } else {
                                    sender.setTitle("Unfollow", for: UIControlState())
                                    sender.backgroundColor = UIColor.darkGray
                                }
                                
                                //update follower's list of followers - add follower

                                self.userReference.child(user.uid).child("followers").observeSingleEvent(of: .value, with: { (shot) in
                                    
                                    var followers = [UserUID]()
                                    
                                    if shot.childrenCount > 0 {
                                        
                                        let c = Connection(snapshot: shot)
                                        
                                        followers = c.users
                                    }
                                    
                                    //update
                                    
                                    if followers.count > 0 { //has followers
                                    
                                        self.userReference.child(user.uid).updateChildValues(["followers": followers], withCompletionBlock: { (error, reference) in
                                        
                                            if error != nil {
                                                self.showAlert(viewController: self, title: oopsTitle, message: error!.localizedDescription, buttonTitle: okTitle)
                                                return
                                            }
                                            
                                            print("Success ˆˆ")
                                            
                                        })
                                    } else { //first follower
                                        
                                        var followers = [UserUID]()
                                        followers.append(currentUID)
                                        
                                        self.userReference.child(user.uid).updateChildValues(["followers": followers], withCompletionBlock: { (error, reference) in
                                            
                                            if error != nil {
                                                self.showAlert(viewController: self, title: oopsTitle, message: error!.localizedDescription, buttonTitle: okTitle)
                                                return
                                            }
                                            
                                            print("Success ˆˆ")
                                            
                                        })
                                    }
                                    
                                    }, withCancel: { (error) in
                                        
                                        self.showAlert(viewController: self, title: oopsTitle, message: error.localizedDescription, buttonTitle: okTitle)
                                        return
                                })
                                
                            })
                        })
                    
                    } else {
                        //update my feed
                        
                        self.userReference.child(currentUID).updateChildValues(["feed": myFeed], withCompletionBlock: { (error, reference) in
                            
                            
                            if error != nil {
                                self.showAlert(viewController: self, title: oopsTitle, message: error!.localizedDescription, buttonTitle: okTitle)
                                return
                            }
                            
                            print("Success ˆˆ")
                            
                            if hasRemoved {
                                sender.setTitle("Follow", for: UIControlState())
                                sender.backgroundColor = UIColor.appOrange()
                            } else {
                                sender.setTitle("Unfollow", for: UIControlState())
                                sender.backgroundColor = UIColor.darkGray
                            }
                            
                            //update follower's list of followers - remove follower
                            
                            self.userReference.child(user.uid).child("followers").observeSingleEvent(of: .value, with: { (shot) in
                                
                                var followers = [UserUID]()
                                
                                if shot.childrenCount > 0 {
                                    
                                    let c = Connection(snapshot: shot)
                                    
                                    followers = c.users
                                }
                                
                                // TODO: ADD map / filter / reduce here!!!
                                if followers.contains(currentUID) {
                                    
                                    for i in 0..<followers.count {
                                        followers.remove(at: i)
                                    }
                                }
                                
                                //update
                                
                                if followers.count > 0 { //has followers
                                    
                                    self.userReference.child(user.uid).updateChildValues(["followers": followers], withCompletionBlock: { (error, reference) in
                                        
                                        if error != nil {
                                            self.showAlert(viewController: self, title: oopsTitle, message: error!.localizedDescription, buttonTitle: okTitle)
                                            return
                                        }
                                        
                                        print("Success ˆˆ")
                                        
                                    })
                                } else { //had last follower
                                    
                                    self.userReference.child(user.uid).child("followers").removeValue(completionBlock: { (error, ref) in
                                        
                                        if error != nil {
                                            self.showAlert(viewController: self, title: oopsTitle, message: error!.localizedDescription, buttonTitle: okTitle)
                                            return
                                        }
                                        
                                        print("Success ˆˆ")
                                        
                                    })
                                }
                                
                                }, withCancel: { (error) in
                                    
                                    self.showAlert(viewController: self, title: oopsTitle, message: error.localizedDescription, buttonTitle: okTitle)
                                    return
                            })
                            
                        })
                    
                    }
                    
                })
            })
        }
    }
}
