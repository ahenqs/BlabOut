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

public let oopsTitle = "Oops!"
public let okTitle = "OK"

class FeedController: UICollectionViewController, AlertMessage {
    
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
        view.backgroundColor = UIColor.white
        return view
    }()
    
    lazy var statusTextfield: UITextView = {
        let textfield = UITextView()
        textfield.font = Font.textfield
        textfield.backgroundColor = UIColor.white
        textfield.autocorrectionType = .no
        textfield.delegate = self
        textfield.text = statusPlaceholder
        textfield.textColor = UIColor.lightGray
        return textfield
    }()
    
    lazy var postButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Post", for: UIControlState())
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.backgroundColor = UIColor.appBlue()
        button.layer.cornerRadius = 8.0
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(FeedController.handlePost), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    lazy var photoButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Photo", for: UIControlState())
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.backgroundColor = UIColor.appOrange()
        button.layer.cornerRadius = 8.0
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(FeedController.togglePhotoButton), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    let photoImageView: UIImageView = {
        let view = UIImageView()
        view.isHidden = true
        return view
    }()
    
    let progressBar: UIProgressView = {
        let view = UIProgressView()
        view.progress = 0.0
        view.isHidden = true
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
        collectionView!.register(FeedCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        setupUI()
        
        setupViews()
        
        checkUserLoggedIn()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    func setupViews() {
        
        view.addSubview(postContentView)
        postContentView.addSubview(statusTextfield)
        postContentView.addSubview(postButton)
        postContentView.addSubview(photoImageView)
        postContentView.addSubview(photoButton)
        postContentView.addSubview(progressBar)
        
        view.addConstraintWithFormat("H:|[v0]|", views: postContentView)
        
        statusTextHeightConstraint = NSLayoutConstraint(item: postContentView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 53.0)
        
        view.addConstraint(statusTextHeightConstraint!)
        
        let postContentViewTopConstraint = NSLayoutConstraint(item: postContentView, attribute: .top, relatedBy: .equal, toItem: topLayoutGuide, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        view.addConstraint(postContentViewTopConstraint)
        
        view.addConstraintWithFormat("H:|[v0]|", views: collectionView!)
        view.addConstraintWithFormat("V:[v0][v1]", views: postContentView, collectionView!)
        
        let bottomContraint = NSLayoutConstraint(item: collectionView!, attribute: .bottom, relatedBy: .equal, toItem: self.bottomLayoutGuide, attribute: .top, multiplier: 1.0, constant: 0.0)
        
        view.addConstraint(bottomContraint)
        
        postContentView.addConstraintWithFormat("H:|-[v0]-[v1(50)]-[v2(50)]-|", views: statusTextfield, postButton, photoButton)
        postContentView.addConstraintWithFormat("H:|[v0]|", views: progressBar)
        postContentView.addConstraintWithFormat("V:|-5-[v0]-5-[v1]|", views: statusTextfield, progressBar)
        
        postContentView.addConstraintWithFormat("V:|-[v0(40)]", views: postButton)
        postContentView.addConstraintWithFormat("V:|-[v0(40)]", views: photoButton)
        
        let photoImageViewCenterXConstraint = NSLayoutConstraint(item: photoImageView, attribute: .centerX, relatedBy: .equal, toItem: photoButton, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        let photoImageViewCenterYConstraint = NSLayoutConstraint(item: photoImageView, attribute: .centerY, relatedBy: .equal, toItem: photoButton, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        
        postContentView.addConstraints([photoImageViewCenterXConstraint, photoImageViewCenterYConstraint])
        
        postContentView.addConstraintWithFormat("H:[v0(==v1)]", views: photoImageView, photoButton)
        postContentView.addConstraintWithFormat("V:[v0(==v1)]", views: photoImageView, photoButton)
        
        //fix collection view
        collectionView!.contentInset = UIEdgeInsetsMake(10.0, 0.0, 0.0, 0.0)
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    func setupUI() {
        
        navigationController?.navigationBar.barStyle = .blackTranslucent
        
        navigationItem.title = "Home"
        
        collectionView?.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        collectionView?.alwaysBounceVertical = true
        
        let logoutButton = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(FeedController.handleLogout))
        navigationItem.leftBarButtonItem = logoutButton
    }
    
    func handleLogout() {
        
        print("Logout")
        
        do {
        
            try FIRAuth.auth()?.signOut()
            
            let loginController = LoginController()
            present(loginController, animated: true, completion: nil)
            
        } catch let error as NSError {
            showAlert(viewController: self, title: oopsTitle, message: error.localizedDescription, buttonTitle: okTitle)
        }
    }
    
    func checkUserLoggedIn() {
        
        if FIRAuth.auth()?.currentUser?.uid == nil {
            perform(#selector(FeedController.handleLogout), with: nil, afterDelay: 0.0)
        } else {
            
            loadProfile()
            
            loadMyBlabs()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        checkUserLoggedIn()
    }
    
    func loadProfile() {

        let profileImageView = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0))
        profileImageView.image = UIImage(named: "user")
        profileImageView.layer.cornerRadius = 20.0
        profileImageView.layer.masksToBounds = true
        let profileButton = UIBarButtonItem(customView: profileImageView)
        
        navigationItem.rightBarButtonItem = profileButton

        if let uid = FIRAuth.auth()?.currentUser?.uid {
            
            userReference.child(uid).observe(.value, with: { (snapshot: FIRDataSnapshot) in
                
                let user = User(snapshot: snapshot)
                
                self.user = user
                
                //enable post button
                self.postButton.isEnabled = true
                self.photoButton.isEnabled = true
                
                if user.profileImageURL != "" {
                    profileImageView.loadImageUsingCacheWithUrlString(user.profileImageURL)
                }
            })
        }
        
    }
    
    func loadFeed() {
        
        FIRDatabase.database().reference().child("blabs").observe(.value, with: { (snapshot) in
            
            var newBlabs = [Blab]()
            
            for blab in snapshot.children {
                let blabObject = Blab(snapshot: blab as! FIRDataSnapshot)
                newBlabs.append(blabObject)
            }
            
            self.blabs = newBlabs.reversed()

        })
    }
    
    func loadMyBlabs() {
        
        self.blabs = [Blab]()
        
        if let uid = FIRAuth.auth()?.currentUser?.uid { //make sure we have user id before querying
            
            FIRDatabase.database().reference().child("blabs").queryOrdered(byChild: "user/uid").queryEqual(toValue: uid).queryLimited(toLast: limitNumberOfBlabs).observe(.value, with: { (snapshot) in
                
                var newBlabs = [Blab]()
                
                for blab in snapshot.children {
                    let blabObject = Blab(snapshot: blab as! FIRDataSnapshot)
                    newBlabs.append(blabObject)
                }
                
                self.blabs = newBlabs.reversed()
            })
        }
    }
    
    func hideKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return blabs.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FeedCell
    
        cell.blab = blabs[(indexPath as NSIndexPath).row]
        return cell
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
        
//        collectionView?.reloadData()
    }
}

extension FeedController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var blab = blabs[(indexPath as NSIndexPath).row]
        
        let rect = NSString(string: blab.statusText).boundingRect(with: CGSize(width: collectionView.frame.width, height: 3000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14.0)], context: nil)
        var height = rect.height + 5.0 + 12.0 + 50.0
        
        blab.statusTextHeight = rect.height + 5.0
        
        blabs[(indexPath as NSIndexPath).row] = blab
        
        if blab.statusPhoto != "" {
            height += view.frame.width + 5.0
        }
        
        return CGSize(width: view.frame.width, height: height)
    }
}

extension FeedController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handlePost()
        return true
    }
}

extension FeedController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        changeTextViewConstraints(textView)
        
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        changeTextViewConstraints(textView)
    }
    
    func changeTextViewConstraints(_ textView: UITextView) {
        let oldSize = textView.frame.size
        
        let newSize = textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude))
        
        let diff = newSize.height - oldSize.height
        
        let newHeight = (statusTextHeightConstraint?.constant)! + diff
        
        statusTextHeightConstraint?.constant = newHeight > 53.0 ? newHeight > 150.0 ? 150.0 : newHeight : 53.0
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = statusPlaceholder
            textView.textColor = UIColor.lightGray
        }
    }
}
