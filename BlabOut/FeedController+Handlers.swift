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
    
    func handlePost() {
        
        hideKeyboard()
        
        postButton.enabled = false
        photoButton.enabled = false
        
        if statusTextfield.text?.characters.count == 0 {
            postButton.enabled = true
            photoButton.enabled = true
            print("Invalid post.")
            return
        }
        
        guard let status = statusTextfield.text else {
            postButton.enabled = true
            photoButton.enabled = true
            print("Invalid post.")
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
                                        
                                        self.postButton.enabled = true
                                        self.photoButton.enabled = true
                                        
                                        if error != nil {
                                            print("Error: \(error?.localizedDescription)")
                                            return
                                        }
                                        
                                        self.progressBar.hidden = true
                                        
                                        self.statusTextfield.text = ""
                                        
                                        self.removePhoto()
                                        
                                        self.statusTextHeightConstraint?.constant = 53.0
                                    }
                                }
                            }
                            
                        } else {
                            self.progressBar.hidden = true
                            self.postButton.enabled = true
                            self.photoButton.enabled = true
                            
                            //no image due to error upload
                            print("Error: \(error?.localizedDescription)")
                            return
                        }
                    })
                    
                    // Add a progress observer to an upload task
                    task.observeStatus(.Progress) { snapshot in
                        // Upload reported progress
                        if let progress = snapshot.progress {
                            let percentComplete = Float(progress.completedUnitCount) / Float(progress.totalUnitCount)
                            print("Progress: \(percentComplete)%...")
                            
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
                            print("Error: \(error?.localizedDescription)")
                            return
                        }
                        
                        self.statusTextfield.text = ""
                        
                        self.statusTextHeightConstraint?.constant = 53.0
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