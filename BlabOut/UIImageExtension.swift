//
//  UIImageExtension.swift
//  BlabOut
//
//  Created by André Henrique da Silva on 11/07/2016.
//  Copyright © 2016 André Henrique da Silva. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {

    func resizeImage(_ newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / self.size.width
        
        let newHeight = self.size.height * scale
        
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
