//
//  Blab.swift
//  BlabOut
//
//  Created by André Henrique da Silva on 09/07/2016.
//  Copyright © 2016 André Henrique da Silva. All rights reserved.
//

import Foundation
import Firebase
import UIKit

let kStatusText = "status_text"
let kStatusPhoto = "status_photo"
let kTimestamp = "timestamp"
let kUser = "user"
let kLikes = "likes"

struct Blab: Mappable {
    
    let key: String
    let itemReference: FIRDatabaseReference?
    let statusText: String
    let statusPhoto: String
    let timestamp: Date?
    var user: User?
    let likes: Int
    
    var statusTextHeight: CGFloat = 0.0
    
    init(user usr: User, text: String, photo: String = "", key: String = "", likes: Int = 0) {
        self.key = key
        self.itemReference = nil
        
        self.statusText = text
        self.statusPhoto = photo
        self.timestamp = Date()
        self.user = usr
        self.likes = likes
    }
    
    // MARK: Mappable
    init(snapshot: FIRDataSnapshot) {
        self.key = snapshot.key
        self.itemReference = snapshot.ref
        
        if let dict = snapshot.value! as? NSDictionary, let text = dict[kStatusText] as? String {
            self.statusText = text
        } else {
            self.statusText = ""
        }
        
        if let dict = snapshot.value! as? NSDictionary, let photo = dict[kStatusPhoto] as? String {
            self.statusPhoto = photo
        } else {
            self.statusPhoto = ""
        }
        
        if let dict = snapshot.value! as? NSDictionary, let time = dict[kTimestamp] as? Double {
            self.timestamp = Date(timeIntervalSince1970: time)
        } else {
            self.timestamp = nil
        }
        
        if let dict = snapshot.value! as? NSDictionary, let user = dict[kUser] as? [String: String] {
            self.user = User(uid: user[kUID]!, name: user[kName]!, imageURL: user[kProfileImageURL]!)
        } else {
            self.user = nil
        }
        
        if let dict = snapshot.value! as? NSDictionary, let likes = dict[kLikes] as? Int {
            self.likes = likes
        } else {
            self.likes = 0
        }
    }
    
    func toAnyObject() -> [String : AnyObject] {
        
        return [kStatusText: self.statusText as AnyObject, kStatusPhoto: self.statusPhoto as AnyObject, kTimestamp: self.timestamp!.timeIntervalSince1970 as AnyObject, kUser: (self.user?.toAnyObject())! as AnyObject, kLikes: NSNumber(value: Int32(self.likes) as Int32)]
    }
}

