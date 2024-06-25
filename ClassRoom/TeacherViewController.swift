//
//  TeacherViewController.swift
//  CommFusion
//
//  Created by Umer Farooq on 25/06/2024.
//  Copyright © 2024 n0. All rights reserved.
//

import UIKit

class TeacherViewController: UIViewController {

    
    
    @IBOutlet weak var groupchat_View1 : UIView!
    @IBOutlet weak var groupmember_Profile1 : UIImageView!
    @IBOutlet weak var groupmember_Name1 : UILabel!
    
    @IBOutlet weak var groupchat_View2 : UIView!
    @IBOutlet weak var groupmember_Profile2 : UIImageView!
    @IBOutlet weak var groupmember_Name2 : UILabel!
    
    @IBOutlet weak var groupchat_View3 : UIView!
    @IBOutlet weak var groupmember_Profile3 : UIImageView!
    @IBOutlet weak var groupmember_Name3 : UILabel!
    
    @IBOutlet weak var groupchat_View4 : UIView!
    @IBOutlet weak var groupmember_Profile4 : UIImageView!
    @IBOutlet weak var groupmember_Name4 : UILabel!
    
    var user = User()
    var serverWrapper = APIWrapper()
    var captureTimer: Timer?
    var overlayView: UIView!
    
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var capturedImage: UIImage?
 

    
    
    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var playerItem: AVPlayerItem?
    var SignsvideoContainerView: UIView?
    
    let userID = UserDefaults.standard.string(forKey: "userID")!
    
    @IBOutlet weak var cameraView : UIView!
    @IBOutlet weak var textMessage : UITextView!
    
    
    
    
    //MARK:- deaf and mute signs
    private var playedGifs: Set<String> = []
    private var wordToGifMap: [String: String] = [
        "hello": "hello.gif",
        "helo": "hello.gif",
        "how": "howareyou.gif",
        "cool": "cool.gif",
        "happy": "happy.gif",
        "fine": "iamfine.gif",
        "learning": "iamlearning.gif",
        "love": "iloveyou.gif",
        "calm": "keepcalmandstayhome.gif",
        "kiss": "kiss.gif",
        "me": "me.gif",
        "meet": "nicetomeetyou.gif",
        "no": "no.gif",
        "ok": "ok.gif",
        "please": "please.gif",
        "sorry": "sorry.gif",
        "super": "super.gif",
        "thank": "thankyou.gif",
        "try": "tryagain.gif",
        "understand": "understand.gif",
        "from": "whereareyoufrom.gif",
        "wonderful": "wonderful.gif"
//        "you": "you.gif"
        // Add more mappings as needed
    ]
    
    
    
    @IBAction func hangupCall (_ sender : Any)
    {
        
        socketsClass.shared.GroupCall_End(caller1: String(userfirst_id), caller2: String(usersecond_id))
        
        stopCamera()
        self.navigationController?.popViewController(animated: true)
        self.navigationController?.popViewController(animated: true)
    }
    
    deinit
    {
        let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setCategory(.playAndRecord, mode: .default, options: [.mixWithOthers])
                try audioSession.setActive(true)
            } catch {
                print("Error setting up audio session: \(error)")
            }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUserData(userid: userfirst_id, userno: 1)
        fetchUserData(userid: usersecond_id, userno: 2)
        
        setupCamera()
        captureSession.startRunning()
        
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(messageRecieved(_:)), name: Notification.Name("ChatMsg_Recieved"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(hangupCall), name: Notification.Name("groupChatEnd"), object: nil)
        
        
        self.captureTimer = Timer.scheduledTimer(timeInterval: 2.0 , target: self, selector: #selector(self.takePicture), userInfo: nil, repeats: true)
        
        var doubletap = UITapGestureRecognizer(target: self, action: #selector(predictWords))
        doubletap.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubletap)
       
        
        overlayView = UIView(frame: view.bounds)
        overlayView.backgroundColor = UIColor.clear
        overlayView.isUserInteractionEnabled = false
        view.addSubview(overlayView)
    }
    
    
    var static_frameCheck = true
    @objc func predictWords()  {
        
        //toggle static , dynamic
        if static_frameCheck {
           
            performColorFade()
            static_frameCheck = false
            
        }
        else{
            performColorFade()
            
            static_frameCheck = true
            }
        
        }
    
    func performColorFade() {
            // Set the initial color of the overlay view
            overlayView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.4)
            
            // Animate the color fade in and out
            UIView.animate(withDuration: 0.5, animations: {
                self.overlayView.backgroundColor = UIColor.blue.withAlphaComponent(0.2)
            }) { _ in
                UIView.animate(withDuration: 0.5, animations: {
                    self.overlayView.backgroundColor = UIColor.clear
                })
            }
        }
    
    
    
    @objc func takePicture() {
        
        let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setCategory(.playAndRecord, mode: .default, options: [.mixWithOthers])
                try audioSession.setActive(true)
            } catch {
                print("Error setting up audio session: \(error)")
            }

        
        let settings = AVCapturePhotoSettings()
        stillImageOutput.capturePhoto(with: settings, delegate: self)
    }
    
    @objc func messageRecieved(_ notification : Notification)
     {
         if let userid = notification.userInfo?["from"] as? String {
             if let Message = notification.userInfo?["message"] as? String {
         if userfirst_id == Int(userid) {
             
            textMessage.text = Name_First_User+": "+Message
            processTranscription(Message)
             
         }
         else{
            textMessage.text = Name_Second_User+": "+Message
            processTranscription(Message)
         }
             
             }
         }
     }
     
    func setupCamera() {
           // Setup camera
           captureSession = AVCaptureSession()
           captureSession.sessionPreset = .medium

           guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
               print("Unable to access front camera!")
               return
           }

           do {
               let input = try AVCaptureDeviceInput(device: frontCamera)
               stillImageOutput = AVCapturePhotoOutput()

               if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
                   captureSession.addInput(input)
                   captureSession.addOutput(stillImageOutput)
                   setupLivePreview()
               }
           } catch let error  {
               print("Error Unable to initialize front camera:  \(error.localizedDescription)")
           }
       }

    func setupLivePreview() {
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer.videoGravity = .resizeAspectFill
            videoPreviewLayer.connection?.videoOrientation = .portrait

            // Insert the videoPreviewLayer at the lowest level
            cameraView.layer.insertSublayer(videoPreviewLayer, at: 0)

            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.startRunning()
                DispatchQueue.main.async {
                    self.videoPreviewLayer.frame = self.cameraView.bounds
                    self.videoPreviewLayer.masksToBounds = true
                }
            }
        }

       override func viewDidLayoutSubviews() {
           super.viewDidLayoutSubviews()
           videoPreviewLayer.frame = cameraView.bounds
       }

      

       func stopCamera() {
           captureSession.stopRunning()
       }

       // AVCapturePhotoCaptureDelegate method
       func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
           guard let imageData = photo.fileDataRepresentation() else { return }
           let static_image = UIImage(data: imageData)

        self.sendtoServer(image: static_image!)
          
       }
   
   
    func sendtoServer(image : UIImage)
    {
        //MARK:- predicting alphabets now
        if static_frameCheck{
            
            predict_staticSign(image: image)
    }
    
        //MARK:- predicting Words now
    else{
    predict_WordsSign(image: image)
    
    
        }
    }
    
    

    func fetchUserData(userid : Int , userno : Int) {
            let userID = userid
            
            let Url = "\(Constants.serverURL)/user/userdetails/\(userID)"
            print("URL: "+Url)
          
            let url = URL(string: Url)!
            
            self.serverWrapper.fetchUserInfo(baseUrl: url, structure: singleUserInfo.self) { userInfo, error in
                if let error = error {
                    print("inner URL: \(Url)")
                    print("Error in receiving:", error.localizedDescription)
                } else if let userObject = userInfo {
                    print("JSON Data:", userObject)
                    
                    self.processContactsData(userObject , userno: userno)
                } else {
                    print("No data received from the server")
                }
            }
        }

    func processContactsData(_ userObject: singleUserInfo , userno : Int) {
            print("Processing user data")
//            user.Fname = userObject.fname
//            user.Lname = userObject.lname
//
            user.ProfilePicture = userObject.profile_picture

            
            let group = DispatchGroup()
              group.enter()

            let urlString = "\(Constants.serverURL)\(user.ProfilePicture)"

            if let url = URL(string: urlString) {
                
                if userno == 1{
               Profilepic_Firstuser.kf.setImage(with: url, placeholder: UIImage(named: "No image found"))

                   
                }
                else{
                    Profilepic_Seconduser.kf.setImage(with: url, placeholder: UIImage(named: "No image found"))

                        
                    
                }
            } else {
                // Handle invalid URL
                print("Invalid URL:", urlString)
            }
            
            group.leave()
        }


    
    
    func predict_staticSign(image : UIImage)
    {
        let apiUrl = URL(string: "\(Constants.serverURL)/asl-Updatedsigns/detect_hand")!
                     serverWrapper.predictAlphabet(baseUrl: apiUrl, image: image) { predictedLabel, error in
                         if let error = error {
                             print("Error: \(error.localizedDescription)")
                         }
                         else if let predictedLabel = predictedLabel {
                            
                             print("Predicted Label: \(predictedLabel)")
                            
                            
                            socketsClass.shared.Send_GroupChatMsgByDeaf(friendId: String(self.userfirst_id), Message: predictedLabel, from: self.userID )
                            socketsClass.shared.Send_GroupChatMsgByDeaf(friendId: String(self.usersecond_id), Message: predictedLabel, from: self.userID )
                            
                            
                            }
                         }
                     
    }
    
    
    //prediction words
    func predict_WordsSign(image : UIImage)
    {

        let apiUrl = URL(string: "\(Constants.serverURL)/asl-Updatedsigns/predictWP")!
        serverWrapper.predictWords(baseUrl: apiUrl, image: image) { predictedLabel, error in
                         if let error = error {
                             print("Error: \(error.localizedDescription)")
                         } else if let predictedLabel = predictedLabel {
                             print("Predicted Word: \(predictedLabel)")
                             
                            socketsClass.shared.Send_GroupChatMsgByDeaf(friendId: String(self.userfirst_id), Message: predictedLabel, from: self.userID )
                            socketsClass.shared.Send_GroupChatMsgByDeaf(friendId: String(self.usersecond_id), Message: predictedLabel, from: self.userID )
                         }
    }
    
    }
    
    
    func processTranscription(_ transcription: String) {
        let words = transcription.lowercased().split(separator: " ")
        
        for word in words {
            let wordStr = String(word)
            if let gifName = wordToGifMap[wordStr], !playedGifs.contains(wordStr) {
               
                playedGifs.insert(wordStr)
                
                print("giving text for video : \(wordStr)")
               
                play_sign_gif(name: wordStr)
                DispatchQueue.main.asyncAfter(deadline: .now()+2)
                {
                    self.cleanupPlayer()
                }
            }
        }
    }
    
    
    func cleanupPlayer() {
           if let playerItem = playerItem {
               NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
           }
           playerLayer?.removeFromSuperlayer()
           playerLayer = nil
           playerItem = nil
           player = nil
           SignsvideoContainerView?.removeFromSuperview()
       }

    
    func play_sign_gif(name: String) {
            // Clean up any existing GIF and views
            cleanupGif()

            guard let gifPath = Bundle.main.path(forResource: name.lowercased(), ofType: "gif") else {
                print("GIF file not found.")
                return
            }

            guard let gifData = NSData(contentsOfFile: gifPath) else {
                print("Failed to load GIF data.")
                return
            }

            let gif = UIImage.gif(data: gifData as Data)
            
            // Define the frame for the GIF image view
            let gifWidth: CGFloat = 200.0 // specify desired width
            let gifHeight: CGFloat = 150.0 // specify desired height
            let xPos: CGFloat = (self.view.bounds.width - gifWidth) / 2 // center horizontally
            let yPos: CGFloat = (self.view.bounds.height - gifHeight) - 150 // position vertically

            // Set up UIImageView for GIF
            let gifImageView = UIImageView(image: gif)
            gifImageView.frame = CGRect(x: xPos, y: yPos, width: gifWidth, height: gifHeight)
            gifImageView.contentMode = .scaleAspectFill
            
            // Add the GIF UIImageView to the view
            SignsvideoContainerView = UIView(frame: view.bounds)
            if let SignsvideoContainerView = SignsvideoContainerView {
                SignsvideoContainerView.addSubview(gifImageView)
                view.addSubview(SignsvideoContainerView)
                
            }
        }


    
    @objc func stopGif() {
            cleanupGif()
        }
        
        func cleanupGif() {
            if let SignsvideoContainerView = SignsvideoContainerView {
                SignsvideoContainerView.removeFromSuperview()
            }
            SignsvideoContainerView = nil
        }
    

}
