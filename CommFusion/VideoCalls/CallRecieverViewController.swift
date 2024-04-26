//
//  RecieverViewController.swift
//  SimpleWebRTC
//
//  Created by Umer Farooq on 15/02/2024.
//  Copyright © 2024 n0. All rights reserved.
//

import UIKit
import AVFoundation
class CallRecieverViewController: UIViewController {
    

  
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var user = User()
    var serverWrapper = APIWrapper()
    var calllerid = ""
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

    
    let socketObj = socketsClass()
    
         override func viewDidLoad() {
             super.viewDidLoad()
            socketObj.connectSocket()
            
            
          fetchUserData(callerId: calllerid)
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




    func acceptCall() {
        
            print("Accepted call")
        let callData = ["type": "call_accept", "from": String(userid), "to": calllerid]
               if let jsonData = try? JSONSerialization.data(withJSONObject: callData) {
                   if let jsonString = String(data: jsonData, encoding: .utf8) {
                    socketObj.socket.write(string: jsonString)
                    print("call is accepted , caller is: \(calllerid)")
                   }
               }
            
            // Send the JSON string to the WebSocket server
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        let controller = (self.storyboard?.instantiateViewController(identifier: "videoCallscreen"))! as ViewController
        controller.modalPresentationStyle = .fullScreen
          self.navigationController?.pushViewController(controller, animated: true)
        }
        }
        
        func rejectCall() {
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
    
   
}