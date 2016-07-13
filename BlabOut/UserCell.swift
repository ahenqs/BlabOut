//
//  UserCell.swift
//  BlabOut
//
//  Created by André Henrique da Silva on 11/07/2016.
//  Copyright © 2016 André Henrique da Silva. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {
    
    weak var delegate: UserControllerDelegate?
    
    var user: User? {
        didSet {
            photoImageView.loadImageUsingCacheWithUrlString((user?.profileImageURL)!)
            usernameLabel.text = user?.name
        }
    }
    
    var hasFollowed = false {
        didSet {
            if self.hasFollowed {
                actionButton.setTitle("Unfollow", forState: .Normal)
                actionButton.backgroundColor = UIColor.darkGrayColor()
            } else {
                actionButton.setTitle("Follow", forState: .Normal)
                actionButton.backgroundColor = UIColor.appOrange()
            }
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
    
    lazy var actionButton: UIButton = {
        let button = UIButton(type: .Custom)
        button.backgroundColor = UIColor.appOrange()
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.titleLabel?.font = Font.smallBoldLabel
        button.setTitle("Follow", forState: .Normal)
        button.layer.cornerRadius = 5.0
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(UserCell.handleTapAction(_:)), forControlEvents: .TouchUpInside)
        return button
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.separatorInset = UIEdgeInsetsMake(0.0, 10.0, 0.0, 10.0)
        self.layoutMargins = UIEdgeInsetsMake(0.0, 10.0, 0.0, 10.0)
        self.selectionStyle = .None
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        
        addSubview(photoImageView)
        addSubview(usernameLabel)
        addSubview(actionButton)
        
        addConstraintWithFormat("H:|-[v0(40)]-[v1]-[v2(60)]-|", views: photoImageView, usernameLabel, actionButton)
        addConstraintWithFormat("V:|-5-[v0(40)]-5-|", views: photoImageView)
        addConstraintWithFormat("V:|-15-[v0(20)]", views: usernameLabel)
        addConstraintWithFormat("V:|-10-[v0(30)]", views: actionButton)
    }
    
    @IBAction func handleTapAction(sender: UIButton) {
        
        if let usr = user {
            delegate?.didTapActionButton(usr, sender: sender)
        }
    }
}
