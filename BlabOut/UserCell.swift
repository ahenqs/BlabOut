//
//  UserCell.swift
//  BlabOut
//
//  Created by André Henrique da Silva on 11/07/2016.
//  Copyright © 2016 André Henrique da Silva. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {
    
    var user: User? {
        didSet {
            photoImageView.loadImageUsingCacheWithUrlString((user?.profileImageURL)!)
            usernameLabel.text = user?.name
        }
    }
    
    let photoImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .ScaleAspectFit
        view.layer.cornerRadius = 20.0
        view.layer.masksToBounds = true
        view.image = UIImage(named: "user")
        return view
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFontOfSize(14.0)
        label.textColor = UIColor.appBlue()
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        
        addSubview(photoImageView)
        addSubview(usernameLabel)
        
        addConstraintWithFormat("H:|-[v0(40)]-[v1]-|", views: photoImageView, usernameLabel)
        addConstraintWithFormat("V:|-5-[v0(40)]-5-|", views: photoImageView)
        addConstraintWithFormat("V:|-15-[v0(20)]", views: usernameLabel)
    }
}
