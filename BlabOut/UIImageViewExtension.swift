//
//  UIImageViewExtension.swift
//  BlabOut
//
//  Created by André Henrique da Silva on 09/07/2016.
//  Copyright © 2016 André Henrique da Silva. All rights reserved.
//

import Foundation
import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    
    func loadImageUsingCacheWithUrlString(_ urlString: String, style: UIActivityIndicatorViewStyle = .white) {
        
        addActivityIndicator(style)
        
        self.image = UIImage(named: "photo")
        
        //search for image in cache
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.removeActivityIndicator()
            self.image = cachedImage
            return
        }
        
        //loads image from url
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            
            DispatchQueue.main.async(execute: {
                
                //download hit an error so lets return out
                if error != nil {
                    self.removeActivityIndicator()
                    print(error)
                    return
                }
                
                self.removeActivityIndicator()
                
                if let downloadedImage = UIImage(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                    self.image = downloadedImage
                }
            })
            
        }).resume()
    }
    
    fileprivate func addActivityIndicator(_ style: UIActivityIndicatorViewStyle = .white) {
//        let indicator = UIActivityIndicatorView(activityIndicatorStyle: style)
//        indicator.translatesAutoresizingMaskIntoConstraints = false
//        indicator.startAnimating()
//        indicator.tag = 99
//        self.addSubview(indicator)
//        
//        let xConstraint = NSLayoutConstraint(item: indicator, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
//        self.addConstraint(xConstraint)
//        
//        let yConstraint = NSLayoutConstraint(item: indicator, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0.0)
//        self.addConstraint(yConstraint)
    }
    
    fileprivate func removeActivityIndicator() {
//        self.removeConstraints(self.constraints)
//        let indicator = self.viewWithTag(99) as! UIActivityIndicatorView
//        indicator.stopAnimating()
//        indicator.removeFromSuperview()
    }
    
}
