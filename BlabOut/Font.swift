//
//  Font.swift
//  StoryboardLess
//
//  Created by André Henrique da Silva on 07/07/2016.
//  Copyright © 2016 André Henrique da Silva. All rights reserved.
//

import Foundation
import UIKit

struct Font {
    
    static let textfield: UIFont = {
        return UIFont.systemFont(ofSize: 14.0)
    }()
    
    static let navigationBar: UIFont = {
        return UIFont.boldSystemFont(ofSize: 16.0)
    }()
    
    static let navigationBarButton: UIFont = {
        return UIFont.boldSystemFont(ofSize: 13.0)
    }()
    
    static let smallLabel: UIFont = {
        return UIFont.systemFont(ofSize: 12.0)
    }()
    
    static let smallBoldLabel: UIFont = {
        return UIFont.boldSystemFont(ofSize: 12.0)
    }()
    
    static let mediumLabel: UIFont = {
        return UIFont.systemFont(ofSize: 14.0)
    }()
    
    static let mediumBoldLabel: UIFont = {
        return UIFont.boldSystemFont(ofSize: 14.0)
    }()
    
    static let bigLabel: UIFont = {
        return UIFont.systemFont(ofSize: 18.0)
    }()
    
    static let bigBoldLabel: UIFont = {
        return UIFont.boldSystemFont(ofSize: 18.0)
    }()
}
