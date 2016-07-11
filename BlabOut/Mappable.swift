//
//  Mappable.swift
//  BlabOut
//
//  Created by André Henrique da Silva on 10/07/2016.
//  Copyright © 2016 André Henrique da Silva. All rights reserved.
//

import Foundation
import Firebase

protocol Mappable {
    init(snapshot: FIRDataSnapshot)
    func toAnyObject() -> [String: AnyObject]
}