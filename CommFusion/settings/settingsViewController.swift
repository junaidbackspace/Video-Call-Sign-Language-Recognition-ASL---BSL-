//
//  settingsViewController.swift
//  SimpleWebRTC
//
//  Created by Umer Farooq on 12/02/2024.
//  Copyright © 2024 n0. All rights reserved.
//

import UIKit
import Kingfisher

class settingsViewController: UIViewController {

    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var lblname: UILabel!
    @IBOutlet var borderedView: UIView!
    
        var user = User()
    var serverWrapper = APIWrapper()
       

    func fetchUserData() {
            guard let userID = UserDefaults.standard.string(forKey: "userID") else {
                print("User ID not found")
                return
            }
            
            let Url = "\(Constants.serverURL)/user/userdetails/\(userID)"
            print("URL: "+Url)
          
            let url = URL(string: Url)!
            
            self.serverWrapper.fetchUserInfo(baseUrl: url, structure: singleUserInfo.self) { userInfo, error in
                if let error = error {
                    print("inner URL: \(Url)")
                    print("Error in receiving:", error.localizedDescription)
                } else if let userObject = userInfo {
                    print("JSON Data:", userObject)
                    self.processContactsData(userObject)
                } else {
                    print("No data received from the server")
                }
            }
        }

        func processContactsData(_ userObject: singleUserInfo) {
            print("Processing user data")
            user.Fname = userObject.fname
            user.Lname = userObject.lname
            user.Password = userObject.password
            user.ProfilePicture = userObject.profile_picture
            user.Email = userObject.email
            user.UserType = userObject.disability_type
            user.BioStatus = userObject.bio_status
            user.OnlineStatus = userObject.online_status
            lblname.text = user.Fname+" "+user.Lname
            
            let group = DispatchGroup()
              group.enter()

            let urlString = "\(Constants.serverURL)\(user.ProfilePicture)"

            if let url = URL(string: urlString) {
                profileImageView.kf.setImage(with: url, placeholder: UIImage(named: "No image found"))
            } else {
                // Handle invalid URL
                print("Invalid URL:", urlString)
            }
            
            group.leave()
        }

    
       override func viewDidLoad() {
           super.viewDidLoad()
        
        fetchUserData()
       
        
           // Make the profile image round
           profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
           profileImageView.clipsToBounds = true
           
           // Add borders to the bordered view
           
        addBordersToView(borderedView, top: true, bottom: true, left: false, right: false, borderColor: UIColor.black, borderWidth: 1.0)
                
           
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swipedDown(_:)))
        swipeDown.direction = .down
             view.addGestureRecognizer(swipeDown)
       }
    
    @objc func swipedDown(_ gesture: UISwipeGestureRecognizer) {
           if gesture.direction == .down {
            //Displaying Refreshing
            showLoadingView()
            fetchUserData()
           }
        
    }
       
    func addBordersToView(_ view: UIView, top: Bool, bottom: Bool, left: Bool, right: Bool, borderColor: UIColor, borderWidth: CGFloat) {
          let borderLayer = CALayer()
          borderLayer.borderColor = borderColor.cgColor
          borderLayer.borderWidth = borderWidth
          
          if top {
              borderLayer.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: borderWidth)
              view.layer.addSublayer(borderLayer)
          }
          
          if bottom {
              borderLayer.frame = CGRect(x: 0, y: view.frame.size.height - borderWidth, width: view.frame.size.width, height: borderWidth)
              view.layer.addSublayer(borderLayer)
          }
          
          if left {
              borderLayer.frame = CGRect(x: 0, y: 0, width: borderWidth, height: view.frame.size.height)
              view.layer.addSublayer(borderLayer)
          }
          
          if right {
              borderLayer.frame = CGRect(x: view.frame.size.width - borderWidth, y: 0, width: borderWidth, height: view.frame.size.height)
              view.layer.addSublayer(borderLayer)
          }
      }
    
    @IBAction func back_btn(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
       @IBAction func btn_profileSettings() {
         
        let controller = (self.storyboard?.instantiateViewController(identifier: "profilesettingsScreen"))! as ProfileSettingsViewController
        
        var userKey = UserDefaults.standard.string(forKey: "userpass")
        print("Password is : \(userKey)")
       
        controller.name = user.Fname+" "+user.Lname
        controller.About = user.BioStatus
        controller.currentpass = userKey!
        controller.profile = user.ProfilePicture
        controller.distype = user.UserType
        
       
        controller.modalPresentationStyle = .fullScreen
          self.navigationController?.pushViewController(controller, animated: true)
       }
    
    
    @IBAction func btn_Logout(_ sender: Any) {
        socketsClass.shared.disconnect()
        UserDefaults.standard.setValue(0, forKey: "userID")
        
        self.navigationController?.popViewController(animated: true)
        let controller = self.storyboard!.instantiateViewController(identifier: "firstscreen")
        controller.hidesBottomBarWhenPushed = true
        controller.modalPresentationStyle = .fullScreen
          self.navigationController?.pushViewController(controller, animated: true)
        
        
    }
    
    @IBAction func btn_aboutApp(_ sender: Any) {
        let controller = self.storyboard!.instantiateViewController(identifier: "aboutscreen")
        controller.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func btn_termsSettings(_ sender: Any) {
        let controller = self.storyboard!.instantiateViewController(identifier: "termsconditions")
        controller.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func btn_notificationSettigns(_ sender: Any) {
        let controller = self.storyboard!.instantiateViewController(identifier: "notifications")
        controller.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func btn_generalSettings(_ sender: Any) {
        
        let controller = self.storyboard!.instantiateViewController(identifier: "GerenalSettingsScreen")
        
        controller.modalPresentationStyle = .fullScreen
          self.navigationController?.pushViewController(controller, animated: true)
        
    }
    var loadingView: UIView!
    var activityIndicator: UIActivityIndicatorView!
    var loadingLabel: UILabel!
    
    func showLoadingView() {
        setupLoading()
        view.addSubview(loadingView)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.hideLoadingView()
                    }
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
        loadingLabel.text = "Refreshing..."
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
