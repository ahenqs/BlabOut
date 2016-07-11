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
    
    func toggleLoginType(sender: UIButton) {
        
        if let text = continueButton.titleForState(.Normal) {
            
            if text == "Sign in" {
                
                continueButton.setTitle("Sign up", forState: .Normal)
                sender.setTitle("Already registered? Sign in here!", forState: .Normal)
                
                //show name
                nameTextfield.hidden = false
            } else {
                
                continueButton.setTitle("Sign in", forState: .Normal)
                sender.setTitle("Not registered yet? Sign up now!", forState: .Normal)
                
                //hide name
                nameTextfield.hidden = true
            }
        }
    }
    
    func handleLogin(sender: UIButton) {
        
        hideKeyboard()
        
        if let text = continueButton.titleForState(.Normal) {
            
            if text == "Sign in" {
            
                handleSignIn()

            } else {
                
                handleSignUp()
            }
        }
    }
    
    func handleSignIn() {
        print("Signing in...")
        
        guard let email = emailTextfield.text, password = passwordTextfield.text else {
            
            // TODO: Show message with error
            print("Invalid form.")
            return
        }
        
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
        FIRAuth.auth()?.signInWithEmail(email, password: password, completion: { (user, error) in
            
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
            
            if error != nil {
                print("Error: \(error?.localizedDescription)")
                return
            }
            
            self.dismissViewControllerAnimated(true, completion: nil)
        })
    }
    
    func handleSignUp() {
        print("Signing up...")
        
        if (nameTextfield.text?.characters.count == 0 || emailTextfield.text?.characters.count == 0 || passwordTextfield.text?.characters.count == 0) {
            
            // TODO: Show message with error
            print("Invalid form.")
            return
        }
        
        showUploadProfilePictureMessage()
    }
    
    func showUploadProfilePictureMessage() {
        let alertController = UIAlertController(title: "Profile Picture", message: "Would you like to set a profile picture now?", preferredStyle: .Alert)
        
        let uploadAction = UIAlertAction(title: "Yes, choose one now", style: .Cancel) { (action) in
            
            //            self.registerUser(name: name, email: email, password: password)
            
            self.pictureContainerView.hidden = false
            
            self.showImagePicker()
        }
        
        let cancelAction = UIAlertAction(title: "Not now", style: .Default) { action in
        
            guard let name = self.nameTextfield.text, email = self.emailTextfield.text, password = self.passwordTextfield.text else {
                
                // TODO: Show message with error
                print("Invalid form.")
                return
            }
            
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            
            //create auth user
            FIRAuth.auth()?.createUserWithEmail(email, password: password, completion: { (user, error) in
                
                if error != nil {
                    
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    print("Error: \(error?.localizedDescription)")
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
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func handleRegistrationWithImage() {
        
        guard let name = nameTextfield.text, email = emailTextfield.text, password = passwordTextfield.text else {
            
            // TODO: Show message with error
            print("Invalid form.")
            return
        }
        
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()

        registerUser(name: name, email: email, password: password)
    }
    
    func showImagePicker() {
        //load picker
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func registerUser(name name: String, email: String, password: String) {
        //create auth user
        FIRAuth.auth()?.createUserWithEmail(email, password: password, completion: { (user, error) in
            
            if error != nil {
                print("Error: \(error?.localizedDescription)")
                return
            }
            
            //create user with profile picture
            print(user)
            
            if let uid = user?.uid {
                
                if self.profileImageView.image != UIImage(named: "user") {
                
                    //upload image
                    let uniqueID = NSUUID().UUIDString
                    let randomValue   = Int(arc4random_uniform(UInt32(999999)))
                    let uniqueImageID = "\(uniqueID)-\(randomValue).png"
                    
                    let storageReference = FIRStorage.storage().reference().child("profile_images").child(uniqueImageID)
                    
                    //resize profile picture to 100 pixels
                    if let uploadImageData = UIImagePNGRepresentation(self.profileImageView.image!.resizeImage(100.0)) {
                        
                        let task = storageReference.putData(uploadImageData, metadata: nil, completion: { (metadata, error) in
                            
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
                        task.observeStatus(.Progress) { snapshot in
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
    
    func saveUser(user: User) {
        
        self.userReference.child(user.uid).updateChildValues(user.toAnyObject(), withCompletionBlock: { (error, reference) in
            
            if error != nil {
                print("Error: \(error?.localizedDescription)")
                return
            }
            
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
            
            self.dismissViewControllerAnimated(true, completion: nil)
        })
    }
    
    func hideProfilePictureContainerView() {
        pictureContainerView.hidden = true
    }
    
    // MARK: Image Picker
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            profileImageView.image = selectedImage
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
