//
//  GroupCall_Blind_NormalViewController.swift
//  CommFusion
//
//  Created by Umer Farooq on 01/06/2024.
//  Copyright © 2024 n0. All rights reserved.
//

import UIKit
import Speech
import AVFoundation

class GroupCall_Blind_NormalViewController: UIViewController {

    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var playerItem: AVPlayerItem?
    var SignsvideoContainerView: UIView?
    
    public var speechtoText = ""
    var userfirst_id = 0
    var usersecond_id = 0
    var msgList = [String]()
    
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
    
//    var Msg = ""
//    var currentmsg = -1
//
//
//
//    func getCurrentFormattedDate() -> String {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
//        dateFormatter.timeZone = TimeZone(identifier: "UTC")
//        return dateFormatter.string(from: Date())
//    }
//
//    func test(msg : String) {
//        let startTime = getCurrentFormattedDate()
//        let endTime = getCurrentFormattedDate()
//
//        let newSegment = TranscriptSegment(
//            UserId: 2,
//            VideoCallId: "2345", // Replace with the actual VideoCallId
//            StartTime: startTime,
//            EndTime: endTime,
//            Content: "msg"
//        )
//    }
//
//
//    @IBAction func backbtn(_ sender: UIButton)
//    {
//        print("Current message : \(currentmsg) , Total count \(msgList.count)")
////        currentmsg -= 1
////        if (currentmsg > 0) {
//
//        Msg = msgList.popLast()!
//        print("Poped msg : \(Msg)")
//            msg_firstuser.text = Msg
//            if myLangType == "deaf"{
//            processTranscription(Msg)
//        }
//        else{
//            print("speak check")
//            speak(text: Msg)
//        }
////        }
//    }
//    @IBAction func freshbtn(_ sender: UIButton)
//    {
//        print("Current message : \(currentmsg) , Total count \(msgList.count)")
//        Msg =  msgList.last!
//        print("fresh msg is : \(Msg)")
//        msg_firstuser.text = Msg
//        processTranscription(Msg)
//        if myLangType == "deaf"{
//            processTranscription(Msg)
//        }
//        else{
//            print("speak check")
//            speak(text: Msg)
//        }
//
//    }
//
//    private var playedGifs: Set<String> = []
//    private var wordToGifMap: [String: String] = [
//        "hello": "hello.gif",
//        "helo": "hello.gif",
//        "how": "howareyou.gif",
//        "cool": "cool.gif",
//        "happy": "happy.gif",
//        "fine": "iamfine.gif",
//        "learning": "iamlearning.gif",
//        "love": "iloveyou.gif",
//        "calm": "keepcalmandstayhome.gif",
//        "kiss": "kiss.gif",
//        "me": "me.gif",
//        "meet": "nicetomeetyou.gif",
//        "no": "no.gif",
//        "ok": "ok.gif",
//        "please": "please.gif",
//        "sorry": "sorry.gif",
//        "super": "super.gif",
//        "thank": "thankyou.gif",
//        "try": "tryagain.gif",
//        "understand": "understand.gif",
//        "from": "whereareyoufrom.gif",
//        "wonderful": "wonderful.gif"
////        "you": "you.gif"
//        // Add more mappings as needed
//    ]
//
//
    let myLangType = UserDefaults.standard.string(forKey: "disabilityType")!
   @objc func messageRecieved(_ notification : Notification)
    {
    
//      currentmsg += 1
    print("displaying chat message")
        if let userid = notification.userInfo?["from"] as? String {
            if let Message = notification.userInfo?["message"] as? String {
        if userfirst_id == Int(userid) {

            msg_firstuser.text = Message
            processTranscription(Message)
        }
        else{
            msg_seconduser.text = Message
        }
//
//                if myLangType == "deaf"
//                {
//                    print("Runing fings")
//                    processTranscription(Message)
//                }
//                else{
//                    print("speaking...")
//                    TexttoSpeech(text : Message)
//                }
//
                msg_firstuser.text = Message
                if Message != " "{
                msgList.append(Message)
//                    test(msg: Message)
                }
                print(" chat message is : \(Message)")
                
            
            }
        }
    }
    @objc func ChatEnded(){
        
//        self.speechRecognizer!.isStopping = true
//        self.speechRecognizer!.stopRecognition()
        self.navigationController?.popViewController(animated: true)
        self.navigationController?.popViewController(animated: true)
        
    }
    
    func processTranscription(_ transcription: String) {
        let words = transcription.lowercased().split(separator: " ")
        
        for word in words {
            let wordStr = String(word)
            if let gifName = wordToGifMap[wordStr], !playedGifs.contains(wordStr) {
               
//                playedGifs.insert(wordStr)
                
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
    
    
    @IBAction func hangupcall(_ sender : Any)
    {
        socketsClass.shared.GroupCall_End(caller1: String(userfirst_id), caller2: String(usersecond_id))
        
//        self.speechRecognizer!.isStopping = true
//        self.speechRecognizer!.stopRecognition()
        
        self.navigationController?.popViewController(animated: true)
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
        
        
//        setupSpeechToText()
        
        NotificationCenter.default.addObserver(self, selector: #selector(messageRecieved(_:)), name: Notification.Name("ChatMsg_Recieved"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatEnded), name: Notification.Name("groupChatEnd"), object: nil)
    }
    deinit {
     
     speechRecognizer?.isStopping = false
     speechRecognizer?.stopRecognition()
    }

    
    func TexttoSpeech(text: String)
    {
        
        print("it is speacking now")
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
        speechRecognizer = SpeechRecognizer(blind_normalGroup: self ,friendfirst: String(userfirst_id) , friendsecond: String(usersecond_id) )
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

    func speak(text: String) {
        // Check if the speech synthesizer is speaking
        if speechSynthesizer.isSpeaking {
            print("Speech synthesizer is currently speaking. Stopping.")
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
        
        // Debugging output
        print("Speaking text: \(text)")
        
        // Speak the utterance
//        speechSynthesizer.speak(utterance)
        
       
    }

    
  

  
}
