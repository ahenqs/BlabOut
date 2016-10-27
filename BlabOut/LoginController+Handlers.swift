//
//  LoginController+Handlers.swift
//  BlabOut
//
//  Created by André Henrique da Silva on 08/07/2016.
//  Copyright © 2016 André Henrique da Silva. All rights reserved.
//

import UIKit
import Firebase

extension LoginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func toggleLoginType(_ sender: UIButton) {
        
        if let text = continueButton.title(for: UIControlState()) {
            
            if text == "Sign in" {
                
                continueButton.setTitle("Sign up", for: UIControlState())
                sender.setTitle("Already registered? Sign in here!", for: UIControlState())
                
                //show name
                nameTextfield.isHidden = false
            } else {
                
                continueButton.setTitle("Sign in", for: UIControlState())
                sender.setTitle("Not registered yet? Sign up now!", for: UIControlState())
                
                //hide name
                nameTextfield.isHidden = true
            }
        }
    }
    
    func handleLogin(_ sender: UIButton) {
        
        hideKeyboard()
        
        if let text = continueButton.title(for: UIControlState()) {
            
            if text == "Sign in" {
            
                handleSignIn()

            } else {
                
                handleSignUp()
            }
        }
    }
    
    func handleSignIn() {
        print("Signing in...")
        
        guard let email = emailTextfield.text, let password = passwordTextfield.text else {
            
            // TODO: Show message with error
            showAlert(viewController: self, title: oopsTitle, message: "All fields required.", buttonTitle: okTitle)
            
            return
        }
        
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            
            UIApplication.shared.endIgnoringInteractionEvents()
            
            if error != nil {
                self.showAlert(viewController: self, title: oopsTitle, message: (error?.localizedDescription)!, buttonTitle: okTitle)
                return
            }
            
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    func handleSignUp() {
        print("Signing up...")
        
        if (nameTextfield.text?.characters.count == 0 || emailTextfield.text?.characters.count == 0 || passwordTextfield.text?.characters.count == 0) {
            
            // TODO: Show message with error
            showAlert(viewController: self, title: oopsTitle, message: "All fields required.", buttonTitle: okTitle)
            return
        }
        
        showUploadProfilePictureMessage()
    }
    
    func showUploadProfilePictureMessage() {
        let alertController = UIAlertController(title: "Profile Picture", message: "Would you like to set a profile picture now?", preferredStyle: .alert)
        
        let uploadAction = UIAlertAction(title: "Yes, choose one now", style: .cancel) { (action) in
            
            //            self.registerUser(name: name, email: email, password: password)
            
            self.pictureContainerView.isHidden = false
            
            self.showImagePicker()
        }
        
        let cancelAction = UIAlertAction(title: "Not now", style: .default) { action in
        
            guard let name = self.nameTextfield.text, let email = self.emailTextfield.text, let password = self.passwordTextfield.text else {
                
                self.showAlert(viewController: self, title: oopsTitle, message: "All fields required.", buttonTitle: okTitle)
                return
            }
            
            UIApplication.shared.beginIgnoringInteractionEvents()
            
            //create auth user
            FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
                
                if error != nil {
                    
                    UIApplication.shared.endIgnoringInteractionEvents()
                    self.showAlert(viewController: self, title: oopsTitle, message: (error?.localizedDescription)!, buttonTitle: okTitle)
                    return
                }
                
                //create user without profile picture

                if let uid = user?.uid {
                    
                    let u = User(uid: uid, name: name)
                    
                    self.saveUser(u)
                }
            })
            
        }
        
        alertController.addAction(uploadAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func handleRegistrationWithImage() {
        
        guard let name = nameTextfield.text, let email = emailTextfield.text, let password = passwordTextfield.text else {
            
            // TODO: Show message with error
            showAlert(viewController: self, title: oopsTitle, message: "All fields required.", buttonTitle: okTitle)
            return
        }
        
        UIApplication.shared.beginIgnoringInteractionEvents()

        registerUser(name: name, email: email, password: password)
    }
    
    func showImagePicker() {
        //load picker
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func registerUser(name: String, email: String, password: String) {
        //create auth user
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            
            if error != nil {
                self.showAlert(viewController: self, title: oopsTitle, message: (error?.localizedDescription)!, buttonTitle: okTitle)
                return
            }
            
            //create user with profile picture
            if let uid = user?.uid {
                
                if self.profileImageView.image != UIImage(named: "user") {
                
                    //upload image
                    let uniqueID = UUID().uuidString
                    let randomValue   = Int(arc4random_uniform(UInt32(999999)))
                    let uniqueImageID = "\(uniqueID)-\(randomValue).png"
                    
                    let storageReference = FIRStorage.storage().reference().child("profile_images").child(uniqueImageID)
                    
                    //resize profile picture to 100 pixels
                    if let uploadImageData = UIImagePNGRepresentation(self.profileImageView.image!.resizeImage(100.0)) {
                        
                        let task = storageReference.put(uploadImageData, metadata: nil, completion: { (metadata, error) in
                            
                            //image uploaded successfully
                            if error == nil {
                                
                                if let imageURL = metadata?.downloadURL()?.absoluteString {
                                    
                                    let userObject = User(uid: uid, name: name, imageURL: imageURL)
                                    self.saveUser(userObject)
                                }
                                
                            } else {
                                
                                //no image due to error upload
                                let userObject = User(uid: uid, name: name)
                                self.saveUser(userObject)
                            }
                        })
                        
                        // Add a progress observer to an upload task
                        task.observe(.progress) { snapshot in
                            // Upload reported progress
                            if let progress = snapshot.progress {
                                let percentComplete = Float(progress.completedUnitCount) / Float(progress.totalUnitCount)
                                print("Progress: \(percentComplete)%...")
                                
                                self.progressBar.setProgress(percentComplete, animated: true)
                            }
                        }
                    }
                    
                } else {
                    //no image
                    let userObject = User(uid: uid, name: name)
                    self.saveUser(userObject)
                    
                }
                
            }
        })
    }
    
    func saveUser(_ user: User) {
        
        self.userReference.child(user.uid).updateChildValues(user.toAnyObject(), withCompletionBlock: { (error, reference) in
            
            if error != nil {
                self.showAlert(viewController: self, title: oopsTitle, message: (error?.localizedDescription)!, buttonTitle: okTitle)
                return
            }
            
            UIApplication.shared.endIgnoringInteractionEvents()
            
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    func hideProfilePictureContainerView() {
        pictureContainerView.isHidden = true
    }
    
    // MARK: Image Picker
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            profileImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}
