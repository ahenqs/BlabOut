//
//  UIImageViewExtension.swift
//  BlabOut
//
//  Created by André Henrique da Silva on 09/07/2016.
//  Copyright © 2016 André Henrique da Silva. All rights reserved.
//

import Foundation
import UIKit

let imageCache = NSCache()

extension UIImageView {
    
    func loadImageUsingCacheWithUrlString(urlString: String, style: UIActivityIndicatorViewStyle = .White) {
        
        addActivityIndicator(style)
        
        self.image = UIImage(named: "photo")
        
        //search for image in cache
        if let cachedImage = imageCache.objectForKey(urlString) as? UIImage {
            self.removeActivityIndicator()
            self.image = cachedImage
            return
        }
        
        //loads image from url
        let url = NSURL(string: urlString)
        NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, response, error) in
            
            dispatch_async(dispatch_get_main_queue(), {
                
                //download hit an error so lets return out
                if error != nil {
                    self.removeActivityIndicator()
                    print(error)
                    return
                }
                
                self.removeActivityIndicator()
                
                if let downloadedImage = UIImage(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: urlString)
                    self.image = downloadedImage
                }
            })
            
        }).resume()
    }
    
    private func addActivityIndicator(style: UIActivityIndicatorViewStyle = .White) {
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
    
    private func removeActivityIndicator() {
//        self.removeConstraints(self.constraints)
//        let indicator = self.viewWithTag(99) as! UIActivityIndicatorView
//        indicator.stopAnimating()
//        indicator.removeFromSuperview()
    }
    
}