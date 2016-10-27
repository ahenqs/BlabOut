//
//  Alert.swift
//  BlabOut
//
//  Created by André Henrique da Silva on 13/07/2016.
//  Copyright © 2016 André Henrique da Silva. All rights reserved.
//

import Foundation
import UIKit

protocol AlertMessage {
    func showAlert(viewController: UIViewController, title: String, message: String, buttonTitle: String)
}

extension AlertMessage {
    func showAlert(viewController: UIViewController, title: String, message: String, buttonTitle: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: buttonTitle, style: .default, handler: nil)
        
        alertController.addAction(okAction)
        
        viewController.present(alertController, animated: true, completion: nil)
    }
}
