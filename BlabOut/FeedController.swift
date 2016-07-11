//
//  FeedController.swift
//  StoryboardLess
//
//  Created by André Henrique da Silva on 07/07/2016.
//  Copyright © 2016 André Henrique da Silva. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "Cell"

let statusPlaceholder = "What's happening?"

class FeedController: UICollectionViewController {
    
    let limitNumberOfBlabs = UInt(10)
    
    var statusTextHeightConstraint: NSLayoutConstraint? = nil
    
    lazy var userReference: FIRDatabaseReference = {
        FIRDatabase.database().reference().child("users")
    }()
    
    lazy var blabReference: FIRDatabaseReference = {
        FIRDatabase.database().reference().child("blabs")
    }()
    
    var user: User?
    
    var blabs = [Blab]() {
        didSet {
            collectionView!.reloadData()
        }
    }
    
    let postContentView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.whiteColor()
        return view
    }()
    
    lazy var statusTextfield: UITextView = {
        let textfield = UITextView()
        textfield.font = Font.textfield
        textfield.backgroundColor = UIColor.whiteColor()
        textfield.autocorrectionType = .No
        textfield.delegate = self
        textfield.text = statusPlaceholder
        textfield.textColor = UIColor.lightGrayColor()
        return textfield
    }()
    
    lazy var postButton: UIButton = {
        let button = UIButton(type: .Custom)
        button.setTitle("Post", forState: .Normal)
        button.titleLabel?.font = UIFont.systemFontOfSize(14.0)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.backgroundColor = UIColor.appBlue()
        button.layer.cornerRadius = 8.0
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(FeedController.handlePost), forControlEvents: .TouchUpInside)
        button.enabled = false
        return button
    }()
    
    lazy var photoButton: UIButton = {
        let button = UIButton(type: .Custom)
        button.setTitle("Photo", forState: .Normal)
        button.titleLabel?.font = UIFont.systemFontOfSize(14.0)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.backgroundColor = UIColor.appOrange()
        button.layer.cornerRadius = 8.0
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(FeedController.togglePhotoButton), forControlEvents: .TouchUpInside)
        button.enabled = false
        return button
    }()
    
    let photoImageView: UIImageView = {
        let view = UIImageView()
        view.hidden = true
        return view
    }()
    
    let progressBar: UIProgressView = {
        let view = UIProgressView()
        view.progress = 0.0
        view.hidden = true
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        //handl url cache
//        let memoryCapacity = 50 * 1024 * 1024
//        let diskCapacity = 50 * 1024 * 1024
//        let urlCache = NSURLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity, diskPath: "BlabOutDiskPath")
//        NSURLCache.setSharedURLCache(urlCache)

        // Register cell classes
        collectionView!.registerClass(FeedCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        setupUI()
        
        setupViews()
        
        checkUserLoggedIn()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func setupViews() {
        
        view.addSubview(postContentView)
        postContentView.addSubview(statusTextfield)
        postContentView.addSubview(postButton)
        postContentView.addSubview(photoImageView)
        postContentView.addSubview(photoButton)
        postContentView.addSubview(progressBar)
        
        view.addConstraintWithFormat("H:|[v0]|", views: postContentView)
        
        statusTextHeightConstraint = NSLayoutConstraint(item: postContentView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 53.0)
        
        view.addConstraint(statusTextHeightConstraint!)
        
        let postContentViewTopConstraint = NSLayoutConstraint(item: postContentView, attribute: .Top, relatedBy: .Equal, toItem: topLayoutGuide, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        view.addConstraint(postContentViewTopConstraint)
        
        view.addConstraintWithFormat("H:|[v0]|", views: collectionView!)
        view.addConstraintWithFormat("V:[v0][v1]", views: postContentView, collectionView!)
        
        let bottomContraint = NSLayoutConstraint(item: collectionView!, attribute: .Bottom, relatedBy: .Equal, toItem: self.bottomLayoutGuide, attribute: .Top, multiplier: 1.0, constant: 0.0)
        
        view.addConstraint(bottomContraint)
        
        postContentView.addConstraintWithFormat("H:|-[v0]-[v1(50)]-[v2(50)]-|", views: statusTextfield, postButton, photoButton)
        postContentView.addConstraintWithFormat("H:|[v0]|", views: progressBar)
        postContentView.addConstraintWithFormat("V:|-5-[v0]-5-[v1]|", views: statusTextfield, progressBar)
        
        postContentView.addConstraintWithFormat("V:|-[v0(40)]", views: postButton)
        postContentView.addConstraintWithFormat("V:|-[v0(40)]", views: photoButton)
        
        let photoImageViewCenterXConstraint = NSLayoutConstraint(item: photoImageView, attribute: .CenterX, relatedBy: .Equal, toItem: photoButton, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
        let photoImageViewCenterYConstraint = NSLayoutConstraint(item: photoImageView, attribute: .CenterY, relatedBy: .Equal, toItem: photoButton, attribute: .CenterY, multiplier: 1.0, constant: 0.0)
        
        postContentView.addConstraints([photoImageViewCenterXConstraint, photoImageViewCenterYConstraint])
        
        postContentView.addConstraintWithFormat("H:[v0(==v1)]", views: photoImageView, photoButton)
        postContentView.addConstraintWithFormat("V:[v0(==v1)]", views: photoImageView, photoButton)
        
        //fix collection view
        collectionView!.contentInset = UIEdgeInsetsMake(10.0, 0.0, 0.0, 0.0)
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    func setupUI() {
        
        navigationController?.navigationBar.barStyle = .BlackTranslucent
        
        navigationItem.title = "Home"
        
        collectionView?.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        collectionView?.alwaysBounceVertical = true
        
        let logoutButton = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: #selector(FeedController.handleLogout))
        navigationItem.leftBarButtonItem = logoutButton
    }
    
    func handleLogout() {
        
        print("Logout")
        
        do {
        
            try FIRAuth.auth()?.signOut()
            
            let loginController = LoginController()
            presentViewController(loginController, animated: true, completion: nil)
            
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    func checkUserLoggedIn() {
        
        if FIRAuth.auth()?.currentUser?.uid == nil {
            performSelector(#selector(FeedController.handleLogout), withObject: nil, afterDelay: 0.0)
        } else {
            
            loadProfile()
            
            loadMyBlabs()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    
        checkUserLoggedIn()
    }
    
    func loadProfile() {

        let profileImageView = UIImageView(frame: CGRectMake(0.0, 0.0, 40.0, 40.0))
        profileImageView.image = UIImage(named: "user")
        profileImageView.layer.cornerRadius = 20.0
        profileImageView.layer.masksToBounds = true
        let profileButton = UIBarButtonItem(customView: profileImageView)
        
        navigationItem.rightBarButtonItem = profileButton

        if let uid = FIRAuth.auth()?.currentUser?.uid {
            
            userReference.child(uid).observeEventType(.Value, withBlock: { (snapshot: FIRDataSnapshot) in
                
                let user = User(snapshot: snapshot)
                
                self.user = user
                
                //enable post button
                self.postButton.enabled = true
                self.photoButton.enabled = true
                
                if let profileImageURL: String = user.profileImageURL {
                    
                    if profileImageURL != "" {
                        profileImageView.loadImageUsingCacheWithUrlString(profileImageURL)
                    }
                    
                } else {
                    profileImageView.image = UIImage(named: "user")
                }
            })
        }
        
    }
    
    func loadFeed() {
        
        FIRDatabase.database().reference().child("blabs").observeEventType(.Value, withBlock: { (snapshot) in
            
            var newBlabs = [Blab]()
            
            for blab in snapshot.children {
                let blabObject = Blab(snapshot: blab as! FIRDataSnapshot)
                newBlabs.append(blabObject)
            }
            
            self.blabs = newBlabs.reverse()

        })
    }
    
    func loadMyBlabs() {
        
        self.blabs = [Blab]()
        
        if let uid = FIRAuth.auth()?.currentUser?.uid { //make sure we have user id before querying
            
            FIRDatabase.database().reference().child("blabs").queryOrderedByChild("user/uid").queryEqualToValue(uid).queryLimitedToLast(limitNumberOfBlabs).observeEventType(.Value, withBlock: { (snapshot) in
                
                var newBlabs = [Blab]()
                
                for blab in snapshot.children {
                    let blabObject = Blab(snapshot: blab as! FIRDataSnapshot)
                    newBlabs.append(blabObject)
                }
                
                self.blabs = newBlabs.reverse()
            })
        }
    }
    
    func hideKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return blabs.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! FeedCell
    
        cell.blab = blabs[indexPath.row]
        return cell
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
        
//        collectionView?.reloadData()
    }
}

extension FeedController: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        var blab = blabs[indexPath.row]
        
        let rect = NSString(string: blab.statusText).boundingRectWithSize(CGSizeMake(collectionView.frame.width, 3000), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(14.0)], context: nil)
        var height = rect.height + 5.0 + 12.0 + 50.0
        
        blab.statusTextHeight = rect.height + 5.0
        
        blabs[indexPath.row] = blab
        
        if blab.statusPhoto != "" {
            height += view.frame.width + 5.0
        }
        
        return CGSizeMake(view.frame.width, height)
    }
}

extension FeedController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        handlePost()
        return true
    }
}

extension FeedController: UITextViewDelegate {
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        changeTextViewConstraints(textView)
        
        return true
    }
    
    func textViewDidChange(textView: UITextView) {
        
        changeTextViewConstraints(textView)
    }
    
    func changeTextViewConstraints(textView: UITextView) {
        let oldSize = textView.frame.size
        
        let newSize = textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.max))
        
        let diff = newSize.height - oldSize.height
        
        let newHeight = (statusTextHeightConstraint?.constant)! + diff
        
        statusTextHeightConstraint?.constant = newHeight > 53.0 ? newHeight > 150.0 ? 150.0 : newHeight : 53.0
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = statusPlaceholder
            textView.textColor = UIColor.lightGrayColor()
        }
    }
}