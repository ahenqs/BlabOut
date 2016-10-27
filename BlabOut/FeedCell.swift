//
//  FeedCollectionViewCell.swift
//  StoryboardLess
//
//  Created by André Henrique da Silva on 07/07/2016.
//  Copyright © 2016 André Henrique da Silva. All rights reserved.
//

import UIKit

class FeedCell: UICollectionViewCell {
    
    var blab: Blab? {
        didSet {
            statusTextLabel.text = blab?.statusText
            
            let formatter = DateFormatter()
            formatter.dateStyle = DateFormatter.Style.long
            formatter.timeStyle = .medium
            
            detailLabel.text = formatter.string(from: (blab?.timestamp)! as Date)
            usernameLabel.text = blab?.user!.name
            
            setupConstraints()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 20.0
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(named: "user")
        return imageView
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14.0)
        label.textColor = UIColor.appBlue()
        return label
    }()
    
    let statusTextLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.textColor = UIColor.gray
        label.numberOfLines = 0
        label.textAlignment = .justified
        return label
    }()
    
    let detailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11.0)
        label.textColor = UIColor.lightGray
        return label
    }()
    
    let statusPhotoView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.isHidden = true
        view.layer.masksToBounds = true
        return view
    }()
    
    func setupViews() {
        
        backgroundColor = UIColor.white
        addSubview(profileImageView)
        addSubview(usernameLabel)
        addSubview(statusTextLabel)
        addSubview(detailLabel)
        addSubview(statusPhotoView)
    }
    
    func setupConstraints() {
        
        self.removeConstraints(self.constraints)
        
        addConstraintWithFormat("H:|-[v0(40)]-[v1]|", views: profileImageView, usernameLabel)
        addConstraintWithFormat("H:|-[v0(40)]-[v1]|", views: profileImageView, detailLabel)
        addConstraintWithFormat("H:[v0(==v1)]", views: detailLabel, usernameLabel)
        
        addConstraintWithFormat("H:|-[v0]-|", views: statusTextLabel)
        
        if blab?.user?.profileImageURL != "" {
            profileImageView.loadImageUsingCacheWithUrlString((blab?.user?.profileImageURL)!)
        }
        
        if blab?.statusPhoto != "" {
            statusPhotoView.isHidden = false
            addConstraintWithFormat("H:|[v0]|", views: statusPhotoView)
            addConstraintWithFormat("V:|-[v0(40)]-[v1(\((blab?.statusTextHeight)!))]-[v2(\(self.frame.width))]", views: profileImageView ,statusTextLabel, statusPhotoView)
            
            statusPhotoView.loadImageUsingCacheWithUrlString((blab?.statusPhoto)!, style: .gray)
            
        } else {
            statusPhotoView.isHidden = true
            addConstraintWithFormat("V:|-[v0(40)]-[v1(\((blab?.statusTextHeight)!))]", views: profileImageView ,statusTextLabel)
        }
        
        addConstraintWithFormat("V:|-10-[v0(20)]-6-[v1(13)]", views: usernameLabel, detailLabel)//, statusTextLabel)
        
    }
}
