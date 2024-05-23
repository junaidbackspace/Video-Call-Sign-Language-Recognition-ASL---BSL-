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
  
    
    
    var speechRecognizer: SpeechRecognizer?
    var isAutoLockEnabledBeforeCall: Bool = true

    let font_sizeDefault = UserDefaults.standard
    let caption_opacityDefault = UserDefaults.standard
   
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
    
   
   
    @IBOutlet weak var msgtextView: UITextView!

    @IBOutlet weak var OutLet_Mic_Mute: UIButton!
    @IBOutlet weak var OutLet_speaker_Mute: UIButton!
    @IBOutlet weak var OutLetHangUp: UIButton!
 
    @IBOutlet weak var OutLetSwitchCam: UIButton!
   
  

   
    
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
        speechRecognizer?.isStopping = true
        speechRecognizer?.stopRecognition()
        hangupButtonTapped()
        
    }
    
    var testmsg = "1"
//    @IBAction func btnFreshmsg(_ sender: Any) {
//        print("sendind Message")
////        let data = testmsg.data(using: String.Encoding.utf8)
////        print(testmsg)
//        testmsg = String(Int(testmsg)!+1)
//        webRTCClient.sendMessge(message: testmsg)
////        webRTCClient.sendData(data: data!)
////          testmsg = String(testmsg)
////                if let client = webRTCClient {
////                    client.sendMessge(message: testmsg)
////                } else {
////                    print("webRTCClient is not initialized")
////                }
//
//    }
    func textmsg(msg:String)
    {
     
       self.webRTCClient.sendMessge(message: msg)
        
    }
    
//    @IBAction func btnOldMsg(_ sender: Any) {
//    }
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
        DispatchQueue.main.async {
        print("updating check of voice recognizer")
            self.speechRecognizer?.isStopping = false
            self.speechRecognizer?.stopRecognition()
        
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
            
            //shifted in hangupcall
//            webRTCClient.delegate = nil // Remove delegate
//            webRTCClient.disconnect()
//            isReciever = 0
//            socket.delegate = nil
//            socket.disconnect()
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
  
        disabilitytype_check_msg = true
        let connectingView = ConnectingView(frame: CGRect(x: 0, y: 0, width: 100, height: 10))
                connectingView.center = view.center
        connectingView.startAnimating()
        self.view.addSubview(connectingView)
        
        disableAutoLock()
         userID = UserDefaults.standard.string(forKey: "userID")!
    
        
       
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleMessage(_:)), name: .didReceiveMessage, object: nil)
            
        
        NotificationCenter.default.addObserver(self, selector: #selector(endCall), name: Notification.Name("CallEndedNotification"), object: nil)
           
        
        
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
//        OutLetOldMsg.layer.zPosition = 1
//        OutLetFreshMsg.layer.zPosition = 1
//        lblmsg.layer.zPosition = 1
        msgtextView.layer.zPosition = 1
        OutLetSwitchCam.layer.zPosition = 1
        
       
        
      
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
        self.setupUI()
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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - UI
    private func setupUI(){
        
        
       
        
        let remoteVideoViewContainter = UIView(frame: CGRect(x: 0, y: 0, width: ScreenSizeUtil.width(), height: ScreenSizeUtil.height()))
        remoteVideoViewContainter.backgroundColor = .white
        self.view.addSubview(remoteVideoViewContainter)
        
        let remoteVideoView = webRTCClient.remoteVideoView()
        webRTCClient.setupRemoteViewFrame(frame: CGRect(x: 0, y: 0, width: ScreenSizeUtil.width(), height: ScreenSizeUtil.height()))
        remoteVideoView.center = remoteVideoViewContainter.center
        remoteVideoViewContainter.addSubview(remoteVideoView)
        
        let localVideoView = webRTCClient.localVideoView()
        webRTCClient.setupLocalViewFrame(frame: CGRect(x: 0, y: 0, width: ScreenSizeUtil.width()/3, height: ScreenSizeUtil.height()/4))
        localVideoView.center.y = self.view.center.y - 180
        localVideoView.center.x = self.view.center.x + 120
        localVideoView.subviews.last?.isUserInteractionEnabled = true
        self.view.addSubview(localVideoView)
       
        
        
        
        let localVideoViewButton = UIButton(frame: CGRect(x: 0, y: 0, width: ScreenSizeUtil.width()/3, height:  ScreenSizeUtil.height()/4))
        localVideoViewButton.backgroundColor = UIColor.clear
        localVideoViewButton.addTarget(self, action: #selector(self.localVideoViewTapped(_:)), for: .touchUpInside)
        localVideoView.addSubview(localVideoViewButton)
        
     
        remoteVideoViewContainter.addSubview(OutLet_Mic_Mute)
        remoteVideoViewContainter.addSubview(OutLet_speaker_Mute)
        remoteVideoViewContainter.addSubview(OutLetHangUp)
        remoteVideoViewContainter.addSubview(OutLetSwitchCam)

        remoteVideoViewContainter.addSubview(msgtextView)
       
        
        //Adding drag Gesture in local video view
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(dragview(_:)))
        localVideoView.addGestureRecognizer(panGesture)
        
    }
    var reciver = 0

    
    // MARK: - UI Events
    @objc func callButtonTapped(){
       
     
        if !webRTCClient.isConnected {
            
            print("initiating call ...")
           
               
            webRTCClient.connect(onSuccess: { (offerSDP: RTCSessionDescription) -> Void in
                self.sendSDP(sessionDescription: offerSDP)
            })
//            webRTCClient.startCaptureFrames()
            
        
        }
    }
    
    
  

    
    @objc func hangupButtonTapped(){
        print("hangup Tapped")
        speechRecognizer?.isStopping = true
        speechRecognizer?.stopRecognition()
        
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
                self.webRTCClient.delegate = nil // Remove delegate
                self.isReciever = 0
                
               
                self.disconnectWebRTC()
                
            }
        } catch {
            print("Error serializing end call data: \(error)")
        }
       
       
    }
    
    
   
    
        func disconnectWebRTC() {
            if webRTCClient.isConnected {
                webRTCClient.disconnect()
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                DispatchQueue.main.async {
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
        if data == testmsg.data(using: String.Encoding.utf8) {
            if let Message = String(data: data, encoding: .utf8) {
                
//            lblmsg.text = Message
            }
            print("String Message : \(data)")
        }
    }
    
   
    
    func didReceiveMessage(message: String) {
        print("viewController message recieved : \(message)")
        
        //speechReconizer start after recieving message
        if disabilitytype_check_msg{
        let myLangType = UserDefaults.standard.string(forKey: "disabilityType")!
            if   (message == "deaf" && myLangType != "deaf") || (message != "deaf" && myLangType == "deaf") {
            
                DispatchQueue.main.async {
                    print("++++++++Starting REcognition.....++++++")
                    self.speechRecognizer!.startRecognition()
                }
                
//            webRTCClient.localVideoTrack.isEnabled = false
            }
            //scroll view text
            self.configureScrollView(with: message)

            disabilitytype_check_msg = false
        }
        DispatchQueue.main.async {
        self.configureScrollView(with: message)
        }
    }
        
    
    
    func hunguptapedbyOtherCaller(){
        
        webRTCClient.disconnect()
        DispatchQueue.main.async {
                   self.navigationController?.popViewController(animated: true)
                   self.navigationController?.popViewController(animated: true)
               }
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
    
    init(viewController: ViewController) {
        self.viewController = viewController
        super.init()
        speechRecognizer?.delegate = self
    }
    
    func startRecognition() {
        print("Audio Recognition started")
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .default)
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
                
                // Use the reference to call ViewController's method
                self.viewController?.textmsg(msg: result.bestTranscription.formattedString)
                
            }
            
            if error != nil || result?.isFinal == true {
                print("Restarting recognition")
                
                self.stopRecognition()
                if !self.isStopping{
                    print("within>>> voice check false")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                   self.startRecognition() // Restart recognition after a short delay
                               }
                       }
                else{
                    
                    print("MAking voice check false")
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
            print("strating engine for voice()()()()")
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error: \(error.localizedDescription)")
        }
    }
    
     var isStopping = false
        
    
    func stopRecognition() {
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
