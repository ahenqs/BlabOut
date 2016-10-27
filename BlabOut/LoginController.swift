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
        imageView.contentMode = .scaleAspectFill
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
        label.textColor = UIColor.white
        label.text = "Vestibulum id ligula porta felis euismod semper. Praesent commodo cursus magna, vel scelerisque nisl consectetur et."
        label.numberOfLines = 0
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    lazy var nameTextfield: UITextField = {
        let textfield = UITextField()
        textfield.borderStyle = .none
        textfield.font = Font.textfield
        textfield.backgroundColor = UIColor.white
        textfield.leftViewMode = .always
        textfield.leftView = textfield.spacerView()
        textfield.placeholder = "Name"
        textfield.autocorrectionType = .no
        textfield.delegate = self
        textfield.isHidden = true
        return textfield
    }()
    
    lazy var emailTextfield: UITextField = {
        let textfield = UITextField()
        textfield.borderStyle = .none
        textfield.font = Font.textfield
        textfield.backgroundColor = UIColor.white
        textfield.leftViewMode = .always
        textfield.leftView = textfield.spacerView()
        textfield.placeholder = "E-mail"
        textfield.autocorrectionType = .no
        textfield.autocapitalizationType = .none
        textfield.delegate = self
        textfield.keyboardType = .emailAddress
        return textfield
    }()
    
    lazy var passwordTextfield: UITextField = {
        let textfield = UITextField()
        textfield.borderStyle = .none
        textfield.font = Font.textfield
        textfield.isSecureTextEntry = true
        textfield.backgroundColor = UIColor.white
        textfield.leftViewMode = .always
        textfield.leftView = textfield.spacerView()
        textfield.placeholder = "Password"
        textfield.delegate = self
        return textfield
    }()
    
    lazy var continueButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Sign in", for: UIControlState())
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.backgroundColor = UIColor.appBlue()
        button.addTarget(self, action: #selector(LoginController.handleLogin(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var operationButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Not registered yet? Sign up now!", for: UIControlState())
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = Font.mediumBoldLabel
        button.backgroundColor = UIColor.clear
        button.addTarget(self, action: #selector(LoginController.toggleLoginType(_:)), for: .touchUpInside)
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
        view.isHidden = true
        view.isUserInteractionEnabled = true
        return view
    }()
    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = UIColor.clear
        imageView.image = UIImage(named: "user")
        imageView.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(LoginController.showImagePicker))
        tap.numberOfTapsRequired = 1
        imageView.addGestureRecognizer(tap)
        
        return imageView
    }()
    
    lazy var validatePictureButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("OK, sign up now", for: UIControlState())
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.backgroundColor = UIColor.appBlue()
        button.layer.cornerRadius = 8.0
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(LoginController.handleRegistrationWithImage), for: .touchUpInside)
        return button
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Cancel", for: UIControlState())
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = Font.mediumBoldLabel
        button.backgroundColor = UIColor.clear
        button.addTarget(self, action: #selector(LoginController.hideProfilePictureContainerView), for: .touchUpInside)
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

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    func setupViews() {
        
        navigationItem.title = "Welcome"
        
        view.backgroundColor = UIColor.white
        
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
        
        let constraint = NSLayoutConstraint(item: spacerForKeyboard, attribute: .top, relatedBy: .equal, toItem: operationButton, attribute: .bottom, multiplier: 1.0, constant: -4.0)
        view.addConstraint(constraint)
        
        bottomConstraint = NSLayoutConstraint(item: spacerForKeyboard, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: -3.0)
        view.addConstraint(bottomConstraint!)
        
        
        //image
        view.addConstraintWithFormat("H:|[v0]|", views: pictureContainerView)
        view.addConstraintWithFormat("V:|[v0]|", views: pictureContainerView)
        
        let pictureCenterXContraint = NSLayoutConstraint(item: profileImageView, attribute: .centerX, relatedBy: .equal, toItem: pictureContainerView, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        pictureContainerView.addConstraint(pictureCenterXContraint)
        
        let pictureCenterYContraint = NSLayoutConstraint(item: profileImageView, attribute: .centerY, relatedBy: .equal, toItem: pictureContainerView, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        pictureContainerView.addConstraint(pictureCenterYContraint)
        
        pictureContainerView.addConstraintWithFormat("H:[v0(200)]", views: profileImageView)
        pictureContainerView.addConstraintWithFormat("V:[v0(200)]", views: profileImageView)
        
        pictureContainerView.addConstraintWithFormat("V:[v0(50)]", views: validatePictureButton)
        
        let validateButtonCenterXContraint = NSLayoutConstraint(item: validatePictureButton, attribute: .centerX, relatedBy: .equal, toItem: pictureContainerView, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        pictureContainerView.addConstraint(validateButtonCenterXContraint)
        
        pictureContainerView.addConstraintWithFormat("H:[v0(200)]", views: progressBar)
        pictureContainerView.addConstraintWithFormat("H:[v0(200)]", views: validatePictureButton)
        pictureContainerView.addConstraintWithFormat("H:[v0(==v1)]", views: cancelButton, validatePictureButton)
        
        let cancelButtonCenterXConstraint = NSLayoutConstraint(item: cancelButton, attribute: .centerX, relatedBy: .equal, toItem: validatePictureButton, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        pictureContainerView.addConstraint(cancelButtonCenterXConstraint)
        
        let progressBarCenterXConstraint = NSLayoutConstraint(item: progressBar, attribute: .centerX, relatedBy: .equal, toItem: pictureContainerView, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        pictureContainerView.addConstraint(progressBarCenterXConstraint)

        pictureContainerView.addConstraintWithFormat("V:[v0]-[v1]-[v2]-24-[v3]", views: profileImageView, progressBar, validatePictureButton, cancelButton)

    }
    
    func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    func addKeyboardListeners() {
        NotificationCenter.default.addObserver(self, selector: #selector(LoginController.animateWithKeyboard(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginController.animateWithKeyboard(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func animateWithKeyboard(_ notification: Notification) {

        if let userInfo = (notification as NSNotification).userInfo {
            let keyboardHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
            let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double
            let curve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as! UInt
            let moveUp = (notification.name == NSNotification.Name.UIKeyboardWillShow)
            
            bottomConstraint?.constant = moveUp ? -keyboardHeight : -3.0
            
            let options = UIViewAnimationOptions(rawValue: curve << 16)
            UIView.animate(withDuration: duration, delay: 0, options: options,
                                       animations: {
                                        self.view.layoutIfNeeded()
                },
                                       completion: nil
            )
        }
    }
}

extension LoginController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        hideKeyboard()
        return true
    }
}
