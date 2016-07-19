//
//  Connection.swift
//  BlabOut
//
//  Created by André Henrique da Silva on 11/07/2016.
//  Copyright © 2016 André Henrique da Silva. All rights reserved.
//

import Foundation
import Firebase

public typealias UserUID = String

enum RelationType {
    case Follows
    case Followers
}

struct Connection: Mappable {
    
    var users = [UserUID]()
    
    var relation: RelationType?

    init(snapshot: FIRDataSnapshot) {
        
        let total = snapshot.value!.count

        let arr = snapshot.value as! NSArray
        
        var array = [UserUID]()
        
        for i in 0..<total {
            
            if let s: String = arr[i] as? String {
                array.append(s)
            }
        }
        
        self.users = array
        
    }
    
    func toAnyObject() -> [String : AnyObject] {
        return ["users": users]
    }
}