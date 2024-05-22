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





class ViewController: UIViewController, WebSocketDelegate, WebRTCClientDelegate, CameraSessionDelegate {
  
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
    
   
    
    @IBOutlet weak var OutLet_Mic_Mute: UIButton!
    @IBOutlet weak var OutLet_speaker_Mute: UIButton!
    @IBOutlet weak var OutLetHangUp: UIButton!
    @IBOutlet weak var OutLetFreshMsg: UIButton!
    @IBOutlet weak var OutLetSwitchCam: UIButton!
    @IBOutlet weak var OutLetOldMsg: UIButton!
    @IBOutlet weak var lblmsg: UILabel!
    @IBOutlet weak var msgview_with_Btns: UIView!
   
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
        hangupButtonTapped()
    }
    
    var testmsg = "1"
    @IBAction func btnFreshmsg(_ sender: Any) {
        print("sendind Message")
//        let data = testmsg.data(using: String.Encoding.utf8)
//        print(testmsg)
//        testmsg = String(Int(testmsg)!+1)
//        webRTCClient.sendData(data: data!)
        
        testmsg = String(Int(testmsg)!+1)
        webRTCClient.sendMessge(message:   testmsg)
    }
    
    @IBAction func btnOldMsg(_ sender: Any) {
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
            print("\nNOW IN VIEWCONTROLLER TO END CALL")
        CallEnd_API(vid: self.v_id, userid: Int(self.userID)!)
            webRTCClient.disconnect()
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
                self.navigationController?.popViewController(animated: true)
            }
        }
        
        deinit {
            
           //Screen lock release
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
        
        let connectingView = ConnectingView(frame: CGRect(x: 0, y: 0, width: 100, height: 10))
                connectingView.center = view.center
                view.addSubview(connectingView)
        
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
     
        

        
        OutLet_Mic_Mute.layer.zPosition = 1
        OutLet_speaker_Mute.layer.zPosition = 1
        OutLetHangUp .layer.zPosition = 1
        OutLetOldMsg.layer.zPosition = 1
        OutLetFreshMsg.layer.zPosition = 1
        lblmsg.layer.zPosition = 1
        msgview_with_Btns.layer.zPosition = 1
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
        
        let currentFontSize = lblmsg.font.pointSize
        lblmsg.font = lblmsg.font.withSize(currentFontSize+CGFloat(size))
        
        let currentHeight = msgview_with_Btns.frame.size.height
       
        msgview_with_Btns.frame.size.height = currentHeight + CGFloat(size)
       
        
        if let color = UserDefaults.standard.color(forKey: "color") {
            
            lblmsg.textColor = color
        }
        
        let opacity = caption_opacityDefault.float(forKey: "caption")
        msgview_with_Btns.alpha = CGFloat(opacity)
        
        
        
        //for new device when defaults not set
        let color = UserDefaults.standard.color(forKey: "color")
        if color == nil{
            let opacity = caption_opacityDefault.float(forKey: "caption")
            msgview_with_Btns.alpha = CGFloat(1)
            
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

        remoteVideoViewContainter.addSubview(msgview_with_Btns)
        msgview_with_Btns.addSubview(OutLetFreshMsg)
        
        //Adding drag Gesture in local video view
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(dragview(_:)))
        localVideoView.addGestureRecognizer(panGesture)
        
    }
    var reciver = 0

    
    // MARK: - UI Events
    @objc func callButtonTapped(){
       
     
        if !webRTCClient.isConnected {
            
            print("Reciever side initiating call ...")
           
               
            webRTCClient.connect(onSuccess: { (offerSDP: RTCSessionDescription) -> Void in
                self.sendSDP(sessionDescription: offerSDP)
            })
//            webRTCClient.startCaptureFrames()
            
        
        }
    }
    
    
  

    
    @objc func hangupButtonTapped(){
        print("hangup Tapped")
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
            lblmsg.text = Message
            }
            print("String Message : \(data)")
        }
    }
    
    func didReceiveMessage(message: String) {
        print("viewController message recieved : \(message)")
        
        if message == "blind" {
            let LangType = UserDefaults.standard.string(forKey: "disability_Type")!
            if LangType == "blind"
            {
            webRTCClient.localVideoTrack.isEnabled = false
            }
        }
        else{
        self.lblmsg.text = message
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
        startAnimating()
    }
    
    private func startAnimating() {
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
}

