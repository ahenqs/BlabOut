//
//  TimelineController.swift
//  BlabOut
//
//  Created by André Henrique da Silva on 10/07/2016.
//  Copyright © 2016 André Henrique da Silva. All rights reserved.
//

import UIKit
import Firebase

class TimelineController: FeedController {

    var follows = [UserUID]()
    
    lazy var followReference: FIRDatabaseReference = {
        return FIRDatabase.database().reference().child("users")
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        loadFollows()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func loadFollows() {
        
        if let currentUID = FIRAuth.auth()?.currentUser?.uid {
            
            followReference.child(currentUID).child("feed").queryOrderedByChild("timestamp").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                
                var newBlabs = [Blab]()
                
                for blab in snapshot.children {
                    let blabObject = Blab(snapshot: blab as! FIRDataSnapshot)
                    newBlabs.append(blabObject)
                }
                
                self.blabs = newBlabs.reverse()
                
                
                }, withCancelBlock: { (error) in
                    
                    self.showAlert(viewController: self, title: oopsTitle, message: (error.localizedDescription), buttonTitle: okTitle)
                    return
            })
        }
    }
}
