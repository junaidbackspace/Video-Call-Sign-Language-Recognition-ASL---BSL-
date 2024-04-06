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
    
    
    var serverWrapper = APIWrapper()
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
    var LangType = ""
    
    @IBAction func btnback(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func btnSave(_ sender: Any) {
        
        
        if verifyPass(){
            
            print("\n\nin updating user profile...")
            let Url = "\(Constants.serverURL)/user/update-profile"

            var userid = UserDefaults.standard.integer(forKey: "userID")

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
                        if let responseData = data {
                            // Parse JSON data
                            do {
                                let json = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any]
                                if let message = json?["message"] as? String, let id = json?["Id"] as? Int {
                                    print("Message: \(message)")
                                    print("ID: \(id)")
                                } else {
                                    print("Invalid JSON format")
                                }
                            } catch {
                                print("Error parsing JSON: \(error)")
                            }
                        } else {
                            print("No data received from the server")
                        }
                    } else {
                        print("Request failed with status code \(httpResponse.statusCode)")
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
    //Setting ASL byDefault
    GetSignLang()
    
    
    
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
