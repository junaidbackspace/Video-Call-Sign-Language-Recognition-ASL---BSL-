//
//  LoginToAccountViewController.swift
//  SimpleWebRTC
//
//  Created by Umer Farooq on 04/02/2024.
//  Copyright © 2024 n0. All rights reserved.
//

import UIKit

class LoginToAccountViewController: UIViewController {
    var serverWrapper = APIWrapper()
    var logindefaults = UserDefaults()
    
    @IBAction func backLogin(_ sender: Any) {
        let controller = self.storyboard!.instantiateViewController(identifier: "firstscreen")
        controller.modalPresentationStyle = .fullScreen
          self.navigationController?.pushViewController(controller, animated: true)
    }
  
    @IBOutlet weak var txtemail: UITextField!
    
    @IBOutlet weak var btnlogin: UIButton!
    @IBOutlet weak var txtpassword: UITextField!
    @IBAction func btnloginAct(_ sender: Any) {
        
           
        var u = User()
        u.Username = txtemail.text!
        u.Password = txtpassword.text!
        let Url = "\(Constants.serverURL)/login"

        let Dic: [String: Any] = [
            "username": u.Username,
            "password": u.Password,
        ]

        serverWrapper.insertData(baseUrl: Url, u: u, userDictionary: Dic) { responseString, error in
            if let error = error {
                print("Error:", error)
                self.txtemail.layer.borderColor = CGColor.init(red: 1, green: 0, blue: 0, alpha: 1)
                self.txtpassword.layer.borderColor = CGColor.init(red: 1, green: 0, blue: 0, alpha: 1)
            } else {
                if let responseString = responseString {
                    print("login Server response:", responseString)
                    
                    do {
                        let jsonData = responseString.data(using: .utf8)
                        let jsonArray = try JSONSerialization.jsonObject(with: jsonData!, options: []) as? [Any]
                        
                        if let userId = (jsonArray?.first as? [String: Any])?["user_id"] as? Int {
                            self.logindefaults.set(userId, forKey: "userID")
                            print("login User ID saved successfully: \(userId)")
                            
                            print("User sign-in successfully")
                            self.logindefaults.setValue(u.Username, forKey: "loginedUser")
                            let controller = self.storyboard!.instantiateViewController(identifier: "dashboard")
                            controller.modalPresentationStyle = .fullScreen
                            self.navigationController?.pushViewController(controller, animated: true)
                            
                        }else{
                            return
                        }
                    } catch {
                        print("Error parsing JSON data: \(error)")
                    }
                }
                
               
            }
        }

        
        
        
    }
    func setupui()
    {
        txtemail.frame = CGRect(x: txtemail.frame.origin.x,
                                y: txtemail.frame.origin.y,
                                width: txtemail.frame.size.width,
                                height: 80)
        txtemail.layer.borderWidth = 1.0
        txtemail.layer.borderColor = UIColor.gray.cgColor
        txtemail.layer.cornerRadius = 25
        
        
        txtpassword.frame = CGRect(x: txtpassword.frame.origin.x,
                                y: txtpassword.frame.origin.y,
                                width: txtpassword.frame.size.width,
                                height: 80)
        txtpassword.layer.borderWidth = 1.0
        txtpassword.layer.borderColor = UIColor.gray.cgColor
        txtpassword.layer.cornerRadius = 25
        
        
        btnlogin.layer.cornerRadius = 15
    }
    override func viewDidLoad() {
        super.viewDidLoad()
       setupui()
        addDoneButtonToKeyboard(for: txtemail)
        addDoneButtonToKeyboard(for: txtpassword)
        // Do any additional setup after loading the view.
    }
    

    func addDoneButtonToKeyboard(for textField: UITextField) {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .close, target: textField, action: #selector(UIResponder.resignFirstResponder))
        toolbar.items = [doneButton]
        
        textField.inputAccessoryView = toolbar
    }

    
    @IBAction func btnForgotpass(_ sender: Any) {
//        let controller = self.storyboard!.instantiateViewController(identifier: "dashboard")
//        controller.modalPresentationStyle = .fullScreen
//          self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func btn_Signup(_ sender: Any) {
        let controller = self.storyboard!.instantiateViewController(identifier: "signupscreen")
        controller.modalPresentationStyle = .fullScreen
          self.navigationController?.pushViewController(controller, animated: true)
    }
}
