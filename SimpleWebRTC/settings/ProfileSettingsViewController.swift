//
//  ProfileSettingsViewController.swift
//  SimpleWebRTC
//
//  Created by Umer Farooq on 12/02/2024.
//  Copyright © 2024 n0. All rights reserved.
//

import UIKit
import DropDown
import Kingfisher
import MobileCoreServices
import DKImagePickerController

extension ProfileSettingsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            // Do something with the picked image
        }
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

class ProfileSettingsViewController: UIViewController {
    
    
    var serverWrapper = APIWrapper()
    var imgPicker =  UIImagePickerController()
    var userid = UserDefaults.standard.integer(forKey: "userID")
    var imageToUpload: URL?

    
    func pickImage() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary // or .camera for camera access
        imagePickerController.mediaTypes = [kUTTypeImage as String]
        present(imagePickerController, animated: true, completion: nil)
    }

    
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
//        {
//        if let imageURL = info[.imageURL] as? URL {
//
//            imageToUpload = imageURL
//        }
//
//            if let img = info[.originalImage] as? UIImage
//            {
//                self.profilepic.image = img
//                let Url = "\(Constants.serverURL)/user/uploadprofilepicture/\(userid)"
//
//                // Call uploadImage function within a do-catch block
//                do {
//                    try self.serverWrapper.uploadImage(baseUrl: Url, imageURL: self.imageToUpload!)
//                } catch {
//                    print("Error uploading image:", error)
//                    // Handle error uploading image
//                }
//                do {
//                    let toastView = ToastView(message: "Profile Picture updated successfully")
//                    toastView.show(in: self.view)
//                }
//            }
//            imgPicker.dismiss(animated: true, completion: nil)
//        }
    
    var name = ""
    var currentpass = ""
    var About = ""
    var newpass = ""
    var confirmpass = ""
    
    var profile = ""
    var distype = ""
    var LangType = ""
    
    @IBAction func btnback(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func btnSave(_ sender: Any) {
        
        
        if verifyPass(){
            
            print("\n\nin updating user profile...")
            let Url = "\(Constants.serverURL)/user/update-profile"

            
            let fullName = txtname.text!

            
            let components = fullName.components(separatedBy: " ")
            let fname = components.first ?? ""
            let lname = components.dropFirst().joined(separator: " ")

            
            let requestBody = updateUserProfile( user_id : userid,
                                                current_password : currentpass,
                                                new_password: newpass,
                                                new_fname : fname,
                                                new_lname : lname,
                                                new_bio_status : txtabout.text!,
                                                new_disability_type: lblDisablity.text!)
           
            
            serverWrapper.putRequest(urlString: Url, requestBody: requestBody) { data, response, error in
                if let error = error {
                        print("Error: \(error)")
                        return
                    }

                    guard let httpResponse = response as? HTTPURLResponse else {
                        print("Invalid HTTP response")
                        return
                    }

                    if httpResponse.statusCode == 200 {
                        
                        let toastView = ToastView(message: "Details updated successfully")
                        toastView.show(in: self.view)
                    }
            }
        
        }

    }

    
    @IBOutlet weak var txtConfirmPass: UITextField!
    @IBOutlet weak var txtNewPass: UITextField!
    @IBOutlet weak var txtCurrentpass: UITextField!
    @IBOutlet weak var ViewLangtype: UIView!
    @IBAction func btnLangType(_ sender: Any) {
        let dropDown = DropDown()
        dropDown.anchorView = ViewLangtype
        dropDown.dataSource = ["ASL","BSL"]
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.lblLangType.text = "\(item)"
            
            if ( item == "ASL")
            {
            if let image = UIImage(named: "disablity_Sign", in: Bundle.main, compatibleWith: nil) {
                imgLangType.image = image
                    }
                UserDefaults.standard.set("ASL", forKey: "SignType")
            }
        
        else{
            if let image = UIImage(named: "two_Fingers_Sign", in: Bundle.main, compatibleWith: nil) {
                imgLangType.image = image
                    }
            UserDefaults.standard.set("BSL", forKey: "SignType")
            }
            
        }
        dropDown.show()
    }
    @IBOutlet weak var lblLangType: UILabel!
    @IBOutlet weak var imgLangType: UIImageView!
    @IBOutlet weak var imgdisablity: UIImageView!
    @IBOutlet weak var lblDisablity: UILabel!
    @IBAction func btndrpdwnDisablity(_ sender: Any) {
        let dropDown = DropDown()
        dropDown.anchorView = disTypeView
        dropDown.dataSource = ["General","Deff & Mute ","Blind"]
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.lblDisablity.text = "\(item)"
            
            if item == "Normal" {
                if let image = UIImage(named: "normalperson", in: Bundle.main, compatibleWith: nil) {
                    print("Normal Entered")
                    imgdisablity.image = image
                }
            } else if item == "Blind" {
                if let image = UIImage(named: "blind", in: Bundle.main, compatibleWith: nil) {
                    imgdisablity.image = image
                }
            } else { 
                if let image = UIImage(named: "deff", in: Bundle.main, compatibleWith: nil) {
                    imgdisablity.image = image
                }
            }
        }
        dropDown.show()
    }

    @IBOutlet weak var disTypeView: UIView!
    @IBOutlet weak var txtabout: UITextField!
    @IBOutlet weak var txtname: UITextField!
    
    @IBOutlet weak var profilepic: UIImageView!
    @IBOutlet weak var lblname: UILabel!
    @IBOutlet weak var lblabout: UILabel!
    
    @IBAction func btn_editProfile(_ sender: Any) {
//        openImagePicker()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    
        txtname?.placeholder = name
        lblname?.text = name
        txtabout?.placeholder = About
        lblabout?.text = About
        lblDisablity?.text = distype
        setup()
        
    }
        
   func setup()
   {
    //Setting ASL byDefault
    GetSignLang()
    
    
    
    let urlString = "\(Constants.serverURL)\(profile)"
    print("\n\n\n\npic: \(urlString)")
    if let url = URL(string: urlString) {
        profilepic.kf.setImage(with: url, placeholder: UIImage(named: "No image found"))
    } else {
        // Handle invalid URL
        print("Invalid URL:", urlString)
    }
    
    if distype == "General" {
        if let image = UIImage(named: "normalperson", in: Bundle.main, compatibleWith: nil) {
            print("Normal Entered")
            imgdisablity.image = image
        }
    } else if distype == "Blind" {
        if let image = UIImage(named: "blind", in: Bundle.main, compatibleWith: nil) {
            imgdisablity.image = image
        }
    } else {
        if let image = UIImage(named: "deff", in: Bundle.main, compatibleWith: nil) {
            imgdisablity.image = image
        }
    
   }
        
       
    }
   

    @objc func hideKeyboard() {
            self.view.endEditing(true)
        }
    
    
    func GetSignLang()
    {
        if UserDefaults.standard.object(forKey: "SignType") == nil {
            
            UserDefaults.standard.set("ASL", forKey: "SignType")
        }
        else{
            LangType = UserDefaults.standard.string(forKey: "SignType")!
          }
        
        //fetching ASL / BSL
        if ( LangType == "ASL")
        {
            lblLangType.text = LangType
        if let image = UIImage(named: "disablity_Sign", in: Bundle.main, compatibleWith: nil) {
            imgLangType.image = image
                }
           
        }

    else{
        lblLangType.text = LangType
        if let image = UIImage(named: "two_Fingers_Sign", in: Bundle.main, compatibleWith: nil) {
            imgLangType.image = image
                }
       
        }
    }
    
    
    func verifyPass()->Bool
    {
        if txtNewPass.text! == "" && txtConfirmPass.text! == ""{
            newpass = currentpass
            confirmpass = currentpass
            return true
            print("pass not changed")
        }
        else{
            if txtNewPass.text == txtConfirmPass.text
            {
                if txtCurrentpass.text == currentpass {
                    
                    //checking new pass and confirm pass
                    
                    newpass = txtNewPass.text!
                    confirmpass = newpass
                    
                    self.txtConfirmPass.layer.borderWidth = 0
                    self.txtCurrentpass.layer.borderWidth = 0
                    self.txtNewPass.layer.borderWidth = 0
                    UserDefaults.standard.set(newpass, forKey: "userpass")
                    return true
                   
                    }
                else{
                 
                    print("Wrong current pass")
                    self.txtCurrentpass.layer.borderWidth = 1.0
                    self.txtCurrentpass.layer.borderColor = UIColor.red.cgColor
                    return false
                   }
                
            }
            else{
                print("new pass and confirm pass not matched")
                self.txtConfirmPass.layer.borderWidth = 1.0
                self.txtConfirmPass.layer.borderColor = UIColor.red.cgColor
                self.txtNewPass.layer.borderWidth = 1.0
                self.txtNewPass.layer.borderColor = UIColor.red.cgColor
                return false
               
            }
            return true
        }
    }
}


class ToastView: UIView {
    // Properties
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    // Initialization
    init(message: String) {
        super.init(frame: .zero)
        configureUI(withMessage: message)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI(withMessage message: String) {
        backgroundColor = UIColor.green.withAlphaComponent(0.5)
        layer.cornerRadius = 10
        clipsToBounds = true
        
        addSubview(messageLabel)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.text = message
        messageLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        messageLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        
     
    }

    
    func show(in view: UIView) {
        view.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50).isActive = true
        widthAnchor.constraint(equalToConstant: 400).isActive = true
        heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        UIView.animate(withDuration: 0.5, animations: {
            self.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.5, delay: 2.0, animations: {
                self.alpha = 0
            }) { _ in
                self.removeFromSuperview()
            }
        }
    }
}

