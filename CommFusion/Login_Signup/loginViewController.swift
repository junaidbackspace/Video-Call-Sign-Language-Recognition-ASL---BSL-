//
//  loginViewController.swift
//  SimpleWebRTC
//
//  Created by Umer Farooq on 04/02/2024.
//  Copyright © 2024 n0. All rights reserved.
//

import UIKit

class loginViewController: UIViewController {
    @IBOutlet weak var btnSignup: UIButton!
    
    @IBOutlet weak var btnlogin: UIButton!
    @IBOutlet weak var whiteCircleView: UIView!

    @IBAction func btnSignupAct(_ sender: Any) {
        let controller = self.storyboard?.instantiateViewController(identifier: "signupscreen") as! SignUpViewController
        controller.modalPresentationStyle = .fullScreen
          self.navigationController?.pushViewController(controller, animated: true)
    }
    @IBAction func btnloginAct(_ sender: Any) {
        let controller = self.storyboard?.instantiateViewController(identifier: "loginscreen") as! LoginToAccountViewController
        controller.modalPresentationStyle = .fullScreen
          self.navigationController?.pushViewController(controller, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if UserDefaults.standard.integer(forKey: "userID") != 0{
            let controller = self.storyboard!.instantiateViewController(identifier: "dashboard")
            controller.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(controller, animated: true)
        }
        print("checking userdefault id \(UserDefaults.standard.integer(forKey: "userID"))")
        
        btnlogin.layer.cornerRadius = 15
        btnSignup.layer.cornerRadius = 15
        btnSignup.layer.borderWidth = 1.0
        btnSignup.layer.borderColor = UIColor.black.cgColor
        whiteCircleView.layer.cornerRadius = 90
        whiteCircleView.layer.zPosition = 1
       
      
        
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }

    
    
}

