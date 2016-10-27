//
//  ViewExtension.swift
//  BlabOut
//
//  Created by André Henrique da Silva on 06/07/2016.
//  Copyright © 2016 André Henrique da Silva. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func addConstraintWithFormat(_ format: String, views: UIView...) {
        
        var viewsDictionary = [String: UIView]()
        
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            viewsDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }
    
    func spacerView() -> UIView {
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 10.0, height: self.frame.height))
        return view
    }
}
