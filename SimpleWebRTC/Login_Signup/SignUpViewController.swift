//
//  SignUpViewController.swift
//  SimpleWebRTC
//
//  Created by Umer Farooq on 05/02/2024.
//  Copyright © 2024 n0. All rights reserved.
//

import UIKit
import DropDown

class SignUpViewController: UIViewController, UIImagePickerControllerDelegate & UIGestureRecognizerDelegate, UINavigationControllerDelegate {
    
    let serverWrapper = APIWrapper()
    let dateFormatter = DateFormatter()
    var imgPicker =  UIImagePickerController()
    
   // var imgList = [Media]()
    var u = User()
    
 //second view
    @IBOutlet weak var imgview: UIImageView!
    @IBOutlet weak var outletBtnBack: UIButton!
    @IBOutlet weak var outletBtnNext: UIButton!
    @IBOutlet weak var txtAbout: UITextField!
    @IBOutlet weak var imgabout: UIImageView!
    
    @IBAction func backSignUp(_ sender: Any) {
        
        let controller = self.storyboard!.instantiateViewController(identifier: "firstscreen")
        controller.modalPresentationStyle = .fullScreen
          self.navigationController?.pushViewController(controller, animated: true)
       
    }
    @IBAction func backbtn(_ sender: Any) {
        
        firstScreen.isHidden = false
        SecondScreen.isHidden = true
        imgview.isHidden = true
        txtAbout.isHidden = true
        outletBtnBack.isHidden = true
        btnsignupOutlet.isHidden = true
        imgabout.isHidden = true
       
    }
    
    @IBOutlet weak var imgdisablity: UIImageView!
    @IBOutlet weak var drpdownView: UIView!
    @IBOutlet weak var viewDOB: UIView!
    @IBOutlet weak var txtpassword: UITextField!
    
    @IBOutlet weak var btnsignupOutlet: UIButton!
    @IBOutlet weak var lbldropdown: UILabel!
    
    @IBOutlet weak var firstScreen: UIView!
    @IBOutlet weak var SecondScreen: UIView!
    
    
    @IBAction func btndrpdown(_ sender: Any) {
        let dropDown = DropDown()
        dropDown.anchorView = drpdownView
        dropDown.dataSource = ["Normal","Deff & Mute ","Blind"]
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.lbldropdown.text = "\(item)"
            
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
 
    @IBAction func btnNext(_ sender: Any) {
        
        firstScreen.isHidden = true
        SecondScreen.isHidden = false
        
        imgview.isHidden = false
        txtAbout.isHidden = false
        outletBtnBack.isHidden = false
        btnsignupOutlet.isHidden = false
        imgabout.isHidden = false
        
        self.view.addSubview(imgview)
        self.view.addSubview(txtAbout)
        self.view.addSubview(outletBtnBack)
        self.view.addSubview(btnsignupOutlet)
        self.view.addSubview(imgabout)
    }
    
    @IBAction func btnSignup(_ sender: Any) {
        
        
        
        if txtName.text != ""{
        if let fullName = txtName.text {
            let fullNameComponents = fullName.components(separatedBy: " ")
            if let firstName = fullNameComponents.first {
               
                u.Fname = firstName
            }
            if fullNameComponents.count >= 2 {
                let lastName = fullNameComponents.dropFirst().joined(separator: " ")
                        
                u.Lname = lastName
            }
        }
        }
        else{
            txtName.layer.borderColor = CGColor.init(red: 1, green: 0, blue: 0, alpha: 1)
        }
        
       
        if (txtpassword.text != "")  && (txtconfirmPassword.text != ""){
        if txtpassword.text == txtconfirmPassword.text {
            u.Password = txtpassword.text!
        }
        else{
            txtpassword.layer.borderColor = CGColor.init(red: 1, green: 0, blue: 0, alpha: 1)
            txtconfirmPassword.layer.borderColor = CGColor.init(red: 1, green: 0, blue: 0, alpha: 1)
        }
        }
        else{
            txtpassword.layer.borderColor = CGColor.init(red: 1, green: 0, blue: 0, alpha: 1)
            txtconfirmPassword.layer.borderColor = CGColor.init(red: 1, green: 0, blue: 0, alpha: 1)
        }
        
       
        
        if txtemail.text == ""{
            txtemail.layer.borderColor = CGColor.init(red: 1, green: 0, blue: 0, alpha: 1)
        }
        else{
            
            if let fullEmail = txtemail.text {
                let username = fullEmail.components(separatedBy: "@")
                if let UserName = username.first {
                   
                    u.Username = UserName
                }
            }
                
          
            u.Email = txtemail.text!
        }
       
        if lbldropdown.text != "Disability Type"
        {
            u.UserType = lbldropdown.text!
        }
        else{
            lbldropdown.layer.borderColor = CGColor.init(red: 1, green: 0, blue: 0, alpha: 1)
        }
        
        
        u.AccountStatus = "Hi i am using CommFusion"
        u.Status = 0
        if imgname == ""{
            imgview.layer.borderColor = CGColor.init(red: 1, green: 0, blue: 0, alpha: 1)
        }
        else{
        u.ProfilePicture = imgname
        }
        
        if(formattedDate != nil)
        {
       
        u.DateOfBirth = formattedDate
        }
        
        let currentDate = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: currentDate)

        u.RegistrationDate = calendar.date(from: components)!
        u.Status = 1
        u.AccountStatus = "HI I am Using CommFusion"
        
       upload()
    }
    
    func upload(){
        let Url = "http://192.168.31.105:5000/signup"
        
        
        let Dic: [String: Any] = [
            "username": u.Username,
            "date_of_birth": dateFormatter.string(from: u.DateOfBirth),
            "password": u.Password,
            "profile_picture": "/profile_images/"+u.ProfilePicture,
            "email": u.Email,
            "user_type": u.UserType,
            "fname": u.Fname,
            "lname": u.Lname,
            "account_status": u.AccountStatus,
            "status": u.Status,
            "registration_date":  dateFormatter.string(from: u.RegistrationDate)
        ]
       
        serverWrapper.insertData(baseUrl : Url,u: u, userDictionary: Dic) { responseString,error in
            if let error = error {
                print("Error:", error)
            } else {
                print("User signed up successfully")
                        let controller = self.storyboard!.instantiateViewController(identifier: "dashboard")
                        controller.modalPresentationStyle = .fullScreen
                          self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }

    
   
    @IBOutlet weak var txtdob: UIDatePicker!
    @IBOutlet weak var txtconfirmPassword: UITextField!
    @IBOutlet weak var txtemail: UITextField!
    @IBOutlet weak var txtName: UITextField!
    
   
   
    var imgname = ""
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
        {
        if let imageURL = info[.imageURL] as? URL {
                imgname = imageURL.lastPathComponent
               
            print("selected image: \(imgname)")
            
//            let Url = "\(Constants.serverURL)/upload_image"
//            serverWrapper.uploadImage(baseUrl: Url, imageURL: imageURL)
           }
        if let img = info[.originalImage] as? UIImage
        {
            self.imgview.image = img
        }
           picker.dismiss(animated: true, completion: nil)
       }
    
    
    
    func setupUI()
    {
        SecondScreen.isHidden = true
        viewDOB.layer.borderWidth = 1.0
        viewDOB.layer.borderColor = UIColor.gray.cgColor
        viewDOB.layer.cornerRadius = 25
        
        drpdownView.layer.borderWidth = 1.0
        drpdownView.layer.borderColor = UIColor.gray.cgColor
        drpdownView.layer.cornerRadius = 25
        
        txtpassword.layer.borderWidth = 1.0
        txtpassword.layer.borderColor = UIColor.gray.cgColor
        txtpassword.layer.cornerRadius = 25
        
        txtconfirmPassword.layer.borderWidth = 1.0
        txtconfirmPassword.layer.borderColor = UIColor.gray.cgColor
        txtconfirmPassword.layer.cornerRadius = 25
        
        btnsignupOutlet.layer.cornerRadius = 15
        
      imgview.layer.cornerRadius = 57
        
        txtemail.layer.borderWidth = 1.0
        txtemail.layer.borderColor = UIColor.gray.cgColor
        txtemail.layer.cornerRadius = 25
        
        txtName.layer.borderWidth = 1.0
        txtName.layer.borderColor = UIColor.gray.cgColor
        txtName.layer.cornerRadius = 25
    }
    
    var formattedDate: Date = Date()

    override func viewDidLoad() {
        super.viewDidLoad()
        
            self.setupUI()
              
            self.imgPicker.delegate = self
            self.txtdob.datePickerMode = .date
            self.txtdob.date = Date()
            self.txtdob.addTarget(self, action: #selector(self.datePickerValueChanged(_:)), for: .valueChanged)
  
     
               
        imgview.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imgViewTapped(_:)))
        imgview.addGestureRecognizer(tapGesture)
        
        let tapscreen = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapscreen.delegate = self
                self.view.addGestureRecognizer(tapscreen)
        
       
    }
     
    @objc func imgViewTapped(_ sender: Any)
    {
        self.present(imgPicker, animated: true,completion: nil)
    }
    
    @objc func hideKeyboard() {
            self.view.endEditing(true)
        }
    
    
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date

       
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let Date = dateFormatter.string(from: selectedDate)
        print("New Date Format : \(Date)")
        formattedDate = dateFormatter.date(from: Date)!
    }
    
    

}

