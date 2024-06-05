//
//  RecieverViewController.swift
//  SimpleWebRTC
//
//  Created by Umer Farooq on 15/02/2024.
//  Copyright © 2024 n0. All rights reserved.
//

import UIKit
import AVFoundation
class CallRecieverViewController: UIViewController,AVAudioPlayerDelegate {
    
    var musicPlayer: AVAudioPlayer?
    
  
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var user = User()
    var serverWrapper = APIWrapper()
    var calllerid = ""
    
    
    var caller1_id  = 0
    var caller2_id = 0
    var friend_id = 0
    var vid = 0
    var caller1Name = ""
    var caller2Name = ""
    
    var userid = UserDefaults.standard.integer(forKey: "userID")
    @IBOutlet weak var lblrecievingCall: UILabel!
    @IBOutlet weak var lblname: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var rejectButton: UIButton!
       
       // Constraint for the bottom margin of the view containing the buttons
    @IBOutlet weak var bottomButtonViewBottomConstraint: NSLayoutConstraint!

   
    var acceptButtonDragging = false
         var rejectButtonDragging = false
         let maxButtonTranslation: CGFloat = 100 // Adjust the maximum translation as needed

    
   
    
         override func viewDidLoad() {
             super.viewDidLoad()
            var is_ringon = UserDefaults.standard.string(forKey: "notifi_sound")
            if is_ringon == "on"
            {
                print("Ringtone is on...")
                if UserDefaults.standard.object(forKey: "rigntones") == nil {
                    UserDefaults.standard.setValue("default", forKey: "rigntones")
                    
                    playMusic(fileName: "default")
                }
                else {
                    
                    playMusic(fileName: UserDefaults.standard.string(forKey: "rigntones")! as String)
                }
               
            }
           
            
            if !socketsClass.shared.isConnected(){
                socketsClass.shared.connectSocket()
            }
            NotificationCenter.default.addObserver(self, selector: #selector(callcenlled), name: Notification.Name("CallCancelledFromReciverNotification"), object: nil)
               
            if calllerid != "0"
            {
          fetchUserData(callerId: calllerid)
                
            }
            
            else{
                fetchUserNames(callerId: String(caller1_id), number: 1)
                fetchUserNames(callerId: String(caller2_id), number: 2)
                lblname.text = caller1Name+" & "+caller2Name
            }
            startCamera()
            acceptButton.layer.zPosition = 1
            rejectButton.layer.zPosition = 1
            profilePic.layer.zPosition = 1
            lblname.layer.zPosition = 1
            lblrecievingCall.layer.zPosition = 1
            
             // Add pan gesture recognizer for drag-up interaction
             let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
             self.view.addGestureRecognizer(panGesture)
            

         }
    func playMusic(fileName: String) {
            guard let path = Bundle.main.path(forResource: fileName, ofType: "mp3") else {
                print("File not found")
                return
            }

            let url = URL(fileURLWithPath: path)

            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
                musicPlayer = try AVAudioPlayer(contentsOf: url)
                musicPlayer?.delegate = self
                musicPlayer?.prepareToPlay()
                musicPlayer?.volume = 1.0
                musicPlayer?.play()
                
            } catch {
                print("Error playing music: \(error.localizedDescription)")
            }
        }
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
          if flag {
              // Playback finished successfully, restart the music
              player.currentTime = 0
              player.play()
          } else {
              // Playback finished with an error
              print("Playback finished with an error")
          }
      }
  
    
    @objc func callcenlled(){
        let websoc = socketsClass()
     
        let friendid = String(calllerid)
        print("here is Friend id  : \(friendid)")
        
        websoc.CancellCall(with: friendid)
       
        print(" call cancelled")
        captureSession?.stopRunning()
        self.navigationController?.popViewController(animated: true)
       
    }
   
    
    
         @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
             let translation = gesture.translation(in: self.view)
             let velocity = gesture.velocity(in: self.view)
             
             switch gesture.state {
             case .began:
                 // Check if the gesture started within the accept or reject button
                 let location = gesture.location(in: self.view)
                 if acceptButton.frame.contains(location) {
                     acceptButtonDragging = true
                     rejectButtonDragging = false
                 } else if rejectButton.frame.contains(location) {
                     acceptButtonDragging = false
                     rejectButtonDragging = true
                 }
             case .changed:
                if acceptButtonDragging {
                    // Limit dragging for accept button
                    let maxButtonY = 300
                    let initialBottomMargin = 100
                    let newConstant = min(-translation.y, maxButtonTranslation)
                    let maxTranslation = max(CGFloat(maxButtonY) - acceptButton.frame.origin.y, newConstant)
                    bottomButtonViewBottomConstraint.constant = CGFloat(initialBottomMargin) - maxTranslation

                    // Move the accept button independently
                    let buttonTranslation = -bottomButtonViewBottomConstraint.constant
                    
                    // Add animation with a slow-down effect
                    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.3, options: [.curveEaseInOut], animations: {
                        self.acceptButton.transform = CGAffineTransform(translationX: 0, y: buttonTranslation)
                        self.view.layoutIfNeeded()
                    }, completion: nil)
                } else if rejectButtonDragging {
                    // Limit dragging for reject button
                    let maxButtonY = 300
                    let initialBottomMargin = 100
                    let newConstant = min(-translation.y, maxButtonTranslation)
                    let maxTranslation = max(CGFloat(maxButtonY) - rejectButton.frame.origin.y, newConstant)
                    bottomButtonViewBottomConstraint.constant = CGFloat(initialBottomMargin) - maxTranslation

                    // Move the reject button independently
                    let buttonTranslation = -bottomButtonViewBottomConstraint.constant
                    
                    // Add animation with a slow-down effect
                    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.3, options: [.curveEaseInOut], animations: {
                        self.rejectButton.transform = CGAffineTransform(translationX: 0, y: buttonTranslation)
                        self.view.layoutIfNeeded()
                    }, completion: nil)
                }
             case .ended:
                 if acceptButtonDragging {
                     if velocity.y < -100 {
                         // User swiped up quickly, reveal accept button
                         UIView.animate(withDuration: 0.2) {
                             self.bottomButtonViewBottomConstraint.constant = 0
                             self.acceptButton.transform = .identity
                             self.view.layoutIfNeeded()
                         }
                     } else {
                         // User did not swipe up quickly, hide accept button
                         UIView.animate(withDuration: 0.2) {
                             self.bottomButtonViewBottomConstraint.constant = -self.acceptButton.frame.height - 20 // Adjust according to your layout
                             self.acceptButton.transform = .identity
                             self.view.layoutIfNeeded()
                         }
                     }
                     // Check if the accept button is dragged up enough to trigger its action
                     if -translation.y > acceptButton.frame.height / 2 {
                         acceptCall()
                     }
                     acceptButtonDragging = false
                 } else if rejectButtonDragging {
                     if velocity.y < -100 {
                         // User swiped up quickly, reveal reject button
                         UIView.animate(withDuration: 0.2) {
                             self.bottomButtonViewBottomConstraint.constant = 0
                             self.rejectButton.transform = .identity
                             self.view.layoutIfNeeded()
                         }
                     } else {
                         // User did not swipe up quickly, hide reject button
                         UIView.animate(withDuration: 0.2) {
                             self.bottomButtonViewBottomConstraint.constant = -self.rejectButton.frame.height - 20 // Adjust according to your layout
                             self.rejectButton.transform = .identity
                             self.view.layoutIfNeeded()
                         }
                     }
                     // Check if the reject button is dragged up enough to trigger its action
                     if -translation.y > rejectButton.frame.height / 2 {
                         rejectCall()
                     }
                     rejectButtonDragging = false
                 }
             default:
                 break
             }
         }



    let isGroupCall = UserDefaults.standard.string(forKey: "groupchat")
    func acceptCall() {
        musicPlayer?.stop()
        
        if isGroupCall != "1"
        {
            print("Accepted call")
        let callData = ["type": "call_accept", "from": String(userid), "to": calllerid]
               if let jsonData = try? JSONSerialization.data(withJSONObject: callData) {
                   if let jsonString = String(data: jsonData, encoding: .utf8) {
                    socketsClass.shared.socket.write(string: jsonString)
                    print("call is accepted , caller is: \(calllerid)")
                   }
               }
            
            // Send the JSON string to the WebSo|cket server
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        let controller = (self.storyboard?.instantiateViewController(identifier: "videoCallscreen"))! as ViewController
            controller.isReciever = 1
            controller.callFriendId = self.calllerid
            print("call friend id : \(self.calllerid)")
        controller.modalPresentationStyle = .fullScreen
          self.navigationController?.pushViewController(controller, animated: true)
                }
            
            }
        
        else{
            let myLangType = UserDefaults.standard.string(forKey: "disabilityType")!
            
            if myLangType == "deaf"
            {
                
                socketsClass.shared.GroupCallAccepted(caller1: String(caller1_id), caller2: String(caller2_id))
                let controller = (self.storyboard?.instantiateViewController(identifier: "groupcall_Deaf_Screen"))! as GroupCall_deaf_ViewController
                   
                    print("call friend id : \(self.calllerid)")
                controller.userfirst_id = caller1_id
                controller.userfirst_id = caller2_id
                controller.modalPresentationStyle = .fullScreen
                  self.navigationController?.pushViewController(controller, animated: true)
            
            }
            else{
                socketsClass.shared.GroupCallAccepted(caller1: String(caller1_id), caller2: String(caller2_id))
                let controller = (self.storyboard?.instantiateViewController(identifier: "groupcall_blind_normalScreen"))! as GroupCall_Blind_NormalViewController
                
                controller.userfirst_id = caller1_id
                controller.usersecond_id = caller2_id
                
                    print("caller 1 : \(caller1_id) and caller 2  : \(caller2_id)")
                controller.modalPresentationStyle = .fullScreen
                  self.navigationController?.pushViewController(controller, animated: true)
            }
        }
        }
        
        func rejectCall() {
            socketsClass.shared.CancellCall(with: calllerid)
            print("Rejected call")
            self.navigationController?.popViewController(animated: true)
            captureSession?.stopRunning()
        }
    
    func startCamera() {
        // Initialize capture session
                captureSession = AVCaptureSession()
                guard let captureSession = captureSession else { return }
                
                // Define capture device (front camera)
                if let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
                    do {
                        // Add input device to the capture session
                        let input = try AVCaptureDeviceInput(device: captureDevice)
                        captureSession.addInput(input)
                        
                        // Configure video output
                        let captureOutput = AVCaptureVideoDataOutput()
                        captureSession.addOutput(captureOutput)
                        
                        // Configure video preview layer
                        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                        videoPreviewLayer?.videoGravity = .resizeAspectFill
                        videoPreviewLayer?.frame = videoView.bounds
                        videoView.layer.addSublayer(videoPreviewLayer!)
                        
                        // Start the capture session
                        captureSession.startRunning()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
       }
    override func viewDidLayoutSubviews() {
           super.viewDidLayoutSubviews()
           videoPreviewLayer?.frame = videoView.bounds
       }
    

   

    func fetchUserData(callerId : String) {
       
        let userID = String(callerId)
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
        user.ProfilePicture = userObject.profile_picture
        
        lblname.text = user.Fname+" "+user.Lname
        
        let group = DispatchGroup()
          group.enter()

        let urlString = "\(Constants.serverURL)\(user.ProfilePicture)"

        if let url = URL(string: urlString) {
            profilePic.kf.setImage(with: url, placeholder: UIImage(named: "No image found"))
        } else {
            // Handle invalid URL
            print("Invalid URL:", urlString)
        }
        
        group.leave()
    }
    
    
    func fetchUserNames(callerId : String , number : Int) {
       
        let userID = String(callerId)
        let Url = "\(Constants.serverURL)/user/userdetails/\(userID)"
        print("URL: "+Url)
      
        let url = URL(string: Url)!
        
        self.serverWrapper.fetchUserInfo(baseUrl: url, structure: singleUserInfo.self) { userInfo, error in
            if let error = error {
                print("inner URL: \(Url)")
                print("Error in receiving:", error.localizedDescription)
            } else if let userObject = userInfo {
                print("JSON Data:", userObject)
                self.processUserName(userObject , no : number)
            } else {
                print("No data received from the server")
            }
        }
    }

    func processUserName(_ userObject: singleUserInfo, no: Int) {
        print("Processing user data")
        user.Fname = userObject.fname
        user.Lname = userObject.lname
        
        if no == 1{
        caller1Name = user.Fname+" "+user.Lname
        
        }
        else{
            caller2Name = user.Fname+" "+user.Lname
        }
        
        let group = DispatchGroup()
          group.enter()

        let urlString = "\(Constants.serverURL)\(user.ProfilePicture)"

        if let url = URL(string: urlString) {
            profilePic.kf.setImage(with: url, placeholder: UIImage(named: "No image found"))
        } else {
            // Handle invalid URL
            print("Invalid URL:", urlString)
        }
        
        group.leave()
    }
    
    
    deinit {
           NotificationCenter.default.removeObserver(self)
       }
   
}
