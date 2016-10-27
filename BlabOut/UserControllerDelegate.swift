//
//  UserControllerDelegate.swift
//  BlabOut
//
//  Created by André Henrique da Silva on 11/07/2016.
//  Copyright © 2016 André Henrique da Silva. All rights reserved.
//

import Foundation
import UIKit

protocol UserControllerDelegate: class {
    func didTapActionButton(_ user: User, sender: UIButton)
}
