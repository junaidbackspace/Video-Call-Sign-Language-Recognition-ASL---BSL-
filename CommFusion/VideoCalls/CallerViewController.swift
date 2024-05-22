//
//  CallerViewController.swift
//  SimpleWebRTC
//
//  Created by Umer Farooq on 14/02/2024.
//  Copyright © 2024 n0. All rights reserved.
//

import UIKit
import AVFoundation

class CallerViewController: UIViewController, AVAudioPlayerDelegate {
    var musicPlayer: AVAudioPlayer?
    
    static let shared = CallerViewController()
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
    var videocall_id = 0

    func Call_StartAPI(caller : Int ,reciver : Int )
    {
        let Url = "\(Constants.serverURL)/video-call/start"
        
        let Dic: [String: Any] = [
            "caller_id": caller,
              "receiver_id": reciver ]
    
        print("\n\t\t----> \(Dic)")
        serverWrapper.insertData(baseUrl: Url,  userDictionary: Dic) { responseString, error in
            if let error = error {
                print("\n\nError:", error)
               }

            if let responseString = responseString {
                print("response:", responseString)
                if let responsedata = responseString.data(using : .utf8) , let jsonresponse = try? JSONSerialization.jsonObject(with: responsedata, options: []) as? [String:Any]{
                    
                    if let videocallid = jsonresponse["video_call_id"] as? Int {
                        print("Video call ID: \(videocallid)")
                        self.videocall_id = videocallid
                    }
                }
                
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
                print("=====>rigining now: \(text)")
                if text != "Busy in other call..."{
                self.playMusic(fileName: "onhold")
                }
                else{
                    self.playBeepMusic(fileName: "beep")
                    print("\n\nwitin callerview else")
                    DispatchQueue.main.asyncAfter(deadline: .now()+2)
                    {
                       
                        self.captureSession?.stopRunning()
                        self.navigationController?.popViewController(animated: true)
                    }
                   
                }
            }
        }
    @objc func handleCallNotification(_ notification: Notification) {
        
        //stoping rigning notift tune
     
        self.stopMusic()
        
        let controller = (self.storyboard?.instantiateViewController(identifier: "videoCallscreen"))! as ViewController
        controller.isReciever = 0
        controller.reciver = recieverid
        controller.callFriendId = String(recieverid)
        controller.v_id = videocall_id
        controller.modalPresentationStyle = .fullScreen
          self.navigationController?.pushViewController(controller, animated: true)
    }
    
        // Don't forget to remove observer when the ViewController is deallocated
        deinit {
            NotificationCenter.default.removeObserver(self)
          
        }
    
       override func viewDidLoad() {
           super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: Notification.Name("UpdateLabelNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleCallNotification(_:)), name: NSNotification.Name("callacepted"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(callcenlled), name: Notification.Name("CallCancelledFromCallerNotification"), object: nil)
           
       
       
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
        
        
//        response: {"message":"Video call started successfully","video_call_id":300}
//        Video call ID: 300
//        here is reciver id  : 2
//        Connecting in webSocket
//        local side initiating call: ["type": "call", "from": "1", "to": "2", "videocallid": "300"]
        
//        MARK:-
        //calling api's then sockets
        DispatchQueue.global().async { [self] in
            Call_StartAPI(caller: callerid, reciver: recieverid)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                
                let friendid = String(recieverid)
                print("here is reciver id  : \(friendid)")
                socketsClass.shared.initiateCall(with: friendid , videocall_id : videocall_id)
            }
        }
        
        
       
       }
       
    @objc func callcenlled(){
     
        let websoc = socketsClass()
        let friendid = String(recieverid)
        print("here is Friend id  : \(friendid)")
        
        websoc.CancellCall(with: friendid)
        print(" call cancelled")
        captureSession?.stopRunning()
        self.navigationController?.popViewController(animated: true)
        
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
        if lbl_is_ringing.text! == "Busy in other call..."{
            print("User is Busy")
            print("==>",lbl_is_ringing.text)
            captureSession?.stopRunning()
            self.navigationController?.popViewController(animated: true)
        }
        else{
           
            let websoc = socketsClass.shared
     
        let friendid = String(recieverid)
        print("here is Friend id  : \(friendid)")
        
        websoc.CancellCall(with: friendid)
        captureSession?.stopRunning()
        self.navigationController?.popViewController(animated: true)
           dismiss(animated: true, completion: nil)
        }
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
    
    func playMusic(fileName: String) {
            guard let path = Bundle.main.path(forResource: fileName, ofType: "wav") else {
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
                print("\nplaying tune....\n")
                
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
    
    func stopMusic() {
        print("stoping ringing notify tone...\n")
        self.musicPlayer?.stop()
        self.musicPlayer = nil
            do {
                try AVAudioSession.sharedInstance().setActive(false)
            } catch {
                print("Error deactivating AVAudioSession: \(error.localizedDescription)")
            }
        }
    
    func playBeepMusic(fileName: String) {
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
                print("\nplaying tune....\n")
                
            } catch {
                print("Error playing music: \(error.localizedDescription)")
            }
        }
}
