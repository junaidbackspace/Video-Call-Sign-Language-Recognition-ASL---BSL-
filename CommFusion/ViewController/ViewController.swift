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
    let font_sizeDefault = UserDefaults.standard
    let caption_opacityDefault = UserDefaults.standard
    
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
    
   
    @IBOutlet weak var OutLetCall: UIButton!
    @IBOutlet weak var OutLetHangUp: UIButton!
    @IBOutlet weak var OutLetFreshMsg: UIButton!
    @IBOutlet weak var OutLetSwitchCam: UIButton!
    @IBOutlet weak var OutLetOldMsg: UIButton!
    @IBOutlet weak var lblmsg: UILabel!
    @IBOutlet weak var msgview_with_Btns: UIView!
    
    @IBAction func btn_SwitchCamera(_ sender: Any) {
        webRTCClient.switchCameraPosition()
    }
    @IBAction func btnCall(_ sender: Any) {
        print("Entered in CallUp")
      
        callButtonTapped()
    }
    
    @IBAction func btnHangupCall(_ sender: Any) {
        print("Entered in hangup")
        hangupButtonTapped()
    }
    
    var testmsg = "1"
    @IBAction func btnFreshmsg(_ sender: Any) {
        print("sendind data")
        let data = testmsg.data(using: String.Encoding.utf8)
        print(testmsg)
        testmsg = String(Int(testmsg)!+1)
        webRTCClient.sendData(data: data!)
    }
    
    @IBAction func btnOldMsg(_ sender: Any) {
    }
    //MARK: - Properties
    var webRTCClient: WebRTCClient!
    let socketObj = socketsClass()
    var socket: WebSocket!
    
    var cameraSession: CameraSession?
    
    
    // You can create video source from CMSampleBuffer :)
    var useCustomCapturer: Bool = false
    var cameraFilter: CameraFilter?
    
    // Constants
    // MARK: Change this ip address in your case

  
    
    
  
    //MARK: - ViewController Override Methods ----------------------------
    
   let userID = UserDefaults.standard.string(forKey: "userID")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
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
       self.socket = WebSocket(url: URL(string: "ws://" + ipAddress + ":8080")!)
       socket.delegate = self

//      let  tryToConnectWebSocket = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (timer) in
//            if self.webRTCClient.isConnected || self.socket.isConnected {
//                return
//            }  })
        socket.connect()
     
        
//        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
//            socket = appDelegate.socketObj.socket
//                    
//                } else {
//                    print("Unable to access AppDelegate")
//                }
        
        // Do any additional setup after loading the view, typically from a nib.
        
        OutLetCall.layer.zPosition = 1
        OutLetHangUp .layer.zPosition = 1
        OutLetOldMsg.layer.zPosition = 1
        OutLetFreshMsg.layer.zPosition = 1
        lblmsg.layer.zPosition = 1
        msgview_with_Btns.layer.zPosition = 1
        OutLetSwitchCam.layer.zPosition = 1
       
        callButtonTapped()
      
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.setupUI()
        let size = font_sizeDefault.integer(forKey: "fontsize")
        
        let currentFontSize = lblmsg.font.pointSize
        lblmsg.font = lblmsg.font.withSize(currentFontSize+CGFloat(size))
        
        let currentHeight = msgview_with_Btns.frame.size.height
        print("Curren view hight : \(currentHeight)")
        msgview_with_Btns.frame.size.height = currentHeight + CGFloat(size)
        print("Curren view hight : \(msgview_with_Btns.frame.size.height)")
        
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
        remoteVideoViewContainter.backgroundColor = .gray
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
        
     
        remoteVideoViewContainter.addSubview(OutLetCall)
        remoteVideoViewContainter.addSubview(OutLetHangUp)
        remoteVideoViewContainter.addSubview(OutLetSwitchCam)

        remoteVideoViewContainter.addSubview(msgview_with_Btns)
        msgview_with_Btns.addSubview(OutLetFreshMsg)
        print("\n\nAll IS Setuped")
    }
    var reciver = 0
    
    // MARK: - UI Events
    @objc func callButtonTapped(){
        let recieverid = String(reciver)
        if !webRTCClient.isConnected {
            print("call Tapped")
            if isReciever == 1{
            webRTCClient.connect(onSuccess: { (offerSDP: RTCSessionDescription) -> Void in
                self.sendSDP(sessionDescription: offerSDP)
            })
//            webRTCClient.startCaptureFrames()
            }
        }
    }
    
    
    @objc func hangupButtonTapped(){
        if webRTCClient.isConnected {
            webRTCClient.disconnect()
           print("hangup Tapped")
            
//            let endCallData: [String: Any] = [
//                "type": "call_ended",
//                "callerID": callFriendId // Replace `callerID` with the actual caller ID
//            ]
//            do {
//                print(endCallData)
//                let jsonData = try JSONSerialization.data(withJSONObject: endCallData, options: [])
//                socket.write(data: jsonData)
//            } catch {
//                print("Error serializing end call data: \(error)")
//            }


            self.navigationController?.popViewController(animated: true)
            self.navigationController?.popViewController(animated: true)
         //   webRTCClient.stopCaptureFrames()
        }
        else{
        self.navigationController?.popViewController(animated: false)
        self.navigationController?.popViewController(animated: false)
        }
    }
    
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

    
    
    // MARK: - WebRTC Signaling
    private func sendSDP(sessionDescription: RTCSessionDescription){
        var type = ""
        if sessionDescription.type == .offer {
            type = "offer"
        }else if sessionDescription.type == .answer {
            type = "answer"
        }
        
        let sdp = SDP.init(sdp: sessionDescription.sdp)
        let signalingMessage = SignalingMessage.init(type: type, sessionDescription: sdp, candidate: nil)
        do {
            let data = try JSONEncoder().encode(signalingMessage)
            let message = String(data: data, encoding: String.Encoding.utf8)!
            
            if self.socket.isConnected {
                print("\nwriting \(type) on socket")
                self.socket.write(string: message)
            }
        }catch{
            print(error)
        }
    }
    
    private func sendCandidate(iceCandidate: RTCIceCandidate){
        let candidate = Candidate.init(sdp: iceCandidate.sdp, sdpMLineIndex: iceCandidate.sdpMLineIndex, sdpMid: iceCandidate.sdpMid!)
        let signalingMessage = SignalingMessage.init(type: "candidate", sessionDescription: nil, candidate: candidate)
        do {
            let data = try JSONEncoder().encode(signalingMessage)
            let message = String(data: data, encoding: String.Encoding.utf8)!
            
            if self.socket.isConnected {
                print("\nwriting candidate on socket")
                self.socket.write(string: message)
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
//        wsStatusLabel.text = wsStatusMessageBase + "connected"
//        wsStatusLabel.textColor = .green
        print("\nWebSocket Connected\n")
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
                print("call ended by user")
                hangupButtonTapped()    
            }
            
            if signalingMessage.type == "offer" {
                print("offer recieved")
                webRTCClient.receiveOffer(offerSDP: RTCSessionDescription(type: .offer, sdp: (signalingMessage.sessionDescription?.sdp)!), onCreateAnswer: {(answerSDP: RTCSessionDescription) -> Void in
                    self.sendSDP(sessionDescription: answerSDP)
                })
            }else if signalingMessage.type == "answer" {
                print("Answer recieved")
                webRTCClient.receiveAnswer(answerSDP: RTCSessionDescription(type: .answer, sdp: (signalingMessage.sessionDescription?.sdp)!))
            }else if signalingMessage.type == "candidate" {
                print("Candidate recieved")
                
                let candidate = signalingMessage.candidate!
                webRTCClient.receiveCandidate(candidate: RTCIceCandidate(sdp: candidate.sdp, sdpMLineIndex: candidate.sdpMLineIndex, sdpMid: candidate.sdpMid))
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
        self.socket.disconnect()
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
        }
    }
    
    func didReceiveMessage(message: String) {
        self.lblmsg.text = message
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
