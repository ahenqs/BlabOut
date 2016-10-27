//
//  User.swift
//  BlabOut
//
//  Created by André Henrique da Silva on 06/07/2016.
//  Copyright © 2016 André Henrique da Silva. All rights reserved.
//

import Foundation
import Firebase

let kName = "name"
let kProfileImageURL = "profileImageURL"
let kUID = "uid"

struct User: Mappable {
    let uid: String
    let name: String
    let profileImageURL: String
    let itemReference: FIRDatabaseReference?
    
    init(uid: String, name: String, imageURL: String = "") {
        self.uid = uid
        self.name = name
        self.profileImageURL = imageURL
        self.itemReference = nil
    }
    
    // MARK: Mappable
    init(snapshot: FIRDataSnapshot) {
        uid = snapshot.key
        itemReference = snapshot.ref
        
        if let dict = snapshot.value! as? NSDictionary, let username = dict[kName] as? String {
            name = username
        } else {
            name = ""
        }
        
        if let dict = snapshot.value! as? NSDictionary, let url = dict[kProfileImageURL] as? String {
            profileImageURL = url
        } else {
            profileImageURL = ""
        }
    }
    
    func toAnyObject() -> [String : AnyObject] {
        return [kUID: self.uid as AnyObject, kName: self.name as AnyObject, kProfileImageURL: self.profileImageURL as AnyObject]
    }
    
}
