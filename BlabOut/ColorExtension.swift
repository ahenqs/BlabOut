//
//  Colors.swift
//  BlabOut
//
//  Created by André Henrique da Silva on 06/07/2016.
//  Copyright © 2016 André Henrique da Silva. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
//    static func rgb(red red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 1.0) -> UIColor {
//        return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha)
//    }
//    
//    public static func navigationBarColor() -> UIColor {
//        return rgb(red: 248, green: 144, blue: 0)
//    }
//    
//    public static func navigationBarTextColor() -> UIColor {
//        return UIColor.whiteColor()
//    }
//    
//    public static func lighterGrayColor() -> UIColor {
//        return UIColor(white: 0.95, alpha: 1.0)
//    }
    
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha)
    }
    
    public static func navigationBarColor() -> UIColor {
        return rgb(red: 248, green: 144, blue: 0)
    }
    
    public static func navigationBarTextColor() -> UIColor {
        return UIColor.white
    }
    
    public static func lighterGrayColor() -> UIColor {
        return UIColor(white: 0.95, alpha: 1.0)
    }
    
    public static func appBlue() -> UIColor {
        return rgb(red: 3, green: 176, blue: 241)
    }
    
    public static func appOrange() -> UIColor {
        return rgb(red: 253, green: 162, blue: 0)
    }
    
}
