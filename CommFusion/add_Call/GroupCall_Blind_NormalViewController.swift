//
//  GroupCall_Blind_NormalViewController.swift
//  CommFusion
//
//  Created by Umer Farooq on 01/06/2024.
//  Copyright © 2024 n0. All rights reserved.
//

import UIKit
import Speech

class GroupCall_Blind_NormalViewController: UIViewController {

    public var speechtoText = ""
    var userfirst_id = 0
    var usersecond_id = 0
    
    var speechRecognizer: SpeechRecognizer?
    private var speechSynthesizer =   AVSpeechSynthesizer() // to text to speech
    var user = User()
    var serverWrapper = APIWrapper()
    
    @IBOutlet weak var msg_firstuser : UITextView!
    @IBOutlet weak var msg_seconduser : UITextView!
    
    @IBOutlet weak var profilepic_firstUSer: UIImageView!
    @IBOutlet weak var profilepic_SecondUSer: UIImageView!
    
    @IBOutlet weak var lblname_FirstUser : UILabel!
    @IBOutlet weak var lblname_SecondUser : UILabel!
    
    @IBOutlet weak var view_FirstUser : UIView!
    @IBOutlet weak var view_SecondUser : UIView!
    
    
   @objc func messageRecieved(_ notification : Notification)
    {
        if let userid = notification.userInfo?["from"] as? String {
            if let Message = notification.userInfo?["message"] as? String {
        if userfirst_id == Int(userid) {
            
            msg_firstuser.text = Message
            
        }
        else{
            msg_seconduser.text = Message
        }
            
            }
        }
    }
    
    
    @IBAction func hangupcall(_ sender : Any)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func MuteSpeaker(_ sender : Any)
    {
        
    }
    
    var isMicoff = false
    @IBAction func MuteMic(_ sender : Any)
    {
        if isMicoff{
            self.speechRecognizer!.isStopping = false
            self.speechRecognizer!.startRecognition()
            isMicoff = false
        }
        else{
            isMicoff  = true
            self.speechRecognizer!.isStopping = true
            self.speechRecognizer!.stopRecognition()
            
         
            speechtoText = ""
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchUserData(userid : userfirst_id , userno : 1)
        fetchUserData(userid : usersecond_id , userno : 2)
        
        setupSpeechToText()
        
        NotificationCenter.default.addObserver(self, selector: #selector(messageRecieved(_:)), name: Notification.Name("ChatMsg_Recieved"), object: nil)
    }
    deinit {
     
     speechRecognizer?.isStopping = false
     speechRecognizer?.stopRecognition()
    }

    
    func TexttoSpeech(text: String)
    {
      // Check if the speech synthesizer is speaking
                if speechSynthesizer.isSpeaking {
                    speechSynthesizer.stopSpeaking(at: .immediate)
                }
                
                // Create an utterance with the given text
                let utterance = AVSpeechUtterance(string: text)
                
                // Set the voice (optional, can set to nil for default voice)
                utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                
                // Adjust the rate, pitch, and volume (optional)
                utterance.rate = AVSpeechUtteranceDefaultSpeechRate
                utterance.pitchMultiplier = 1.0
                utterance.volume = 1.0
                
                // Speak the utterance
                speechSynthesizer.speak(utterance)
            
    }
        
    func stopSpeaking() {
            // Stop the speech synthesizer from speaking
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
    
    
    func setupSpeechToText()
    {
        speechRecognizer = SpeechRecognizer(blind_normalGroup: self)
        self.speechRecognizer!.startRecognition()
        
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
            user.Fname = userObject.fname
            user.Lname = userObject.lname
            
            user.ProfilePicture = userObject.profile_picture
//            user.Email = userObject.email
//            user.UserType = userObject.disability_type
//            user.BioStatus = userObject.bio_status
//            user.OnlineStatus = userObject.online_status
            
            let group = DispatchGroup()
              group.enter()

            let urlString = "\(Constants.serverURL)\(user.ProfilePicture)"

            if let url = URL(string: urlString) {
                
                if userno == 1{
               profilepic_firstUSer.kf.setImage(with: url, placeholder: UIImage(named: "No image found"))
                    lblname_FirstUser.text = user.Fname+" "+user.Lname
                   
                }
                else{
                    profilepic_SecondUSer.kf.setImage(with: url, placeholder: UIImage(named: "No image found"))
                         lblname_SecondUser.text = user.Fname+" "+user.Lname
                        
                    
                }
            } else {
                // Handle invalid URL
                print("Invalid URL:", urlString)
            }
            
            group.leave()
        }

}
