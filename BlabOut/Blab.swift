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
    let timestamp: NSDate?
    var user: User?
    let likes: Int
    
    var statusTextHeight: CGFloat = 0.0
    
    init(user usr: User, text: String, photo: String = "", key: String = "", likes: Int = 0) {
        self.key = key
        self.itemReference = nil
        
        self.statusText = text
        self.statusPhoto = photo
        self.timestamp = NSDate()
        self.user = usr
        self.likes = likes
    }
    
    // MARK: Mappable
    init(snapshot: FIRDataSnapshot) {
        self.key = snapshot.key
        self.itemReference = snapshot.ref
        
        if let text = snapshot.value![kStatusText] as? String {
            self.statusText = text
        } else {
            self.statusText = ""
        }
        
        if let photo = snapshot.value![kStatusPhoto] as? String {
            self.statusPhoto = photo
        } else {
            self.statusPhoto = ""
        }
        
        if let time = snapshot.value![kTimestamp] as? Double {
            self.timestamp = NSDate(timeIntervalSince1970: time)
        } else {
            self.timestamp = nil
        }
        
        if let user = snapshot.value![kUser] as? [String: String] {
            self.user = User(uid: user[kUID]!, name: user[kName]!, imageURL: user[kProfileImageURL]!)
        } else {
            self.user = nil
        }
        
        if let likes = snapshot.value![kLikes] as? Int {
            self.likes = likes
        } else {
            self.likes = 0
        }
    }
    
    func toAnyObject() -> [String : AnyObject] {
        
        return [kStatusText: self.statusText, kStatusPhoto: self.statusPhoto, kTimestamp: self.timestamp!.timeIntervalSince1970, kUser: (self.user?.toAnyObject())!, kLikes: NSNumber(int: Int32(self.likes))]
    }
}

