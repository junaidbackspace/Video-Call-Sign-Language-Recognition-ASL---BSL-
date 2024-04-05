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

class ProfileSettingsViewController: UIViewController, UIImagePickerControllerDelegate & UIGestureRecognizerDelegate, UINavigationControllerDelegate {
    
    
    
    var imgPicker =  UIImagePickerController()
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
        {
            if let img = info[.originalImage] as? UIImage
            {
                self.profilepic.image = img
            }
            imgPicker.dismiss(animated: true, completion: nil)
        }
    
    var name = ""
    var currentpass = ""
    var About = ""
    var newpass = ""
    var confirmpass = ""
    
    var profile = ""
    var distype = ""
    
    @IBAction func btnback(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func btnSave(_ sender: Any) {
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
            }
        
        else{
            if let image = UIImage(named: "two_Fingers_Sign", in: Bundle.main, compatibleWith: nil) {
                imgLangType.image = image
                    }
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
        openImagePicker()
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
    let urlString = "\(Constants.serverURL)\(profile)"

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
        
       profilepic.isUserInteractionEnabled = true

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imgViewTapped(_:)))
       profilepic.addGestureRecognizer(tapGesture)

        imgPicker.delegate = self

        let tapscreen = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapscreen.delegate = self
                self.view.addGestureRecognizer(tapscreen)
    }
    @objc func imgViewTapped(_ sender: Any)
    {
        openImagePicker()
    }
    func openImagePicker() {
        imgPicker.sourceType = .photoLibrary // or .camera if you want to use the camera
       present(imgPicker, animated: true, completion: nil)
    }

    @objc func hideKeyboard() {
            self.view.endEditing(true)
        }
    
    
}
