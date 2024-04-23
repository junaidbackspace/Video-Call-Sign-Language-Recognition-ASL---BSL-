//
//  CallerViewController.swift
//  SimpleWebRTC
//
//  Created by Umer Farooq on 14/02/2024.
//  Copyright © 2024 n0. All rights reserved.
//

import UIKit
import AVFoundation

class CallerViewController: UIViewController {
    
    var profilepic = UIImage()
    var name = " "
    var isringing = " "
    var audioSession = AVAudioSession.sharedInstance()
    var isMuted = true
    
    @IBOutlet weak var videoPreviewView: UIView!
    @IBOutlet weak var btnswitchCamera: UIButton!
    @IBOutlet weak var btnendCall: UIButton!
    @IBOutlet weak var btnMuteSpeaker: UIButton!

    @IBOutlet weak var lblname: UILabel!
    @IBOutlet weak var imgview: UIImageView!
    @IBOutlet weak var lbl_is_ringing: UILabel!
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var isFrontCamera = true
       
    
    var serverWrapper = APIWrapper()
  
    var callerid = 0
    var recieverid = 0
    
    func CallAPI(caller : Int ,reciver : Int )
    {
        let Url = "\(Constants.serverURL)/video-call/start"
        print("calling : \(Url)")
        let Dic: [String: Any] = [
            "caller_id": caller,
              "receiver_id": reciver ]

        serverWrapper.insertData(baseUrl: Url,  userDictionary: Dic) { responseString, error in
            if let error = error {
                print("\n\nError:", error)
               }
            
            if let responseString = responseString {
                print("w response:", responseString)
                
                guard let responseData = responseString.data(using: .utf8) else {
                    print("Error converting response data to UTF-8")
                    return
                }
                
            }

        }
    }
    @objc func handleNotification(_ notification: Notification) {
            if let text = notification.userInfo?["text"] as? String {
                lbl_is_ringing.text = text
            }
        }

        // Don't forget to remove observer when the ViewController is deallocated
        deinit {
            NotificationCenter.default.removeObserver(self)
        }
    
       override func viewDidLoad() {
           super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: Notification.Name("UpdateLabelNotification"), object: nil)
           
        
        setupCamera()
        imgview.image = profilepic
        imgview.layer.cornerRadius = 35
        imgview.clipsToBounds = true
        lblname.text = name
        lbl_is_ringing.text = isringing
        
        //bring images buttons upon camerascreen
        btnMuteSpeaker.layer.zPosition = 1
        btnendCall.layer.zPosition = 1
        btnswitchCamera.layer.zPosition = 1
        lblname.layer.zPosition = 1
        lbl_is_ringing.layer.zPosition = 1
        imgview.layer.zPosition = 1
        
        let websoc = socketsClass()
        
        let friendid = String(recieverid)
        print("here is reciver id  : \(friendid)")
        
        websoc.initiateCall(with: friendid)
        CallAPI(caller: callerid, reciver: recieverid)
       }
       
       func setupCamera() {
           captureSession = AVCaptureSession()
           guard let captureSession = captureSession else { return }
           
           guard let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
           guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else { return }
           
           do {
               let input = try AVCaptureDeviceInput(device: isFrontCamera ? frontCamera : backCamera)
               captureSession.addInput(input)
           } catch {
               print("Error setting up camera input:", error.localizedDescription)
               return
           }
           
           videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
           videoPreviewLayer?.videoGravity = .resizeAspectFill
           videoPreviewLayer?.frame = videoPreviewView.layer.bounds
           videoPreviewView.layer.addSublayer(videoPreviewLayer!)
           
           captureSession.startRunning()
       }
       
       @IBAction func switchCameraTapped(_ sender: UIButton) {
           isFrontCamera.toggle()
           captureSession?.stopRunning()
           setupCamera()
       }
       
       @IBAction func endCallTapped(_ sender: UIButton) {
        captureSession?.stopRunning()
        self.navigationController?.popViewController(animated: true)
           dismiss(animated: true, completion: nil)
       }
    
    @IBAction func Mute_Audio(_ sender: UIButton) {

    do {
               try audioSession.setActive(true)
               if isMuted {
                   try audioSession.overrideOutputAudioPort(.speaker)
                   isMuted = false
                btnMuteSpeaker.setBackgroundImage(UIImage(named: "speaker.slash.circle.fill"), for: .normal) // Set image for unmuted state
               } else {
                   try audioSession.overrideOutputAudioPort(.none)
                   isMuted = true
                btnMuteSpeaker.setBackgroundImage(UIImage(named: "speaker.wave.2.circle.fill"), for: .normal) // Set image for muted state
               }
           } catch {
               print("Error setting audio session: \(error.localizedDescription)")
           }
    }
}
