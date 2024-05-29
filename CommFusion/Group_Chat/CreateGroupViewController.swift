//
//  CreateGroupViewController.swift
//  CommFusion
//
//  Created by Umer Farooq on 30/05/2024.
//  Copyright © 2024 n0. All rights reserved.
//

import UIKit




class CreateGroupViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    
    var imgPicker = UIImagePickerController()
//    var userid = UserDefaults.standard.integer(forKey: "userID")
    var imageToUpload: URL?
    

    @IBOutlet weak var profilepic : UIImageView!
    @IBOutlet weak var grp_Name : UITextField!
    
    
    
   
    override func viewDidLoad() {
        super.viewDidLoad()

        imgPicker.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profilePicTapped))
           profilepic.addGestureRecognizer(tapGesture)
           profilepic.isUserInteractionEnabled = true
        // Do any additional setup after loading the view.
    }
    
    @objc func profilePicTapped() {
    
        print("Profile picture tapped!")
        openImagePicker()
    }
    
    
    @IBAction func btnCreate_Grp(_ sender: Any)
    {
        
    }
    
   
    

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        // Check if the image was captured successfully
        guard let img = info[.originalImage] as? UIImage else {
            print("Failed to retrieve the image")
            return
        }
       
        self.profilepic.image = img
        
        // Save the captured image to the temporary directory
        if let imageData = img.jpegData(compressionQuality: 1.0) {
            let fileManager = FileManager.default
            let tempDirURL = fileManager.temporaryDirectory
            let fileName = "\(UUID().uuidString).jpg"
            let fileURL = tempDirURL.appendingPathComponent(fileName)
            
            do {
                try imageData.write(to: fileURL)
                // Set the image URL to be uploaded
                self.imageToUpload = fileURL
                
               
//                let Url = "\(Constants.serverURL)/user/uploadprofilepicture/\(userid)"
//                
//                // Call uploadImage function within a do-catch block
//                do {
//                    try self.serverWrapper.uploadImage(baseUrl: Url, imageURL: self.imageToUpload!)
//                    let toastView = ToastView(message: "Profile Picture updated successfully")
//                    toastView.show(in: self.view)
//                } catch {
//                    print("Error uploading image:", error)
//                    // Handle error uploading image
//                }
            } catch {
                print("Error saving image to temporary directory:", error)
            }
        }
    }


    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func openImagePicker() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Take Photo", style: .default) { [weak self] (_) in
            self?.imgPicker.sourceType = .camera
            self?.present(self!.imgPicker, animated: true, completion: nil)
        }
        alertController.addAction(cameraAction)
        
        let photoLibraryAction = UIAlertAction(title: "Choose Photo", style: .default) { [weak self] (_) in
            self?.imgPicker.sourceType = .photoLibrary
            self?.present(self!.imgPicker, animated: true, completion: nil)
        }
        alertController.addAction(photoLibraryAction)
        
        let cancelAction = UIAlertAction(title: "Back", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }


}
