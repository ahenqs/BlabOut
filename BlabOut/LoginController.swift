//
//  LoginController.swift
//  StoryboardLess
//
//  Created by André Henrique da Silva on 07/07/2016.
//  Copyright © 2016 André Henrique da Silva. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController, AlertMessage {
    
    lazy var userReference: FIRDatabaseReference = {
        FIRDatabase.database().reference().child("users")
    }()
    
    var bottomConstraint: NSLayoutConstraint?
    
    let backgroundView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "city")
        imageView.contentMode = .ScaleAspectFill
        return imageView
    }()
    
    let darkBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        return view
    }()
    
    let welcomeTextLabel: UILabel = {
        let label = UILabel()
        label.font = Font.bigBoldLabel
        label.textColor = UIColor.whiteColor()
        label.text = "Vestibulum id ligula porta felis euismod semper. Praesent commodo cursus magna, vel scelerisque nisl consectetur et."
        label.numberOfLines = 0
        label.textAlignment = .Center
        label.lineBreakMode = .ByWordWrapping
        return label
    }()
    
    lazy var nameTextfield: UITextField = {
        let textfield = UITextField()
        textfield.borderStyle = .None
        textfield.font = Font.textfield
        textfield.backgroundColor = UIColor.whiteColor()
        textfield.leftViewMode = .Always
        textfield.leftView = textfield.spacerView()
        textfield.placeholder = "Name"
        textfield.autocorrectionType = .No
        textfield.delegate = self
        textfield.hidden = true
        return textfield
    }()
    
    lazy var emailTextfield: UITextField = {
        let textfield = UITextField()
        textfield.borderStyle = .None
        textfield.font = Font.textfield
        textfield.backgroundColor = UIColor.whiteColor()
        textfield.leftViewMode = .Always
        textfield.leftView = textfield.spacerView()
        textfield.placeholder = "E-mail"
        textfield.autocorrectionType = .No
        textfield.autocapitalizationType = .None
        textfield.delegate = self
        textfield.keyboardType = .EmailAddress
        return textfield
    }()
    
    lazy var passwordTextfield: UITextField = {
        let textfield = UITextField()
        textfield.borderStyle = .None
        textfield.font = Font.textfield
        textfield.secureTextEntry = true
        textfield.backgroundColor = UIColor.whiteColor()
        textfield.leftViewMode = .Always
        textfield.leftView = textfield.spacerView()
        textfield.placeholder = "Password"
        textfield.delegate = self
        return textfield
    }()
    
    lazy var continueButton: UIButton = {
        let button = UIButton(type: .Custom)
        button.setTitle("Sign in", forState: .Normal)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.backgroundColor = UIColor.appBlue()
        button.addTarget(self, action: #selector(LoginController.handleLogin(_:)), forControlEvents: .TouchUpInside)
        return button
    }()
    
    lazy var operationButton: UIButton = {
        let button = UIButton(type: .Custom)
        button.setTitle("Not registered yet? Sign up now!", forState: .Normal)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.titleLabel?.font = Font.mediumBoldLabel
        button.backgroundColor = UIColor.clearColor()
        button.addTarget(self, action: #selector(LoginController.toggleLoginType(_:)), forControlEvents: .TouchUpInside)
        return button
    }()
    
    let spacerForKeyboard: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var pictureContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.0, alpha: 0.8)
        view.hidden = true
        view.userInteractionEnabled = true
        return view
    }()
    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .ScaleAspectFit
        imageView.backgroundColor = UIColor.clearColor()
        imageView.image = UIImage(named: "user")
        imageView.userInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(LoginController.showImagePicker))
        tap.numberOfTapsRequired = 1
        imageView.addGestureRecognizer(tap)
        
        return imageView
    }()
    
    lazy var validatePictureButton: UIButton = {
        let button = UIButton(type: .Custom)
        button.setTitle("OK, sign up now", forState: .Normal)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.backgroundColor = UIColor.appBlue()
        button.layer.cornerRadius = 8.0
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(LoginController.handleRegistrationWithImage), forControlEvents: .TouchUpInside)
        return button
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton(type: .Custom)
        button.setTitle("Cancel", forState: .Normal)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.titleLabel?.font = Font.mediumBoldLabel
        button.backgroundColor = UIColor.clearColor()
        button.addTarget(self, action: #selector(LoginController.hideProfilePictureContainerView), forControlEvents: .TouchUpInside)
        return button
    }()
    
    let progressBar: UIProgressView = {
        let view = UIProgressView()
        view.setProgress(0.0, animated: false)
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        
        addKeyboardListeners()
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func setupViews() {
        
        navigationItem.title = "Welcome"
        
        view.backgroundColor = UIColor.whiteColor()
        
        view.addSubview(backgroundView)
        view.addSubview(darkBackgroundView)
        
        let tapToHideKeyboard = UITapGestureRecognizer(target: self, action: #selector(LoginController.hideKeyboard))
        tapToHideKeyboard.numberOfTapsRequired = 1
        darkBackgroundView.addGestureRecognizer(tapToHideKeyboard)

        view.addSubview(welcomeTextLabel)
        view.addSubview(nameTextfield)
        view.addSubview(emailTextfield)
        view.addSubview(passwordTextfield)
        view.addSubview(continueButton)
        view.addSubview(operationButton)
        view.addSubview(spacerForKeyboard)
        
        pictureContainerView.addSubview(profileImageView)
        pictureContainerView.addSubview(validatePictureButton)
        pictureContainerView.addSubview(cancelButton)
        pictureContainerView.addSubview(progressBar)
        view.addSubview(pictureContainerView)
        
        view.addConstraintWithFormat("H:|[v0]|", views: backgroundView)
        view.addConstraintWithFormat("H:|[v0]|", views: darkBackgroundView)
        view.addConstraintWithFormat("H:|-16-[v0]-16-|", views: welcomeTextLabel)
        view.addConstraintWithFormat("H:|-16-[v0]-16-|", views: nameTextfield)
        view.addConstraintWithFormat("H:|-16-[v0]-16-|", views: emailTextfield)
        view.addConstraintWithFormat("H:|-16-[v0]-16-|", views: passwordTextfield)
        view.addConstraintWithFormat("H:|-16-[v0]-16-|", views: continueButton)
        view.addConstraintWithFormat("H:|-16-[v0]-16-|", views: operationButton)
        view.addConstraintWithFormat("H:|[v0]|", views: spacerForKeyboard)
        
        view.addConstraintWithFormat("V:|[v0]|", views: backgroundView)
        view.addConstraintWithFormat("V:|[v0]|", views: darkBackgroundView)

        view.addConstraintWithFormat("V:|-(100@100)-[v0(80@250)]-20-[v1(44)]-8-[v2(==v1)]-8-[v3(==v2)]-8-[v4(50)]-12-[v5(44)]", views: welcomeTextLabel, nameTextfield, emailTextfield, passwordTextfield, continueButton, operationButton)
        
        let constraint = NSLayoutConstraint(item: spacerForKeyboard, attribute: .Top, relatedBy: .Equal, toItem: operationButton, attribute: .Bottom, multiplier: 1.0, constant: -4.0)
        view.addConstraint(constraint)
        
        bottomConstraint = NSLayoutConstraint(item: spacerForKeyboard, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1.0, constant: -3.0)
        view.addConstraint(bottomConstraint!)
        
        
        //image
        view.addConstraintWithFormat("H:|[v0]|", views: pictureContainerView)
        view.addConstraintWithFormat("V:|[v0]|", views: pictureContainerView)
        
        let pictureCenterXContraint = NSLayoutConstraint(item: profileImageView, attribute: .CenterX, relatedBy: .Equal, toItem: pictureContainerView, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
        pictureContainerView.addConstraint(pictureCenterXContraint)
        
        let pictureCenterYContraint = NSLayoutConstraint(item: profileImageView, attribute: .CenterY, relatedBy: .Equal, toItem: pictureContainerView, attribute: .CenterY, multiplier: 1.0, constant: 0.0)
        pictureContainerView.addConstraint(pictureCenterYContraint)
        
        pictureContainerView.addConstraintWithFormat("H:[v0(200)]", views: profileImageView)
        pictureContainerView.addConstraintWithFormat("V:[v0(200)]", views: profileImageView)
        
        pictureContainerView.addConstraintWithFormat("V:[v0(50)]", views: validatePictureButton)
        
        let validateButtonCenterXContraint = NSLayoutConstraint(item: validatePictureButton, attribute: .CenterX, relatedBy: .Equal, toItem: pictureContainerView, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
        pictureContainerView.addConstraint(validateButtonCenterXContraint)
        
        pictureContainerView.addConstraintWithFormat("H:[v0(200)]", views: progressBar)
        pictureContainerView.addConstraintWithFormat("H:[v0(200)]", views: validatePictureButton)
        pictureContainerView.addConstraintWithFormat("H:[v0(==v1)]", views: cancelButton, validatePictureButton)
        
        let cancelButtonCenterXConstraint = NSLayoutConstraint(item: cancelButton, attribute: .CenterX, relatedBy: .Equal, toItem: validatePictureButton, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
        pictureContainerView.addConstraint(cancelButtonCenterXConstraint)
        
        let progressBarCenterXConstraint = NSLayoutConstraint(item: progressBar, attribute: .CenterX, relatedBy: .Equal, toItem: pictureContainerView, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
        pictureContainerView.addConstraint(progressBarCenterXConstraint)

        pictureContainerView.addConstraintWithFormat("V:[v0]-[v1]-[v2]-24-[v3]", views: profileImageView, progressBar, validatePictureButton, cancelButton)

    }
    
    func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    func addKeyboardListeners() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginController.animateWithKeyboard(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginController.animateWithKeyboard(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func animateWithKeyboard(notification: NSNotification) {

        if let userInfo = notification.userInfo {
            let keyboardHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue().height
            let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double
            let curve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as! UInt
            let moveUp = (notification.name == UIKeyboardWillShowNotification)
            
            bottomConstraint?.constant = moveUp ? -keyboardHeight : -3.0
            
            let options = UIViewAnimationOptions(rawValue: curve << 16)
            UIView.animateWithDuration(duration, delay: 0, options: options,
                                       animations: {
                                        self.view.layoutIfNeeded()
                },
                                       completion: nil
            )
        }
    }
}

extension LoginController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        hideKeyboard()
        return true
    }
}
