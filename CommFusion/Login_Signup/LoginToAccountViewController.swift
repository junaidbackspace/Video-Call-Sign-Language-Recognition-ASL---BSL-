//
//  LoginToAccountViewController.swift
//  SimpleWebRTC
//
//  Created by Umer Farooq on 04/02/2024.
//  Copyright © 2024 n0. All rights reserved.
//

import UIKit

class LoginToAccountViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var serverWrapper = APIWrapper()
    var logindefaults = UserDefaults()
    
    var loadingView: UIView!
    var activityIndicator: UIActivityIndicatorView!
    var loadingLabel: UILabel!
    
    
    @IBAction func backLogin(_ sender: Any) {
        let controller = self.storyboard!.instantiateViewController(identifier: "firstscreen")
        controller.modalPresentationStyle = .fullScreen
          self.navigationController?.pushViewController(controller, animated: true)
    }
  
    @IBOutlet weak var txtemail: UITextField!
    
    @IBOutlet weak var btnlogin: UIButton!
    @IBOutlet weak var txtpassword: UITextField!
    @IBAction func btnloginAct(_ sender: Any) {
        
       
        showLoadingView()
        
        var u = User()
        u.Username = txtemail.text!
        u.Password = txtpassword.text!
        let Url = "\(Constants.serverURL)/user/login"

        let Dic: [String: Any] = [
            "email": u.Username,
            "password": u.Password,
        ]

        serverWrapper.insertData(baseUrl: Url,  userDictionary: Dic) { responseString, error in
            if let error = error {
                print("\n\nError:", error)
                
                self.hideLoadingView()
                
                self.txtemail.layer.borderColor = CGColor.init(red: 1, green: 0, blue: 0, alpha: 1)
                self.txtpassword.layer.borderColor = CGColor.init(red: 1, green: 0, blue: 0, alpha: 1)
            } else {
                if let responseString = responseString {
                    print("login Server response:", responseString)
                    
                    do {
                        if let responseData = responseString.data(using: .utf8) {
                            do {
                                let jsonObject = try JSONSerialization.jsonObject(with: responseData, options: [])
                                if let jsonDict = jsonObject as? [String: Any], let userId = jsonDict["user_id"] as? Int {
                                    self.logindefaults.set(userId, forKey: "userID")
                                    
                                    print("login User ID saved successfully: \(userId)")
                                }
                                    if let jsonDict = jsonObject as? [String: Any], let username = jsonDict["username"] as? String {
                                        
                                        print("Usernmae is : \(username)")
                                        self.logindefaults.setValue(username, forKey: "loginedUser")
                                        self.logindefaults.setValue(self.txtpassword.text!, forKey: "userpass")
                                        
                                        
                                        self.hideLoadingView()
                                        
                                        
                                    let controller = self.storyboard!.instantiateViewController(identifier: "dashboard")
                                    controller.modalPresentationStyle = .fullScreen
                                    self.navigationController?.pushViewController(controller, animated: true)
                                    
                                }
                            } catch {
                                self.hideLoadingView()
                                print("Error parsing JSON data: \(error)")
                            }
                        }
                        else{
                            return
                        }
                    } catch {
                        self.hideLoadingView()
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
//        addDoneButtonToKeyboard(for: txtemail)
//        addDoneButtonToKeyboard(for: txtpassword)
        let tapscreen = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapscreen.delegate = self
                self.view.addGestureRecognizer(tapscreen)
       
        
    }
    @objc func hideKeyboard() {
            self.view.endEditing(true)
        }
    

    func addDoneButtonToKeyboard(for textField: UITextField) {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .close, target: textField, action: #selector(UIResponder.resignFirstResponder))
        toolbar.items = [doneButton]
        
        textField.inputAccessoryView = toolbar
    }

    
    @IBAction func btnForgotpass(_ sender: Any) {

    }
    
    @IBAction func btn_Signup(_ sender: Any) {
        let controller = self.storyboard!.instantiateViewController(identifier: "signupscreen")
        controller.modalPresentationStyle = .fullScreen
          self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func showLoadingView() {
        setupLoading()
        view.addSubview(loadingView)
    }
    
    // Function to hide loading view
    func hideLoadingView() {
        loadingView.removeFromSuperview()
    }
    func setupLoading(){
        // Create loading view
        loadingView = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: 100))
        loadingView.center = view.center
        loadingView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        view.addSubview(loadingView)
        
        // Add activity indicator
        activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
        activityIndicator.center = CGPoint(x: loadingView.frame.size.width / 2, y: loadingView.frame.size.height / 3)
        loadingView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        // Add loading label
        loadingLabel = UILabel(frame: CGRect(x: 0, y: activityIndicator.frame.origin.y + activityIndicator.frame.size.height + 10, width: loadingView.frame.size.width, height: 20))
        loadingLabel.text = "Loading..."
        loadingLabel.textColor = UIColor.white
        loadingLabel.textAlignment = .center
        loadingLabel.font = UIFont.systemFont(ofSize: 16)
        loadingView.addSubview(loadingLabel)
        
        // Rotate animation for the activity indicator
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(Double.pi * 2.0)
        rotateAnimation.duration = 1.0
        rotateAnimation.repeatCount = .infinity
        activityIndicator.layer.add(rotateAnimation, forKey: nil)
    }
}

