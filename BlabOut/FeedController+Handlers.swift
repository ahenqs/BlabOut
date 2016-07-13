//
//  FeedController+Handlers.swift
//  BlabOut
//
//  Created by André Henrique da Silva on 09/07/2016.
//  Copyright © 2016 André Henrique da Silva. All rights reserved.
//

import Foundation
import UIKit
import Firebase

extension FeedController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func resetStatus() {
        self.statusTextfield.text = statusPlaceholder
        self.statusTextfield.textColor = UIColor.lightGrayColor()
        self.statusTextHeightConstraint?.constant = 53.0
    }
    
    func handlePost() {
        
        hideKeyboard()
        
        postButton.enabled = false
        photoButton.enabled = false
        
        if statusTextfield.text?.characters.count == 0 || statusTextfield.textColor == UIColor.lightGrayColor() {
            postButton.enabled = true
            photoButton.enabled = true
            
            showAlert(viewController: self, title: oopsTitle, message: "Invalid data to post.", buttonTitle: okTitle)
            
            return
        }
        
        guard let status = statusTextfield.text else {
            postButton.enabled = true
            photoButton.enabled = true
            
            showAlert(viewController: self, title: oopsTitle, message: "Invalid data to post.", buttonTitle: okTitle)
            
            return
        }
        
        if let loggedInUser = user {
            
            if let image = photoImageView.image {
                self.progressBar.setProgress(0.0, animated: false)
                self.progressBar.hidden = false
                
                //upload image
                let uniqueID = NSUUID().UUIDString
                let randomValue   = Int(arc4random_uniform(UInt32(999999)))
                let uniqueImageID = "\(uniqueID)-\(randomValue).png"
                
                let storageReference = FIRStorage.storage().reference().child("status_images").child(uniqueImageID)
                
                if let uploadImageData = UIImagePNGRepresentation(image) {
                    
                    let task = storageReference.putData(uploadImageData, metadata: nil, completion: { (metadata, error) in
                        
                        //image uploaded successfully
                        if error == nil {
                            
                            if let imageURL = metadata?.downloadURL()?.absoluteString {
                                
                                if let blab: Blab = Blab(user: loggedInUser, text: status, photo: imageURL) {
                                    
                                    self.blabReference.childByAutoId().updateChildValues(blab.toAnyObject()) { (error, reference) in
                                        
                                        let blabID = reference.key
                                        
                                        self.postButton.enabled = true
                                        self.photoButton.enabled = true
                                        
                                        if error != nil {
                                            self.showAlert(viewController: self, title: oopsTitle, message: (error?.localizedDescription)!, buttonTitle: okTitle)
                                            
                                            return
                                        }
                                        
                                        let currentUID = FIRAuth.auth()?.currentUser?.uid
                                        
                                        //update my feed with my blab
                                        
                                        self.userReference.child(currentUID!).child("feed").child(blabID).setValue(blab.toAnyObject(), withCompletionBlock: { (err1, ref1) in
                                            
                                            if err1 != nil {
                                                self.showAlert(viewController: self, title: oopsTitle, message: (err1?.localizedDescription)!, buttonTitle: okTitle)
                                                return
                                            }
                                            
                                            // TODO: update followers' feeds
                                            
                                            self.userReference.child(currentUID!).child("followers").observeSingleEventOfType(.Value, withBlock: { (shot) in
                                                
                                                var followers = [UserUID]()
                                                
                                                if shot.childrenCount > 0 {
                                                    
                                                    let c = Connection(snapshot: shot)
                                                    
                                                    followers = c.users
                                                    
                                                    if followers.count > 0 {
                                                        
                                                        for UID in followers {
                                                            
                                                            self.userReference.child(UID).child("feed").child(blabID).setValue(blab.toAnyObject(), withCompletionBlock: { (err, r) in
                                                                
                                                                if err != nil {
                                                                    
                                                                    self.showAlert(viewController: self, title: oopsTitle, message: (err?.localizedDescription)!, buttonTitle: okTitle)
                                                                    return
                                                                }
                                                                
                                                                self.progressBar.hidden = true
                                                                
                                                                self.resetStatus()
                                                                
                                                                self.removePhoto()
                                                            })
                                                            
                                                        }
                                                        
                                                    }
                                                } else {
                                                    self.progressBar.hidden = true
                                                    
                                                    self.resetStatus()
                                                    
                                                    self.removePhoto()
                                                }
                                                
                                            })
                                            
                                        })
                                    }
                                }
                            }
                            
                        } else {
                            self.progressBar.hidden = true
                            self.postButton.enabled = true
                            self.photoButton.enabled = true
                            
                            //no image due to error upload
                            self.showAlert(viewController: self, title: oopsTitle, message: (error?.localizedDescription)!, buttonTitle: okTitle)
                            return
                        }
                    })
                    
                    // Add a progress observer to an upload task
                    task.observeStatus(.Progress) { snapshot in
                        // Upload reported progress
                        if let progress = snapshot.progress {
                            let percentComplete = Float(progress.completedUnitCount) / Float(progress.totalUnitCount)
                            
                            self.progressBar.setProgress(percentComplete, animated: true)
                            
                            if (percentComplete >= 1.0) {
                                self.progressBar.hidden = true
                            }
                        }
                    }
                }
                
            } else {
                if let blab: Blab = Blab(user: loggedInUser, text: status) {
                    
                    blabReference.childByAutoId().updateChildValues(blab.toAnyObject()) { (error, reference) in
                        
                        self.postButton.enabled = true
                        self.photoButton.enabled = true
                        
                        if error != nil {
                            self.showAlert(viewController: self, title: oopsTitle, message: (error?.localizedDescription)!, buttonTitle: okTitle)
                            return
                        }
                        
                        let blabID = reference.key
                        
                        let currentUID = FIRAuth.auth()?.currentUser?.uid
                        
                        //update my feed with my blab
                        
                        self.userReference.child(currentUID!).child("feed").child(blabID).setValue(blab.toAnyObject(), withCompletionBlock: { (err1, ref1) in
                            
                            if err1 != nil {
                                self.showAlert(viewController: self, title: oopsTitle, message: (err1?.localizedDescription)!, buttonTitle: okTitle)
                                return
                            }
                            
                            // TODO: update followers' feeds
                            
                            self.userReference.child(currentUID!).child("followers").observeSingleEventOfType(.Value, withBlock: { (shot) in
                                
                                var followers = [UserUID]()
                                
                                if shot.childrenCount > 0 {
                                    
                                    let c = Connection(snapshot: shot)
                                    
                                    followers = c.users
                                    
                                    if followers.count > 0 {
                                        
                                        for UID in followers {
                                            
                                            self.userReference.child(UID).child("feed").child(blabID).setValue(blab.toAnyObject(), withCompletionBlock: { (err, r) in
                                                
                                                if err != nil {
                                                    self.showAlert(viewController: self, title: oopsTitle, message: (err?.localizedDescription)!, buttonTitle: okTitle)
                                                    return
                                                }
                                                
                                                self.resetStatus()
                                            })
                                            
                                        }
                                        
                                    }
                                } else {
                                    self.resetStatus()
                                }
                                
                            })
                            
                        })
                    }
                }
            }
        }
    }
    
    func showImagePicker() {
        //load picker
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }

    
    func togglePhotoButton() {
        
        if photoImageView.image == nil {
            
            showImagePicker()

        } else {
        
            removePhoto()
        }
        
    }
    
    func removePhoto() {
        photoImageView.image = nil
        photoImageView.hidden = true
        photoButton.setTitle("Photo", forState: .Normal)
        photoButton.backgroundColor = UIColor.appOrange()
        photoButton.layer.cornerRadius = 8.0
    }
    
    // MARK: Image picker
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            photoImageView.image = selectedImage
            
            photoImageView.hidden = false
            photoButton.setTitle("Cancel", forState: .Normal)
            photoButton.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
            photoButton.layer.cornerRadius = 0.0
            
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}