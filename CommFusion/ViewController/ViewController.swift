//
//  ViewController.swift
//  SimpleWebRTC
//
//  Created by n0 on 2019/01/05.
//  Copyright © 2019年 n0. All rights reserved.
//

import UIKit
import Starscream
import WebRTC
import UIKit
import Speech

class ViewController: UIViewController, WebSocketDelegate, WebRTCClientDelegate, CameraSessionDelegate {
    
    
    func change_localview_Color(color : UIColor , Glowcolor : UIColor) {
        
        
        localVideoView?.layer.borderColor = color.cgColor
        localVideoView?.layer.borderWidth = 2.0

                // Add glow effect
        localVideoView?.layer.shadowColor = Glowcolor.cgColor
        localVideoView?.layer.shadowRadius = 10.0
        localVideoView?.layer.shadowOpacity = 1.0
        localVideoView?.layer.shadowOffset = CGSize.zero
        localVideoView?.layer.masksToBounds = false
    }
    
    func removeBorderAndGlow() {
        DispatchQueue.main.async {
            self.localVideoView?.layer.borderColor = UIColor.clear.cgColor
            self.localVideoView?.layer.borderWidth = 0.0

            // Remove glow effect
            self.localVideoView?.layer.shadowColor = UIColor.clear.cgColor
            self.localVideoView?.layer.shadowRadius = 0.0
            self.localVideoView?.layer.shadowOpacity = 0.0
            self.localVideoView?.layer.shadowOffset = CGSize.zero
            self.localVideoView?.layer.masksToBounds = true
        }
            
        }
  
    var shouldtext_To_speech = false
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var playerItem: AVPlayerItem?
    var SignsvideoContainerView: UIView?
    
    var speechRecognizer: SpeechRecognizer?
    var isAutoLockEnabledBeforeCall: Bool = true

    let font_sizeDefault = UserDefaults.standard
    let caption_opacityDefault = UserDefaults.standard
   
    private var speechSynthesizer =   AVSpeechSynthesizer()
    var serverWrapper = APIWrapper()
    var isReciever = 0
    var callFriendId = ""
    enum messageType {
        case greet
        case introduce
        
        func text() -> String {
            switch self {
            case .greet:
                return "Hello!"
            case .introduce:
                return "I'm " + UIDevice.modelName
            }
        }
    }
    
    @IBAction func btnAddCall(_ sender  : Any)
    {
        print("Adding friend in video call")
       let controller =  self.storyboard?.instantiateViewController(identifier: "addCallScreen") as! AddFriendViewController
        controller.callledFriendId = Int(callFriendId)!
        controller.vid = self.v_id
        controller.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(controller, animated: true)
        
        
    }
   
    @IBOutlet weak var msgtextView: UITextView!

    @IBOutlet weak var OutLet_Mic_Mute: UIButton!
    @IBOutlet weak var OutLet_speaker_Mute: UIButton!
    @IBOutlet weak var OutLetHangUp: UIButton!
 
    @IBOutlet weak var OutLetSwitchCam: UIButton!
    @IBOutlet weak var OutletbtnAddCall : UIButton!
    let myLangType = UserDefaults.standard.string(forKey: "disabilityType")!

    
    
   
    
    func configureScrollView(with text: String) {
        
       
            // Set your text
        msgtextView.text = text
               
               // Ensure the text view does not allow editing
        msgtextView.isEditable = false
               
               // Ensure the text view does not allow vertical scrolling
        msgtextView.showsVerticalScrollIndicator = true
        msgtextView.showsHorizontalScrollIndicator = false
               
               // Ensure the text view scrolls horizontally
        msgtextView.isScrollEnabled = true
        
        msgtextView.textContainer.lineBreakMode = .byWordWrapping
        msgtextView.textContainer.heightTracksTextView = true
        msgtextView.textContainer.widthTracksTextView = false
               
               // Scroll to the end of the content
        scrollToBottom()
           }

          
    func scrollToBottom() {
        let bottomOffset = CGPoint(x: 0, y: msgtextView.contentSize.height - (msgtextView.bounds.size.height+5))
        msgtextView.setContentOffset(bottomOffset, animated: true)
        }
    
    @IBAction func btn_SwitchCamera(_ sender: Any) {
        webRTCClient.switchCameraPosition()
    }
    var ismute_speaker = true
    @IBAction func btn_Speaker_Mute(_ sender: Any) {
        print("Entered in Mute")
        webRTCClient.toggleSpeakerMute(muted: ismute_speaker)
        ismute_speaker = !ismute_speaker
        if ismute_speaker{
            OutLet_speaker_Mute.setBackgroundImage(UIImage(systemName: "speaker.slash.fill") , for: .normal)
        }
        else{
            OutLet_speaker_Mute.setBackgroundImage(UIImage(systemName: "speaker.wave.2.fill") , for: .normal)
        }
        print("is Speaker mute : \(ismute_speaker)")

    }
    
    var ismute_mic = true
    @IBAction func btn_Mic_Mute(_ sender: Any) {
        print("Entered in Mute")
        webRTCClient.toggleMicMute(muted: ismute_mic)
        ismute_mic = !ismute_mic
        if ismute_mic{
            OutLet_Mic_Mute.setBackgroundImage(UIImage(systemName: "mic.slash.fill") , for: .normal)
        }
        else{
            OutLet_Mic_Mute.setBackgroundImage(UIImage(systemName: "mic.fill") , for: .normal)
        }
        print("is Mic mute : \(ismute_mic)")

    }
    
    @IBAction func btnHangupCall(_ sender: Any) {
        print("Entered in hangup")
        
        if ShouldGroupChat == true && speechRecognizer?.isStopping == false{
            print("Turning off speech Recognizer in GroupChat End")
            ShouldGroupChat = false
            speechRecognizer?.isStopping = true
            speechRecognizer?.stopRecognition()
        }
        
        UserDefaults.standard.setValue("0", forKey: "groupchat")
        hangupButtonTapped()
        
        
    }
    
   
    func textmsg(msg:String)
    {
     
       self.webRTCClient.sendMessge(message: msg)
        
    }
    

    //MARK: - Properties
    var webRTCClient: WebRTCClient!
    
    var socket: WebSocket!

    
    var cameraSession: CameraSession?
    
    
    // You can create video source from CMSampleBuffer :)
    var useCustomCapturer: Bool = false
    var cameraFilter: CameraFilter?
    
    
    
  
    //MARK: - ViewController Override Methods ----------------------------
    
   var userID = ""
    
   
   
    @objc func endCall() {
        print("Remote side closing call")
        DispatchQueue.main.async {
        print("updating check of voice recognizer")
            if self.myLangType == "blind"{
            self.speechRecognizer?.isStopping = true
            self.speechRecognizer?.stopRecognition()
            }
            
            
            print("\nNOW IN VIEWCONTROLLER TO END CALL")
            self.CallEnd_API(vid: self.v_id, userid: Int(self.userID)!)
        }
            webRTCClient.disconnect()
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
                self.navigationController?.popViewController(animated: true)
            }
        }
        
        deinit {
            
           //Screen lock release
            print("updating check of voice recognizer")
            speechRecognizer?.isStopping = false
            speechRecognizer?.stopRecognition()
         restoreAutoLock()
            NotificationCenter.default.removeObserver(self, name: .didReceiveMessage, object: nil)
               
            NotificationCenter.default.removeObserver(self)
            
            if let playerItem = playerItem {
                        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
                    }
            //shifted in hangupcall
//            webRTCClient.delegate = nil // Remove delegate
//            webRTCClient.disconnect()
//            isReciever = 0
//            socket.delegate = nil
//            socket.disconnect()
        }
    
    
    @objc func ChatmessageRecieved(_ notification : Notification)
     {
     print("displaying chat message")
         
             if let Message = notification.userInfo?["message"] as? String {
         
            msgtextView.text = "Chat Member : "+Message
             print(" chat message is : \(Message)")
             
             }
         
     }
    
    @objc func handleMessage(_ notification: Notification) {
            guard let messageTuple = notification.userInfo?["messageTuple"] as? (WebSocketClient, String) else { return }
            let (socket, text) = messageTuple
           self.websocketDidReceiveMessage(socket: socket, text: text)
           
        }
    
    func CallAccept_API(vid : Int ,userid : Int )
    {
      
        let Url = "\(Constants.serverURL)/video-call/accept"
        
        let Dic: [String: Any] = [
            "video_call_id": vid,
              "user_id": userid ]
    
        serverWrapper.insertData(baseUrl: Url,  userDictionary: Dic) { responseString, error in
            if let error = error {
                print("===>Error:", error)
               }

            if let responseString = responseString {
              
                print("response:", responseString)
              
           }
            print("DIC : \(Dic)")
        }
    }
    func CallEnd_API(vid : Int ,userid : Int )
    {
       
        let Url = "\(Constants.serverURL)/video-call/end-call"
        
        let Dic: [String: Any] = [
            "video_call_id": vid,
              "user_id": userid ]
    
        serverWrapper.insertData(baseUrl: Url,  userDictionary: Dic) { responseString, error in
            if let error = error {
                print("===>call end Error:", error)
               }

            if let responseString = responseString {
                
                print("response:", responseString)
              
           }
            print("DIC : \(Dic)")
        }
    }
    
    func disableAutoLock() {
           // Save the current auto-lock state
           isAutoLockEnabledBeforeCall = UIApplication.shared.isIdleTimerDisabled
           
           // Disable auto-lock
           UIApplication.shared.isIdleTimerDisabled = true
       }
       
       func restoreAutoLock() {
           // Restore auto-lock to its previous state
           UIApplication.shared.isIdleTimerDisabled = isAutoLockEnabledBeforeCall
       }
    
    var v_id = 0
    
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        
        if UserDefaults.standard.object(forKey: "disabilityType") == nil {
            
            UserDefaults.standard.set("normal", forKey: "disabilityType")
        }
        
        let myLangType = UserDefaults.standard.string(forKey: "disabilityType")!
        
        disabilitytype_check_msg = true
        let connectingView = ConnectingView(frame: CGRect(x: 0, y: 0, width: 100, height: 10))
                connectingView.center = view.center
        connectingView.startAnimating()
        self.view.addSubview(connectingView)
        
        disableAutoLock()
         userID = UserDefaults.standard.string(forKey: "userID")!
    
        
       
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleMessage(_:)), name: .didReceiveMessage, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatmessageRecieved(_:)), name: Notification.Name("ChatMsg_Recieved"), object: nil)
            
        
        NotificationCenter.default.addObserver(self, selector: #selector(hunguptapedbyOtherCaller), name: Notification.Name("CallEndedNotification"), object: nil)
           
        
        NotificationCenter.default.addObserver(self, selector: #selector(EnableGroup_Chat(_:)), name: Notification.Name("Noti_GroupChatAccepted"), object: nil)
        
        
        #if targetEnvironment(simulator)
        // simulator does not have camera
        self.useCustomCapturer = false
        #endif
        
        webRTCClient = WebRTCClient()
        webRTCClient.delegate = self
       
        webRTCClient.setup(videoTrack: true, audioTrack: true, dataChannel: true, customFrameCapturer: useCustomCapturer)
        
        
        if useCustomCapturer {
            print("--- use custom capturer ---")
            self.cameraSession = CameraSession()
            self.cameraSession?.delegate = self
            self.cameraSession?.setupSession()
            
            self.cameraFilter = CameraFilter()
        }
        
        
        
         let ipAddress = Constants.nodeserverIP
       self.socket = WebSocket(url: URL(string: "ws://" + ipAddress + ":8081")!)
       socket.delegate = self
        self.socket.connect()
        
        if isReciever == 0{
            
        self.callButtonTapped()
            print("====>>> shared socket id \(v_id) , Friend id : \(callFriendId)")
            self.CallAccept_API(vid: v_id, userid: Int(self.userID)!)
            self.CallAccept_API(vid: v_id, userid: Int(self.callFriendId)!)
        }
        //call reciever accepted call
        else{
            
        }
     
        
        // Initialize speechRecognizer with a reference to self
        speechRecognizer = SpeechRecognizer(viewController: self)
        
        OutLet_Mic_Mute.layer.zPosition = 1
        OutLet_speaker_Mute.layer.zPosition = 1
        OutLetHangUp .layer.zPosition = 1
        msgtextView.layer.zPosition = 1
        OutLetSwitchCam.layer.zPosition = 1
        OutletbtnAddCall.layer.zPosition = 1
    
        if myLangType == "deaf"{
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
               doubleTapGestureRecognizer.numberOfTapsRequired = 2
               
               // Add the gesture recognizer to the view
               view.addGestureRecognizer(doubleTapGestureRecognizer)
        }
        
        self.setupUI()
    }
    
    var groupFriendId = " "
    var ShouldGroupChat = false
    @objc func EnableGroup_Chat(_ notification: Notification)
    {
       if !ShouldGroupChat{ //if already enabled
            
        print("Entered in Group Chat Enable")
        self.ShouldGroupChat = true
        if let value = notification.userInfo?["callerid"] as? String {
            
            if myLangType == "deaf" //|| myLangType == "blind"
           {
            webRTCClient.ShouldGroupChat = true
            webRTCClient.groupFriendId = value
           }
           else{
            //already speech recognizer is on
            if  !speechRecognizer!.isSpeechOn{
            if speechRecognizer?.isStopping == false{
            print("Enabling group chat in view controller by turning on S_Recognizer")
            
            speechRecognizer?.ShouldGroupChat = true
            speechRecognizer?.groupFriendId = value
            speechRecognizer?.isStopping = false
            self.speechRecognizer!.startRecognition()
            }
            }
            
//            if speechRecognizer?.isStopping != false{
//            print("Enabling group chat in view controller by turning on S_Recognizer")
//
//            speechRecognizer?.ShouldGroupChat = true
//            speechRecognizer?.groupFriendId = value
//            speechRecognizer?.isStopping = false
//            self.speechRecognizer!.startRecognition()
//            }
            else{
                print("Speech Recog Already on")
            }
            
            
           }
        }
        }
    }
    
    var overlayView: UIView!

    
    var static_frameCheck = true
    @objc func handleDoubleTap(_ sender: UITapGestureRecognizer) {
        
        //toggle static , dynamic
        if static_frameCheck {
            webRTCClient.stopStaticCaptureFrames()
            performColorFade()
            DispatchQueue.main.asyncAfter(deadline: .now()+2)
            {
                self.webRTCClient.stop_dynamicframe = true
                self.webRTCClient.should_predictWord_check = true
//                self.webRTCClient.startCaptureFrames()
                self.static_frameCheck = false
                
                //predicting word...
                self.webRTCClient.start_static_CaptureFrames()
            }
            
        }
        else{
            performColorFade()
            DispatchQueue.main.asyncAfter(deadline: .now()+2)
            {
                self.webRTCClient.stop_dynamicframe = false
                self.webRTCClient.stop_Staticframe_check = true
                self.webRTCClient.should_predictWord_check = false
                self.webRTCClient.Permanent_stopCaptureFrames()
                self.webRTCClient.start_static_CaptureFrames()
            }
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
    
    
    @objc func dragview(_ gestureRecognizer: UIPanGestureRecognizer) {
            guard let draggedView = gestureRecognizer.view else { return }
            
            let translation = gestureRecognizer.translation(in: self.view)
            
            if gestureRecognizer.state == .changed {
                draggedView.center = CGPoint(x: draggedView.center.x + translation.x,
                                              y: draggedView.center.y + translation.y)
                gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
            }
        }
    
    override func viewDidAppear(_ animated: Bool) {
       
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - UI
    
    var localVideoView : UIView?
    private func setupUI(){
        
        
       
        //MARK:- setting user defined size and color
        
        let size = font_sizeDefault.integer(forKey: "fontsize")
        
        if let textViewText = msgtextView.text {
            let textViewSize = msgtextView.sizeThatFits(CGSize(width: msgtextView.frame.width, height: CGFloat.greatestFiniteMagnitude))
            print("Text view size: \(textViewSize)")
        }
        
        
        
        guard let currentFont = msgtextView.font else { return }
        let newFontSize = currentFont.pointSize + CGFloat(size)
              msgtextView.font = currentFont.withSize(newFontSize)
        
        
//        let currentFontSize = lblmsg.font.pointSize
//        lblmsg.font = lblmsg.font.withSize(currentFontSize+CGFloat(size))
//
        let currentHeight = msgtextView.frame.size.height
       
        msgtextView.frame.size.height = currentHeight + CGFloat(size)
       
        
        if let color = UserDefaults.standard.color(forKey: "color") {
            
            msgtextView.textColor = color
//            lblmsg.textColor = color
        }
        
        let opacity = caption_opacityDefault.float(forKey: "caption")
        msgtextView.alpha = CGFloat(opacity)
        
        
        
        //for new device when defaults not set
        let color = UserDefaults.standard.color(forKey: "color")
        if color == nil{
            let opacity = caption_opacityDefault.float(forKey: "caption")
            msgtextView.alpha = CGFloat(1)
            
        }
        
         //MARK:- setting user defined size and color
        
        let remoteVideoViewContainter = UIView(frame: CGRect(x: 0, y: 0, width: ScreenSizeUtil.width(), height: ScreenSizeUtil.height()))
        remoteVideoViewContainter.backgroundColor = .white
        self.view.addSubview(remoteVideoViewContainter)
        
        let remoteVideoView = webRTCClient.remoteVideoView()
        webRTCClient.setupRemoteViewFrame(frame: CGRect(x: 0, y: 0, width: ScreenSizeUtil.width(), height: ScreenSizeUtil.height()))
        remoteVideoView.center = remoteVideoViewContainter.center
        remoteVideoViewContainter.addSubview(remoteVideoView)
        
         localVideoView = webRTCClient.localVideoView()
        webRTCClient.setupLocalViewFrame(frame: CGRect(x: 0, y: 0, width: ScreenSizeUtil.width()/3, height: ScreenSizeUtil.height()/4))
        localVideoView?.center.y = self.view.center.y - 180
        localVideoView?.center.x = self.view.center.x + 120
        localVideoView?.subviews.last?.isUserInteractionEnabled = true
        self.view.addSubview(localVideoView!)
       
        
        
        
        let localVideoViewButton = UIButton(frame: CGRect(x: 0, y: 0, width: ScreenSizeUtil.width()/3, height:  ScreenSizeUtil.height()/4))
        localVideoViewButton.backgroundColor = UIColor.clear
        localVideoViewButton.addTarget(self, action: #selector(self.localVideoViewTapped(_:)), for: .touchUpInside)
        localVideoView?.addSubview(localVideoViewButton)
        
     
        remoteVideoViewContainter.addSubview(OutLet_Mic_Mute)
        remoteVideoViewContainter.addSubview(OutLet_speaker_Mute)
        remoteVideoViewContainter.addSubview(OutLetHangUp)
        remoteVideoViewContainter.addSubview(OutLetSwitchCam)
        remoteVideoViewContainter.addSubview(OutletbtnAddCall)

        remoteVideoViewContainter.addSubview(msgtextView)
       
        
        //Adding drag Gesture in local video view
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(dragview(_:)))
        localVideoView?.addGestureRecognizer(panGesture)
        
        // Create and configure the overlay view
               overlayView = UIView(frame: view.bounds)
               overlayView.backgroundColor = UIColor.clear
               overlayView.isUserInteractionEnabled = false
               view.addSubview(overlayView)
    }
    var reciver = 0

    
    // MARK: - UI Events
    @objc func callButtonTapped(){
       
     
        if !webRTCClient.isConnected {
            
            print("initiating call ...")
              
            webRTCClient.connect(onSuccess: { (offerSDP: RTCSessionDescription) -> Void in
                self.sendSDP(sessionDescription: offerSDP)
            })
           
            
        
        }
    }
    
    
  

    
    @objc func hangupButtonTapped(){
        print("hangup Tapped")
//        if myLangType == "blind"
//        {
//        speechRecognizer?.isStopping = true
//        speechRecognizer?.stopRecognition()
//        }
        self.ShouldGroupChat = false
        speechRecognizer?.ShouldGroupChat = false
        
        if speechRecognizer?.isStopping == false
        {
            print("within hangup tap speech recognizer turning off ")
            speechRecognizer?.isStopping = true
            speechRecognizer?.stopRecognition()
        }
        
        if shouldtext_To_speech {
            stopSpeaking()
            shouldtext_To_speech = false
        }
        
        webRTCClient.stop_dynamicframe = false
      CallEnd_API(vid: self.v_id, userid: Int(self.userID)!)

        let endCallData: [String: Any] = [
            "type": "call_ended",
            "callerID": callFriendId,
            "callenderID": userID
        ]

        do {
            print(endCallData)
            let jsonData = try JSONSerialization.data(withJSONObject: endCallData, options: [])
            socket.write(data: jsonData) { [weak self] in
                guard let self = self else { return }
                
                
            }
            self.webRTCClient.delegate = nil // Remove delegate
            self.isReciever = 0
            self.disconnectWebRTC()
        } catch {
            print("Error serializing end call data: \(error)")
        }
       
       
    }
    
    
   
    
    func disconnectWebRTC() {
        
        UserDefaults.standard.setValue("0", forKey: "groupchat")
        var chatmemberID = "0"
        if UserDefaults.standard.object(forKey: "groupchatmember") != nil
        {
            chatmemberID  = UserDefaults.standard.string(forKey: "groupchatmember")!
        }
        
       
        socketsClass.shared.EndGroupChat(friendId: chatmemberID)
        print("getting back to screen call is ended")
            if webRTCClient.isConnected {
                webRTCClient.disconnect()
                DispatchQueue.main.async {
                    print("Closing Video Call")
                    self.navigationController?.popViewController(animated: true)
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                DispatchQueue.main.async {
                    print("WebRTC is disconnected , now backing to screen")
                    self.navigationController?.popViewController(animated: true)
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }


//        socket.connect()
    
    
    @objc func sendMessageButtonTapped(_ sender: UIButton){
//        webRTCClient.sendMessge(message: (sender.titleLabel?.text!)!)
//        if sender.titleLabel?.text == messageType.greet.text() {
//            sender.setTitle(messageType.introduce.text(), for: .normal)
//        }else if sender.titleLabel?.text == messageType.introduce.text() {
//            sender.setTitle(messageType.greet.text(), for: .normal)
//        }
    }
    

    
    @objc func likeButtonTapped(_ sender: UIButton){
//        let data = likeStr.data(using: String.Encoding.utf8)
//        webRTCClient.sendData(data: data!)
    }
    
    @objc func localVideoViewTapped(_ sender: UITapGestureRecognizer) {
//        if let filter = self.cameraFilter {
//            filter.changeFilter(filter.filterType.next())
//        }
        webRTCClient.switchCameraPosition()
    }

    var userid = String(UserDefaults.standard.integer(forKey: "userID"))
    
    // MARK: - WebRTC Signaling
     func sendSDP(sessionDescription: RTCSessionDescription){
        var type = ""
        if sessionDescription.type == .offer {
            type = "offer"
            let sdp = SDP(sdp: sessionDescription.sdp)
                let signalingMessage = SignalingMessage(type: type, sessionDescription: sdp, candidate: nil, from:callFriendId , to:userid)
                do {
                    let data = try JSONEncoder().encode(signalingMessage)
                    let message = String(data: data, encoding: .utf8)!
                    
                    if socketsClass.shared.isConnected() {
                        print("\nnow caller offering sdp to caller")
                        socketsClass.shared.socket.write(string: message)
                    }
                    else{
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.1)
                        {
                       
                            socketsClass.shared.socket.connect()
                            socketsClass.shared.socket.write(string: message)
                        }
                        print(">>>>>>>>socket reconecting...")
                        if socketsClass.shared.isConnected() {
                        print("\n===>in offer , socket reconnected")
                            socketsClass.shared.socket.write(string: message)
                        }
                        else{
                            DispatchQueue.main.asyncAfter(deadline: .now()+0.1)
                            {print("\n<<<====== else in offer , socket reconnected")
                           
                                socketsClass.shared.socket.connect()
                                socketsClass.shared.socket.write(string: message)
                                
                                let connectingView = ConnectingView(frame: CGRect(x: 0, y: 0, width: 100, height: 10))
                                connectingView.center = self.view.center
                                connectingView.startAnimating()
                            }
                        }
                    }
                } catch {
                    print(error)
                }
        }else if sessionDescription.type == .answer {
            type = "answer"
            let sdp = SDP(sdp: sessionDescription.sdp)
            let signalingMessage = SignalingMessage(type: type, sessionDescription: sdp, candidate: nil, from:self.callFriendId  , to:self.userid )
                do {
                    let data = try JSONEncoder().encode(signalingMessage)
                    let message = String(data: data, encoding: .utf8)!
                    
                    if socketsClass.shared.isConnected() {
                        print("\nnow Reciever answering sdp to caller ")
                        socketsClass.shared.socket.write(string: message)
                        
                    }
                    else{
//
                        socketsClass.shared.connectSocket()
                        
                        print("\n===>in Answer , socket reconnected")
                        socketsClass.shared.socket.write(string: message)
                    }
                } catch {
                    print(error)
                }
        }
       
        
    }
    
    public func sendCandidate(iceCandidate: RTCIceCandidate){
        let candidate = Candidate.init(sdp: iceCandidate.sdp, sdpMLineIndex: iceCandidate.sdpMLineIndex, sdpMid: iceCandidate.sdpMid!)
        let signalingMessage = SignalingMessage.init(type: "candidate", sessionDescription: nil, candidate: candidate, from: callFriendId, to: userid)
        do {
            let data = try JSONEncoder().encode(signalingMessage)
            let message = String(data: data, encoding: String.Encoding.utf8)!
            
            if socketsClass.shared.isConnected() {
                print("\nwriting candidate on socketttt")
                socketsClass.shared.socket.write(string: message)
            }
        }catch{
            print(error)
        }
    }
    
}

// MARK: - WebSocket Delegate
extension ViewController {
    
    func websocketDidConnect(socket: WebSocketClient) {
        let userID = UserDefaults.standard.string(forKey: "userID")!
          
        print("-- in call websocket did connect --\(userID)")
        let authData: [String: Any] = ["userId": userID]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: authData, options: [])
            socket.write(data: jsonData)
        } catch {
            print("Error serializing authentication data: \(error)")
        }

    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("-- websocket did disconnect --")
//        wsStatusLabel.text = wsStatusMessageBase + "disconnected"
//        wsStatusLabel.textColor = .red
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        
        do{
            let signalingMessage = try JSONDecoder().decode(SignalingMessage.self, from: text.data(using: .utf8)!)
            if signalingMessage.type == "call_ended"{
                print("call ended by user in viewcontroller")
                self.hunguptapedbyOtherCaller()
            }
            
            else if signalingMessage.type == "offer" {
                print("offer recieved in view controller")
                webRTCClient.receiveOffer(offerSDP: RTCSessionDescription(type: .offer, sdp: (signalingMessage.sessionDescription?.sdp)!), onCreateAnswer: {(answerSDP: RTCSessionDescription) -> Void in
                    self.sendSDP(sessionDescription: answerSDP)
                })
            }else if signalingMessage.type == "answer" {
                print("Answer recieved:")
             
                webRTCClient.receiveAnswer(answerSDP: RTCSessionDescription(type: .answer, sdp: (signalingMessage.sessionDescription?.sdp)!))
                
            }else if signalingMessage.type == "candidate" {
                print("Candidate recieved")
                
                let candidate = signalingMessage.candidate!
                webRTCClient.receiveCandidate(candidate: RTCIceCandidate(sdp: candidate.sdp, sdpMLineIndex: candidate.sdpMLineIndex, sdpMid: candidate.sdpMid))
            }
            else{
                print("something revieved:\n\(signalingMessage)")
            }
        }catch{
            print(error)
        }
        
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) { }
}

var disabilitytype_check_msg = true

// MARK: - WebRTCClient Delegate
extension ViewController {
    func didGenerateCandidate(iceCandidate: RTCIceCandidate) {
        self.sendCandidate(iceCandidate: iceCandidate)
    }
    
    func didIceConnectionStateChanged(iceConnectionState: RTCIceConnectionState) {
        var state = ""
        
        switch iceConnectionState {
        case .checking:
            state = "checking..."
        case .closed:
            state = "closed"
        case .completed:
            state = "completed"
        case .connected:
            state = "connected"
        case .count:
            state = "count..."
        case .disconnected:
            state = "disconnected"
        case .failed:
            state = "failed"
        case .new:
            state = "new..."
        }
        //self.webRTCStatusLabel.text = self.webRTCStatusMesasgeBase + state
    }
    
    
    func didConnectWebRTC() {
       // self.webRTCStatusLabel.textColor = .green
        // MARK: Disconnect websocket
//        self.socket.disconnect()
    }
    
    func didDisconnectWebRTC() {
        //self.webRTCStatusLabel.textColor = .red
    }
    
    func didOpenDataChannel() {
        print("did open data channel")
    }
        

    func didReceiveData(data: Data) {
        var test = "hi"
        if data == test.data(using: String.Encoding.utf8) {
            if let Message = String(data: data, encoding: .utf8) {
                
//            lblmsg.text = Message
            }
            print("String Message : \(data)")
        }
    }
    
   
    
    func didReceiveMessage(message: String) {
        print("viewController message recieved : \(message)")
        
       
        if disabilitytype_check_msg{
            
            print("From viewcontroller Setting Loud Speaker")
            
            webRTCClient.configureAudioSessionForLoudSpeaker()
        
            if myLangType == "deaf"
            {
                webRTCClient.toggleSpeakerMute(muted: true)
                webRTCClient.start_static_CaptureFrames()
                
            }
            
            // for (normal and blind) to (deaf) turn speech on
           else if myLangType != "deaf" && message == "deaf"
            {
            
            DispatchQueue.main.async {
                                print("++++++++Starting REcognition.....++++++")
                                self.speechRecognizer!.startRecognition()
                            }
            }
           
           else
           {
            // Set Loud Speaker
            webRTCClient.configureAudioSessionForLoudSpeaker()
        
           }
                
//            webRTCClient.localVideoTrack.isEnabled = false
//            }
            
            if message == "deaf"
            {
                print("Making Speaking text true")
                shouldtext_To_speech = true
                
                
            }
            

            self.configureScrollView(with: message)

            disabilitytype_check_msg = false
        }
        
       
        if message.count == 1 {
            print("Starting video of sign")
            self.play_sign_video(name: message)
            
            
            DispatchQueue.main.asyncAfter(deadline: .now()+3)
            {
                print("\n::::::><after 2 sec cleaning Video player\n")
                self.cleanupPlayer()
            }
        }
        else if message == " "{
            stopSpeaking()
            cleanupPlayer()
        }
        else {
            
        }
        
        //for text to speech
        if shouldtext_To_speech
        {
            print("Speaking")
            //speaking the message
//            configureAudioSession()
            speak(text: message)
        }
        DispatchQueue.main.async {
        self.configureScrollView(with: message)
        }
    }
        
//    func configureAudioSession() {
//        do {
//            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
//            try AVAudioSession.sharedInstance().setActive(true)
//        } catch {
//            print("Failed to set up audio session: \(error)")
//        }
//    }
    
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
        speechSynthesizer.speak(utterance)
        
       
    }

    
    func stopSpeaking() {
        // Stop the speech synthesizer from speaking
        speechSynthesizer.stopSpeaking(at: .immediate)
    }

    
    @objc func hunguptapedbyOtherCaller(){
        
        self.ShouldGroupChat = false
        speechRecognizer?.ShouldGroupChat = false
        
        if speechRecognizer?.isStopping == false
        {
            print("within hangup tap speech recognizer turning off ")
            speechRecognizer?.isStopping = true
            speechRecognizer?.stopRecognition()
        }
        
        if shouldtext_To_speech {
            stopSpeaking()
            shouldtext_To_speech = false
        }
        
            webRTCClient.stop_dynamicframe = false
            self.webRTCClient.delegate = nil // Remove delegate
            self.isReciever = 0
            self.disconnectWebRTC()
       
    
        
//        if ShouldGroupChat == true && speechRecognizer?.isStopping == false{
//            print("within speech recognizer check , turning off it")
//            ShouldGroupChat = false
//            speechRecognizer?.isStopping = true
//            speechRecognizer?.stopRecognition()
//            speechRecognizer?.ShouldGroupChat = false
//        }
//
//
//
//        //turning of speech
//        if shouldtext_To_speech {
//            print("turning off speech in hangup by other user")
//            stopSpeaking()
//            shouldtext_To_speech = false
//        }
//
//
//        self.disconnectWebRTC()
//
//        DispatchQueue.main.async {
//            print("Returning back because user ends call")
//                   self.navigationController?.popViewController(animated: true)
//                   self.navigationController?.popViewController(animated: true)
//               }
    }
  
    func cleanupPlayer() {
           if let playerItem = playerItem {
               NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
           }
           playerLayer?.removeFromSuperlayer()
           playerLayer = nil
           playerItem = nil
           player = nil
       }

      
//           cleanupPlayer()
       
   

    func play_sign_video(name  : String) {
        
        // Clean up any existing player and observers
        cleanupPlayer()

        guard let filePath = Bundle.main.path(forResource: name.lowercased(), ofType: "mp4") else {
            print("Video file not found.")
            return
        }

        let videoURL = URL(fileURLWithPath: filePath)
        playerItem = AVPlayerItem(url: videoURL)
        player = AVPlayer(playerItem: playerItem)
        playerLayer = AVPlayerLayer(player: player)
        
        let videoWidth: CGFloat = 200.0 // specify desired width
               let videoHeight: CGFloat = 150.0 // specify desired height
               let xPos: CGFloat = (self.view.bounds.width - videoWidth) / 2 // center horizontally
               let yPos: CGFloat = (self.view.bounds.height - videoHeight) - 150 // center vertically


        // Set up playerLayer frame and other properties
        playerLayer?.frame = CGRect(x: xPos, y: yPos, width: videoWidth, height: videoHeight)
        playerLayer?.videoGravity = .resizeAspectFill
        
        SignsvideoContainerView = UIView(frame: view.bounds)
                if let playerLayer = playerLayer {
                    SignsvideoContainerView?.layer.addSublayer(playerLayer)
                }
                
                if let SignsvideoContainerView = SignsvideoContainerView {
                    view.addSubview(SignsvideoContainerView)
                    view.bringSubviewToFront(OutLetHangUp)
                }

//        // Observe when the video finishes playing
//        NotificationCenter.default.addObserver(self, selector: #selector(videoDidFinish), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)

        // Start playing the video
        player?.play()
        
    }


    @objc func videoDidFinish() {
            print("Video finished playing")
            SignsvideoContainerView?.isHidden = true
            // Remove the playerLayer from the view's layer hierarchy
            playerLayer?.removeFromSuperlayer()
            playerLayer = nil
            playerItem = nil
            player = nil

            // Stop observing the notification
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
        }
    

}

// MARK: - CameraSessionDelegate
extension ViewController {
    func didOutput(_ sampleBuffer: CMSampleBuffer) {
        if self.useCustomCapturer {
            if let cvpixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer){
                if let buffer = self.cameraFilter?.apply(cvpixelBuffer){
                    self.webRTCClient.captureCurrentFrame(sampleBuffer: buffer)
                }else{
                    print("no applied image")
                }
            }else{
                print("no pixelbuffer")
            }
            //            self.webRTCClient.captureCurrentFrame(sampleBuffer: buffer)
        }
    }
}

class ConnectingView: UIView {
    
    private var dotSize: CGFloat = 10.0
    private var dotSpacing: CGFloat = 8.0
    private var dotCount: Int = 3
    private var dotViews: [UIView] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDots()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupDots()
    }
    
    private func setupDots() {
        for i in 0..<dotCount {
            let dotView = UIView()
            dotView.backgroundColor = .gray
            dotView.layer.cornerRadius = dotSize / 2
            dotView.frame = CGRect(x: CGFloat(i) * (dotSize + dotSpacing), y: 0, width: dotSize, height: dotSize)
            dotViews.append(dotView)
            addSubview(dotView)
        }
        
    }
    
    func startAnimating() {
        print("DOTS ANIMATION STARTED")
        for (index, dotView) in dotViews.enumerated() {
            let delay = Double(index) * 0.3
            animateDot(dotView, delay: delay)
        }
    }
    
    private func animateDot(_ dotView: UIView, delay: Double) {
        let animation = CAKeyframeAnimation(keyPath: "position.y")
        animation.values = [dotView.center.y, dotView.center.y - 10, dotView.center.y]
        animation.keyTimes = [0, 0.5, 1]
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.duration = 0.6
        animation.beginTime = CACurrentMediaTime() + delay
        animation.repeatCount = .infinity
        dotView.layer.add(animation, forKey: "connectingAnimation")
    }
    
    func stopAnimating() {
        for dotView in dotViews {
            dotView.layer.removeAnimation(forKey: "connectingAnimation")
        }
    }
}


class SpeechRecognizer: NSObject, SFSpeechRecognizerDelegate {
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    // Property to hold a reference to ViewController
    weak var viewController: ViewController?
    weak var Group_chats: ChatScreenViewController?
    weak var Blind_NormalGroup: GroupCall_Blind_NormalViewController?
    
    var Msguserone = ""
    var MSgusertwo = ""
    var checkclass  = ""
    
    init(viewController: ViewController) {
        self.viewController = viewController
        super.init()
        speechRecognizer?.delegate = self
        checkclass = "videocall"
    }
    
    init(groupchat: ChatScreenViewController ) {
        self.Group_chats = groupchat
        super.init()
        speechRecognizer?.delegate = self
        checkclass = "groupchat"
    }
    init(blind_normalGroup: GroupCall_Blind_NormalViewController, friendfirst : String , friendsecond : String) {
        self.Blind_NormalGroup = blind_normalGroup
        super.init()
        Msguserone = friendfirst
        MSgusertwo = friendsecond
        speechRecognizer?.delegate = self
        checkclass = "blind_normal"
    }
    
    var webRTCClient = WebRTCClient()
   var  groupFriendId = ""
   var ShouldGroupChat = false
    var isSpeechOn = false
   let  userID = UserDefaults.standard.string(forKey: "userID")!
    
    
    
    func startRecognition() {
        print("Audio Recognition started")
        
        isSpeechOn = true
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            // Set the audio session category, mode, and options
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.duckOthers, .defaultToSpeaker])
            try audioSession.setMode(.measurement)
            
            // Attempt to use the built-in microphone, which includes the earphone microphone if connected
            if let availableInputs = audioSession.availableInputs {
                for input in availableInputs {
                    if input.portType == .builtInMic || input.portType == .headsetMic {
                        try audioSession.setPreferredInput(input)
                        break
                    }
                }
            }
            
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Audio session error: \(error.localizedDescription)")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            if let result = result {
                print("Transcription: \(result.bestTranscription.formattedString)")
                
                if self.ShouldGroupChat {
                    print("Group Chat Send.")
                    socketsClass.shared.Send_GroupChatMsg(friendId: self.groupFriendId, Message: result.bestTranscription.formattedString, from: self.userID)
                }
                
                if self.checkclass == "groupchat" {
                    self.Group_chats?.speechtoTextMsg(message: result.bestTranscription.formattedString)
                }
                
                else if self.checkclass == "blind_normal" {
                    self.Blind_NormalGroup?.speechtoText = result.bestTranscription.formattedString
                    var text = result.bestTranscription.formattedString
                    socketsClass.shared.Send_GroupChatMsgByDeaf(friendId: self.Msguserone , Message: text, from: self.userID )
                    socketsClass.shared.Send_GroupChatMsgByDeaf(friendId: self.MSgusertwo , Message: text, from: self.userID )
                }
                else {
                    self.viewController?.textmsg(msg: result.bestTranscription.formattedString)
                }
            }
            
            if error != nil || result?.isFinal == true {
                print("Restarting recognition")
                
                self.stopRecognition()
                if !self.isStopping {
                    print("within>>> voice check false")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        self.startRecognition() // Restart recognition after a short delay
                    }
                } else {
                    print("Making voice check false")
                    self.isStopping = false
                    return
                }
            }
        })
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            print("Starting engine for voice")
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error: \(error.localizedDescription)")
        }
    }

    
     var isStopping = false
        
    
    func stopRecognition() {
        
            isSpeechOn = false
            print("Stopping audio engine and recognition task")
            audioEngine.stop()
            
            if let inputNode = audioEngine.inputNode as? AVAudioInputNode {
                inputNode.removeTap(onBus: 0)
            }
            
            recognitionRequest?.endAudio()
            recognitionTask?.cancel()
            
            recognitionRequest = nil
            recognitionTask = nil
            
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
            } catch {
                print("Audio session deactivation error: \(error.localizedDescription)")
            }
        }
}
