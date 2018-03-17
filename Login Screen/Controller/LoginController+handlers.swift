//
//  LoginController+handlers.swift
//  Login Screen
//
//  Created by Harrison Leath on 2/23/18.
//  Copyright © 2018 Harrison Leath. All rights reserved.
//

import UIKit
import Firebase

extension LoginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func handleRegister() {
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text
            else {
                print("Form is not valid!")
                return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            
            if error != nil {
                print("Create User Error")
                return
            }
            
            guard (user?.uid) != nil else {
                return
            }
            
            //successfully authenticated user
            let imageName = NSUUID().uuidString
            let storageRef = Storage.storage().reference().child("profile_Images").child("\(imageName).png")
            
            if let uploadData = UIImagePNGRepresentation(self.profileImageView.image!) {
                
                let uid = user?.uid
                
                storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                    
                    if error != nil {
                        print(error as Any)
                        return
                    }
                    
                    if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                    
                        let values = ["name":name, "email": email, "profileImageUrl": profileImageUrl]
                        self.registerUerIntoDatabaseWithUID(uid: uid!, values: values as [String : AnyObject])
  
                    }
                })
            }
        }
    }
    
    private func registerUerIntoDatabaseWithUID(uid: String, values: [String: AnyObject]) {
        let ref = Database.database().reference(fromURL: "https://chat-login-92eaf.firebaseio.com/")
        let usersReference = ref.child("users").child(uid)
        usersReference.updateChildValues(values, withCompletionBlock: { (error2, ref) in
            
            if error2 != nil {
                print("error2")
                return
            }
            
            self.dismiss(animated: true, completion: nil)
            print("Saved User successfully into firebase")
        })
    }
    
    
    @objc func handleSelectProfileImageView(_ sender: UITapGestureRecognizer) {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
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
        print("cancelled picker")
        dismiss(animated: true, completion: nil)
    }
    
}
