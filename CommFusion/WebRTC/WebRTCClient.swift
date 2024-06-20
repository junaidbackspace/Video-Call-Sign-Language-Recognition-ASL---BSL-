//
//  WebRTCClient.swift
//  SimpleWebRTC
//
//  Created by n0 on 2019/01/06.
//  Copyright © 2019年 n0. All rights reserved.
//

import UIKit
import WebRTC
import Photos
import AVFoundation
import Speech
import Photos

protocol WebRTCClientDelegate {
    func didGenerateCandidate(iceCandidate: RTCIceCandidate)
    func didIceConnectionStateChanged(iceConnectionState: RTCIceConnectionState)
    func didOpenDataChannel()
    func didReceiveData(data: Data)
    func didReceiveMessage(message: String)
    func didConnectWebRTC()
    func didDisconnectWebRTC()
    func hunguptapedbyOtherCaller()
    func change_localview_Color(color : UIColor , Glowcolor : UIColor)
    func removeBorderAndGlow()
}



class WebRTCClient: NSObject, RTCPeerConnectionDelegate, RTCVideoViewDelegate, RTCDataChannelDelegate {
  
    var serverWrapper = APIWrapper()
    private var peerConnectionFactory: RTCPeerConnectionFactory!
    private var peerConnection: RTCPeerConnection?
    private var videoCapturer: RTCVideoCapturer!
    public var localVideoTrack: RTCVideoTrack!
    public var localAudioTrack: RTCAudioTrack!
    private var localRenderView: RTCEAGLVideoView?
    var captureSession: AVCaptureSession?
    private var localView: UIView!
    
    private var remoteRenderView: RTCEAGLVideoView?
    private var remoteView: UIView!
    private var remoteStream: RTCMediaStream?
    private var dataChannel: RTCDataChannel?
    private var remoteDataChannel: RTCDataChannel?
    private var channels: (video: Bool, audio: Bool, datachannel: Bool) = (false, false, false)
    private var customFrameCapturer: Bool = false
    private var cameraDevicePosition: AVCaptureDevice.Position = .front
    
    private var remoteAudioTrack: RTCAudioTrack?
    
    var delegate: WebRTCClientDelegate?
    public private(set) var isConnected: Bool = false
    
    
    




    
    func localVideoView() -> UIView {
        return localView
    }
    
    func remoteVideoView() -> UIView {
        return remoteView
    }
    
    var accessController: ViewController?
    override init() {
        super.init()
        
            self.localView = UIView()
            self.localView.isOpaque = true
         
            
        print("WebRTC Client initialize")
    }

    
    deinit {
        print("WebRTC Client Deinit")
        self.peerConnectionFactory = nil
        self.peerConnection = nil
        
    }
   
    
    //------------------- -------------capturing FRAMES
    
    var captureTimer: Timer?
    var frames: [UIImage] = [] // Array to store captured frames
    var captureDuration: TimeInterval = 3.0 // Duration to capture frames (in seconds)
    var waitDuration: TimeInterval = 4.0 // Duration to wait between captures (in seconds)
    var isCapturing = false
    public var ShouldGroupChat = false
    var groupFriendId = " "
    let userID = UserDefaults.standard.string(forKey: "userID")!
//    MARK:- static frames
    
    var Static_captureTimer: Timer?
    var stop_Staticframe_check = true
    var should_predictWord_check = false
    var shouldPredict_Custom_Signs = false
    var signtype = UserDefaults.standard.string(forKey: "SignType")
    
    
    func start_static_CaptureFrames() {
        print("Sign type : \(signtype)")
        
        if stop_Staticframe_check{
            Static_captureTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(Static_captureFrame), userInfo: nil, repeats: true)
        }
        }

        @objc func Static_captureFrame() {
            
            
            if stop_Staticframe_check{
            print("taking picture")
            delegate?.change_localview_Color(color: UIColor.green, Glowcolor: UIColor.cyan)
                DispatchQueue.main.asyncAfter(deadline: .now()+1.5)
            {
            let static_image =  self.localRenderView!.asImage()
                
                if self.shouldPredict_Custom_Signs{
                    print("Prediction custom signs now")
                    self.Predict_CustomSigns(image: static_image)
                    DispatchQueue.main.asyncAfter(deadline: .now()+2)
                    {
                        print("moving forward to take pic after 2 sec ")
                    }
                    
                }
                else
                    {
                        if self.signtype == "ASL"{
                    
                        if !self.should_predictWord_check{
                                self.predict_staticSign(image: static_image)
                                self.delegate?.removeBorderAndGlow()
                        }
                        else{
                            self.delegate?.removeBorderAndGlow()
                            //predict word now
                            print("\n}}}}}}}}NOW PREDICTING WORD\n")
                    
                            self.predict_WordsSign(image: static_image)
             
                            }
                        }
                
                        else{
                        print("Predicting BSL NOW")
                        self.predict_BSL_Sign(image: static_image)
                        }
                
                    }
            }
        }
    }
    func stopStaticCaptureFrames() {
        self.Static_captureTimer?.invalidate()
        self.Static_captureTimer = nil
    }
    
    
    // MARK:- Predicting words
   
    
    //    MARK:- creating video from frames
    
    var stop_dynamicframe = true
    func Permanent_stopCaptureFrames() {
        delegate?.removeBorderAndGlow()
        if let timer = self.captureTimer {
            timer.invalidate() // Invalidate the timer to stop it
            self.captureTimer = nil // Reset the timer property
            print("\n\n Permanent stop capturing frames\n")
           
        }
    }

    
    func stopCaptureFrames() {
        delegate?.removeBorderAndGlow()
        if let timer = self.captureTimer {
            timer.invalidate() // Invalidate the timer to stop it
            self.captureTimer = nil // Reset the timer property
            print("\n\nBackend thread stopped\n\n")
            createVideoFromFrames()
        }
    }
    
    

    func startCaptureFrames() {
        DispatchQueue.global().async {
            DispatchQueue.main.async {
                self.frames.removeAll() // Clear any previous frames
                self.isCapturing = true
                self.captureTimer = Timer.scheduledTimer(timeInterval: 1.0 / 30.0, target: self, selector: #selector(self.captureFrame), userInfo: nil, repeats: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + self.captureDuration) {
                    self.stopCaptureFrames()
                }
                self.delegate?.change_localview_Color(color: UIColor.yellow, Glowcolor: UIColor.orange)
                print("\n\nBackend thread started\n\n")
            }
        }
    }

    @objc func captureFrame() {
        if let image = self.localRenderView?.asImage() {
            frames.append(image) // Add the captured frame to the array
        }
    }
    
    func predict_staticSign(image : UIImage)
    {
        let apiUrl = URL(string: "\(Constants.serverURL)/asl-Updatedsigns/detect_hand")!
//        let apiUrl = URL(string: "\(Constants.serverURL)/asl-Updatedsigns/detect_hand")!
                     serverWrapper.predictAlphabet(baseUrl: apiUrl, image: image) { predictedLabel, error in
                         if let error = error {
                             print("Error: \(error.localizedDescription)")
                         } else if let predictedLabel = predictedLabel {
                             print("Predicted Label: \(predictedLabel)")
                             self.sendMessge(message: predictedLabel)
                            
                            if self.ShouldGroupChat{
                                socketsClass.shared.Send_GroupChatMsg(friendId: self.groupFriendId, Message: predictedLabel, from : self.userID)
                            }
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
                             self.sendMessge(message: predictedLabel)
                            
                            if self.ShouldGroupChat{
                                socketsClass.shared.Send_GroupChatMsg(friendId: self.groupFriendId, Message: predictedLabel, from : self.userID)
                            }
                         }
                     }
    }
    
    //prediction BSL
    func predict_BSL_Sign(image : UIImage)
    {

        let apiUrl = URL(string: "\(Constants.serverURL)/asl-Updatedsigns/predictBSL")!
        serverWrapper.predictBSL(baseUrl: apiUrl, image: image) { predictedLabel, error in
                         if let error = error {
                             print("Error: \(error.localizedDescription)")
                         } else if let predictedLabel = predictedLabel {
                             print("Predicted BSL : \(predictedLabel)")
                             self.sendMessge(message: predictedLabel)
                            
                            if self.ShouldGroupChat{
                                socketsClass.shared.Send_GroupChatMsg(friendId: self.groupFriendId, Message: predictedLabel, from : self.userID)
                            }
                         }
                     }
    }

   func Predict_CustomSigns(image: UIImage) {
    
    serverWrapper.CustomSigns_Predict(url: URL(string : "\(Constants.serverURL)/testing-CustomSigns/predict/")!, image: image, user: userID){
        result in
            switch result {
            case .success(let prediction):
                print("Prediction: \(prediction)")
                
                self.sendMessge(message: prediction)
               
               if self.ShouldGroupChat{
                   socketsClass.shared.Send_GroupChatMsg(friendId: self.groupFriendId, Message: prediction, from : self.userID)
               }
                
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    

    func createVideoFromFrames() {
        guard !frames.isEmpty else { return }

        let videoSize = frames[0].size
        let outputPath = NSTemporaryDirectory() + "output.mov"
        let outputURL = URL(fileURLWithPath: outputPath)

        do {
            try FileManager.default.removeItem(at: outputURL)
        } catch {
            // File doesn't exist or couldn't be removed
        }

        guard let videoWriter = try? AVAssetWriter(outputURL: outputURL, fileType: .mov) else {
            print("Error: Could not create video writer")
            return
        }

        let videoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: videoSize.width,
            AVVideoHeightKey: videoSize.height
        ]

        let writerInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        let sourceBufferAttributes: [String: Any] = [
            (kCVPixelBufferPixelFormatTypeKey as String): Int(kCVPixelFormatType_32ARGB),
            (kCVPixelBufferWidthKey as String): Float(videoSize.width),
            (kCVPixelBufferHeightKey as String): Float(videoSize.height)
        ]

        let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: writerInput, sourcePixelBufferAttributes: sourceBufferAttributes)
        videoWriter.add(writerInput)

        videoWriter.startWriting()
        videoWriter.startSession(atSourceTime: .zero)

        var frameCount: Int64 = 0
        let frameDuration = CMTime(value: 1, timescale: 30) // 30 frames per second

        for frame in frames {
            while !adaptor.assetWriterInput.isReadyForMoreMediaData {
                Thread.sleep(forTimeInterval: 0.1)
            }

            if let buffer = pixelBufferFromUIImage(image: frame) {
                let presentationTime = CMTimeMultiply(frameDuration, multiplier: Int32(frameCount))
                adaptor.append(buffer, withPresentationTime: presentationTime)
                frameCount += 1
            }
        }

        writerInput.markAsFinished()
        videoWriter.finishWriting {
            self.uploadVideoToServer(outputURL: outputURL)
        }
    }

    func uploadVideoToServer(outputURL: URL) {
        let serverUrl = URL(string: "\(Constants.serverURL)/asl-signs/predict_video/")!

        var request = URLRequest(url: serverUrl)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        let body = NSMutableData()

        let filename = outputURL.lastPathComponent
        let mimetype = "video/quicktime"

        // Add video file data to the raw http request data
        if let videoData = try? Data(contentsOf: outputURL) {
            body.appendString("--\(boundary)\r\n")
            body.appendString("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n")
            body.appendString("Content-Type: \(mimetype)\r\n\r\n")
            body.append(videoData)
            body.appendString("\r\n")
        }

        body.appendString("--\(boundary)--\r\n")
        request.httpBody = body as Data

        let session = URLSession.shared
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error uploading video: \(error.localizedDescription)")
                return
            }

            if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                print("Video uploaded successfully")

                if let data = data {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let word = json["word"] as? String {
                            DispatchQueue.main.async {
                                self.handleServerResponse(word: word)
                                DispatchQueue.main.asyncAfter(deadline: .now() + self.waitDuration) {
                                    //should start again
                                    if self.stop_dynamicframe {
                                        print("starting video capturing again ....")
                                    self.startCaptureFrames() // Start the next capture after the wait duration
                                    }
                                }
                            }
                        }
                    } catch {
                        print("Error parsing server response: \(error.localizedDescription)")
                    }
                }
            } else {
                print("Error uploading video: Server error")
            }
        }.resume()
    }

    
    func handleServerResponse(word: String) {
        print("Predicted Word: \(word)")
        sendMessge(message: word)
        if self.ShouldGroupChat{
            socketsClass.shared.Send_GroupChatMsg(friendId: groupFriendId, Message: word, from :userID )
        }
        // Use the predicted word in your app as needed
    }

    func pixelBufferFromUIImage(image: UIImage) -> CVPixelBuffer? {
        let cgImage = image.cgImage
        let options: [NSObject: AnyObject] = [
            kCVPixelBufferCGImageCompatibilityKey: true as AnyObject,
            kCVPixelBufferCGBitmapContextCompatibilityKey: true as AnyObject
        ]

        var pxbuffer: CVPixelBuffer?
        let width = Int(image.size.width)
        let height = Int(image.size.height)

        let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32ARGB, options as CFDictionary, &pxbuffer)
        guard status == kCVReturnSuccess, let pixelBuffer = pxbuffer else {
            return nil
        }

        CVPixelBufferLockBaseAddress(pixelBuffer, [])
        let pxdata = CVPixelBufferGetBaseAddress(pixelBuffer)

        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pxdata, width: width, height: height, bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

        context?.draw(cgImage!, in: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))
        CVPixelBufferUnlockBaseAddress(pixelBuffer, [])

        return pixelBuffer
    }



       
    

//    func saveImageToDevice(image: UIImage) {
//        PHPhotoLibrary.shared().performChanges({
//            if let imageData = image.jpegData(compressionQuality: 3.0) {
//                let creationRequest = PHAssetCreationRequest.forAsset()
//                creationRequest.addResource(with: .photo, data: imageData, options: nil)
//            }
//        }, completionHandler: { success, error in
//            if success {
//                print("Image saved successfully to the photo library.")
//            } else {
//                if let error = error {
//                    print("Error saving image: \(error.localizedDescription)")
//                } else {
//                    print("Unknown error saving image.")
//                }
//            }
//        })
//    }
  
    //-----------------FRAME CAPURTING-------------------------
    
    
  
    // MARK: - Public functions
    func setup(videoTrack: Bool, audioTrack: Bool, dataChannel: Bool, customFrameCapturer: Bool){
        print("set up")
        
      
       
        
        self.channels.video = videoTrack
        self.channels.audio = audioTrack
        self.channels.datachannel = dataChannel
        self.customFrameCapturer = customFrameCapturer
        
        var videoEncoderFactory = RTCDefaultVideoEncoderFactory()
        var videoDecoderFactory = RTCDefaultVideoDecoderFactory()
        
        if TARGET_OS_SIMULATOR != 0 {
            print("setup vp8 codec")
            videoEncoderFactory = RTCSimluatorVideoEncoderFactory()
            videoDecoderFactory = RTCSimulatorVideoDecoderFactory()
        }
        self.peerConnectionFactory = RTCPeerConnectionFactory(encoderFactory: videoEncoderFactory, decoderFactory: videoDecoderFactory)
        
        setupView()
        setupLocalTracks()
        
        if self.channels.video {
            startCaptureLocalVideo(cameraPositon: self.cameraDevicePosition, videoWidth: 640, videoHeight: 640*16/9, videoFps: 30)
            self.localVideoTrack?.add(self.localRenderView!)
        }
    
    }
    
    func setupLocalViewFrame(frame: CGRect){
       
        localView.frame = frame
        
        localRenderView?.frame = localView.frame
    }
    
    func setupRemoteViewFrame(frame: CGRect){
        
        remoteView.frame = frame
        remoteRenderView?.frame = remoteView.frame
    }
    
    func switchCameraPosition(){
        if let capturer = self.videoCapturer as? RTCCameraVideoCapturer {
            capturer.stopCapture {
                let position = (self.cameraDevicePosition == .front) ? AVCaptureDevice.Position.back : AVCaptureDevice.Position.front
                self.cameraDevicePosition = position
                self.startCaptureLocalVideo(cameraPositon: position, videoWidth: 640, videoHeight: 640*16/9, videoFps: 30)
                
                
            }
        }
    }
    
    // MARK:- Connect
    func connect(onSuccess: @escaping (RTCSessionDescription) -> Void){
        print("creating peer  view")
        self.peerConnection = setupPeerConnection()
        self.peerConnection!.delegate = self
        
        if self.channels.video {
            print("adding video in  peer")
            self.peerConnection!.add(localVideoTrack, streamIds: ["stream0"])
        }
        if self.channels.audio {
            print("adding Audio in  peer")
            self.peerConnection!.add(localAudioTrack, streamIds: ["stream0"])
        }
        if self.channels.datachannel {
            print("Setting data Channel")
            self.dataChannel = self.setupDataChannel()
            self.dataChannel?.delegate = self
        }
        
        
        makeOffer(onSuccess: onSuccess)
    }
    
    // MARK:- HangUp
    func disconnect(){
        if self.peerConnection != nil{
//            onDisConnected()
            self.peerConnection!.close()
//            DispatchQueue.main.async {
//                self.speechRecognizer.stopRecognition()
//            }

            
        }
        stopCaptureLocalVideo()
        print("\n------disconecting all thing-----\n")
        stopCaptureFrames()

    }
    
    

    
    // MARK: -Signaling Event
    func receiveOffer(offerSDP: RTCSessionDescription, onCreateAnswer: @escaping (RTCSessionDescription) -> Void){
        if(self.peerConnection == nil){
            print("offer received, create peerconnection")
            self.peerConnection = setupPeerConnection()
            self.peerConnection!.delegate = self
            if self.channels.video {
                self.peerConnection!.add(localVideoTrack, streamIds: ["stream-1"])
            }
            if self.channels.audio {
                self.peerConnection!.add(localAudioTrack, streamIds: ["stream-1"])
            }
            if self.channels.datachannel {
                self.dataChannel = self.setupDataChannel()
                self.dataChannel?.delegate = self
            }
            
        }
        
        print("set remote description")
        //changed to optional
        self.peerConnection!.setRemoteDescription(offerSDP) { (err) in
            if let error = err {
                print("failed to set remote offer SDP")
                print(error)
                return
            }
            
            print("succeed to set remote offer SDP")
            self.makeAnswer(onCreateAnswer: onCreateAnswer)
        }
    }
    
    func receiveAnswer(answerSDP: RTCSessionDescription){
        //change to optional
        self.peerConnection!.setRemoteDescription(answerSDP) { (err) in
            if let error = err {
                print("failed to set remote answer SDP")
                print(error)
                return
            }
        }
    }

    func receiveCandidate(candidate: RTCIceCandidate){
       
        if self.peerConnection == nil{
            self.connect(onSuccess: { (offerSDP: RTCSessionDescription) -> Void in
//                self.sendSDP(sessionDescription: offerSDP)
            })
        }
        self.peerConnection!.add(candidate)
    }
    


    // MARK:- DataChannel Event
    
    func sendMessge(message: String){
        if let _dataChannel = self.remoteDataChannel {
            if _dataChannel.readyState == .open {
                let buffer = RTCDataBuffer(data: message.data(using: String.Encoding.utf8)!, isBinary: false)
                _dataChannel.sendData(buffer)
            }else {
                print("data channel is not ready state")
            }
        }else{
            print("no data channel")
        }
    }
    
    func sendData(data: Data){
        if let _dataChannel = self.remoteDataChannel {
            if _dataChannel.readyState == .open {
                let buffer = RTCDataBuffer(data: data, isBinary: true)
                _dataChannel.sendData(buffer)
            }
        }
    }
    
    func captureCurrentFrame(sampleBuffer: CMSampleBuffer){
        if let capturer = self.videoCapturer as? RTCCustomFrameCapturer {
            capturer.capture(sampleBuffer)
        }
    }
    
    func captureCurrentFrame(sampleBuffer: CVPixelBuffer){
        if let capturer = self.videoCapturer as? RTCCustomFrameCapturer {
            capturer.capture(sampleBuffer)
        }
    }
    
    // MARK:- Private functions
    // MARK: - Setup
    private func setupPeerConnection() -> RTCPeerConnection{
        let rtcConf = RTCConfiguration()
        rtcConf.iceServers = [RTCIceServer(urlStrings: ["stun:stun.l.google.com:19302"])]
        let mediaConstraints = RTCMediaConstraints.init(mandatoryConstraints: nil, optionalConstraints: nil)
        let pc = self.peerConnectionFactory.peerConnection(with: rtcConf, constraints: mediaConstraints, delegate: nil)
        return pc
    }
    
    private func setupView(){
        // local
        localRenderView = RTCEAGLVideoView()
        localRenderView!.delegate = self
        localView = UIView()
        localView.addSubview(localRenderView!)
        
        // remote
        remoteRenderView = RTCEAGLVideoView()
        remoteRenderView?.delegate = self
        remoteView = UIView()
        remoteView.addSubview(remoteRenderView!)
    }
    
    //MARK: - Local Media
    private func setupLocalTracks(){
        if self.channels.video == true {
            self.localVideoTrack = createVideoTrack()
        }
        if self.channels.audio == true {
            self.localAudioTrack = createAudioTrack()
        }
    }
    
   
    private func createAudioTrack() -> RTCAudioTrack? {
        guard let userID = UserDefaults.standard.string(forKey: "userID") else {
            print("User ID not found")
            return nil
        }

        // Configure the audio session before creating the WebRTC audio track
//        configureAudioSession()

        // Create audio source with default constraints
        let audioSource = peerConnectionFactory.audioSource(with: RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil))
        let audioTrack = peerConnectionFactory.audioTrack(with: audioSource, trackId: "audio\(userID)")

        return audioTrack
    }

    private func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            
            // Deactivate the audio session first
            try audioSession.setActive(false)
            
            // Set the category, mode, and options for video chat
            try audioSession.setCategory(.playAndRecord, mode: .videoChat, options: [.defaultToSpeaker, .allowBluetooth, .allowBluetoothA2DP])
            try audioSession.setActive(true)
            
            // Check and set the preferred input to the built-in bottom microphone if available
            if let bottomMic = audioSession.availableInputs?.first(where: { $0.portType == .builtInMic }) {
                try audioSession.setPreferredInput(bottomMic)
            } else {
                print("Bottom microphone is not available. Using default audio input.")
            }
            
            // Force the audio output to the speaker
            try audioSession.overrideOutputAudioPort(.speaker)
            
            debugAudioRouting()
            
        } catch {
            print("Error setting up audio session: \(error.localizedDescription)")
        }
    }

    private func debugAudioRouting() {
        let audioSession = AVAudioSession.sharedInstance()
        var i = 0
        // Print the current audio route information
        let currentRoute = audioSession.currentRoute
        for output in currentRoute.outputs {
            print("\(i): Current audio output: \(output.portType.rawValue) - \(output.portName)")
            i += 1
        }
        let currentInputRoute = audioSession.currentRoute.inputs
        if let input = currentInputRoute.first {
            print("Current audio input: \(input.portType.rawValue) - \(input.portName)")
        } else {
            print("No audio input route detected")
        }
    }
    
    
    
    
    func toggleSpeakerMute(muted: Bool) {
       
        print("\n\n====> inside Speaker to mute")
        self.remoteAudioTrack?.isEnabled = !muted
        
        
        
    }
    func toggleMicMute(muted: Bool) {
       
            print("\n\n====> inside Mic to mute")
        self.localAudioTrack.isEnabled = !muted
        
        
    }


    // Function to set audio to loudspeaker
    private func setAudioToLoudSpeaker() {
        do {
            // Set the AVAudioSession output to the loudspeaker
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
        } catch {
            print("Error setting audio to loudspeaker: \(error.localizedDescription)")
        }
    }


    
    private func createVideoTrack() -> RTCVideoTrack {
        let videoSource = self.peerConnectionFactory.videoSource()
        
        if self.customFrameCapturer {
            self.videoCapturer = RTCCustomFrameCapturer(delegate: videoSource)
        }else if TARGET_OS_SIMULATOR != 0 {
            print("now runnnig on simulator...")
            self.videoCapturer = RTCFileVideoCapturer(delegate: videoSource)
        }
        else {
            self.videoCapturer = RTCCameraVideoCapturer(delegate: videoSource)
        }
        let videoTrack = self.peerConnectionFactory.videoTrack(with: videoSource, trackId: "video0")
        return videoTrack
    }
    
    private func stopCaptureLocalVideo() {
        if let capturer = self.videoCapturer as? RTCCameraVideoCapturer {
            capturer.stopCapture()
            self.localAudioTrack?.isEnabled = false
            self.stop_Staticframe_check = false
            self.stop_dynamicframe = false
            print("\t,,,,,Stoping capturer")
        } else if let capturer = self.videoCapturer as? RTCFileVideoCapturer {
            print("\t,,,,,failedStoping capturer")
            capturer.stopCapture()
            self.localAudioTrack?.isEnabled = false
//            localVideoTrack?.isEnabled = false
            
        }
    }



    
    private func startCaptureLocalVideo(cameraPositon: AVCaptureDevice.Position, videoWidth: Int, videoHeight: Int?, videoFps: Int) {
        
        
        if let capturer = self.videoCapturer as? RTCCameraVideoCapturer {
            var targetDevice: AVCaptureDevice?
            var targetFormat: AVCaptureDevice.Format?
            
            // find target device
            let devicies = RTCCameraVideoCapturer.captureDevices()
            devicies.forEach { (device) in
                if device.position ==  cameraPositon{
                    targetDevice = device
                    
                }
            }
            
            // find target format
            let formats = RTCCameraVideoCapturer.supportedFormats(for: targetDevice!)
            formats.forEach { (format) in
                for _ in format.videoSupportedFrameRateRanges {
                    let description = format.formatDescription as CMFormatDescription
                    let dimensions = CMVideoFormatDescriptionGetDimensions(description)
                    
                    if dimensions.width == videoWidth && dimensions.height == videoHeight ?? 0{
                        targetFormat = format
                    } else if dimensions.width == videoWidth {
                        targetFormat = format
                    }
                }
            }
            
            capturer.startCapture(with: targetDevice!,
                                  format: targetFormat!,
                                  fps: videoFps)
        }
        else if let capturer = self.videoCapturer as? RTCFileVideoCapturer{
            print("setup file video capturer")
            if let _ = Bundle.main.path( forResource: "sample.mp4", ofType: nil ) {
                capturer.startCapturing(fromFileNamed: "sample.mp4") { (err) in
                    print(err)
                }
            }else{
                print("file did not faund")
            }
        }
    }
    
    // MARK: - Local Data
    private func setupDataChannel() -> RTCDataChannel{
        let dataChannelConfig = RTCDataChannelConfiguration()
        dataChannelConfig.channelId = 0
        
        let _dataChannel = self.peerConnection?.dataChannel(forLabel: "dataChannel", configuration: dataChannelConfig)
        return _dataChannel!
    }
    
    // MARK: - Signaling Offer/Answer
    private func makeOffer(onSuccess: @escaping (RTCSessionDescription) -> Void) {
        self.peerConnection?.offer(for: RTCMediaConstraints.init(mandatoryConstraints: nil, optionalConstraints: nil)) { (sdp, err) in
            if let error = err {
                print("error with make offer")
                print(error)
                return
            }
            
            if let offerSDP = sdp {
                print("make offer, created local sdp")
                self.peerConnection!.setLocalDescription(offerSDP, completionHandler: { (err) in
                    if let error = err {
                        print("error with set local offer sdp")
                        print(error)
                        return
                    }
                    
                    // ICE gathering is complete, send all candidates
                   
                    print("succeed to set local offer SDP")
                    onSuccess(offerSDP)
                })
            }
            
        }
    }
    
    private func makeAnswer(onCreateAnswer: @escaping (RTCSessionDescription) -> Void){
        self.peerConnection!.answer(for: RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil), completionHandler: { (answerSessionDescription, err) in
            if let error = err {
                print("failed to create local answer SDP")
                print(error)
                return
            }
            
            print("succeed to create local answer SDP")
            if let answerSDP = answerSessionDescription{
                self.peerConnection!.setLocalDescription( answerSDP, completionHandler: { (err) in
                    if let error = err {
                        print("failed to set local ansewr SDP")
                        print(error)
                        return
                    }
                    
                    print("succeed to set local answer SDP")
                    onCreateAnswer(answerSDP)
                })
            }
        })
    }
    
    // MARK: - Connection Events
    private func onConnected() {
        self.isConnected = true
        print("\n OnConnected  :- webRTC connected here\n")

        DispatchQueue.main.async {
            self.remoteRenderView?.isHidden = false
            self.delegate?.didConnectWebRTC()
        }
    }

    
     func onDisConnected(){
        self.isConnected = false
        
        DispatchQueue.main.async {
            print("--- on dis connected ---")
            if let peerConnection = self.peerConnection {
                self.peerConnection?.close()
//                self.peerConnection = nil
            } else {
                // Handle the case when peerConnection is nil
                print("peerConnection is nil")
            }
           
            self.remoteRenderView?.isHidden = true
            self.dataChannel = nil
            self.delegate?.didDisconnectWebRTC()
        }
    }
}

// MARK: - PeerConnection Delegeates
extension WebRTCClient {
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        var state = ""
        switch stateChanged {
        case .stable:
            state = "Stable"
        case .haveLocalOffer:
            state = "Have Local Offer"
        case .haveRemoteOffer:
            state = "Have Remote Offer"
        case .haveLocalPrAnswer:
            state = "Have Local PrAnswer"
        case .haveRemotePrAnswer:
            state = "Have Remote PrAnswer"
        case .closed:
            state = "Closed"
        @unknown default:
            state = "Unknown"
        }
        print("Signaling state changed: \(state)")
    }

    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        
        switch newState {
        case .connected, .completed:
            if !self.isConnected {
                print("\nPeer Connection :- webRTC connected here\n")
                self.onConnected()
            }
        default:
            if self.isConnected{
                self.onDisConnected()
            }
        }
        
        DispatchQueue.main.async {
            self.delegate?.didIceConnectionStateChanged(iceConnectionState: newState)
        }
    }
    
    //receiving audio and video
    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        print("did add stream")
        self.remoteStream = stream
        
        if let track = stream.videoTracks.first {
            print("video track found")
            track.add(remoteRenderView!)
        }
        
        if let audioTrack = stream.audioTracks.first{
            print("audio track found")
            audioTrack.source.volume = 1
            remoteAudioTrack = audioTrack
//            configureAudioSessionForLoudSpeaker()
            
            DispatchQueue.main.async {
                print("}}}}}}}stoping dots animation now...")
                let connecting_animation = ConnectingView()
                connecting_animation.stopAnimating()
            }
           
        }
    
        
        
    }
    
     func configureAudioSessionForLoudSpeaker() {
            do {
                print("\n\nNow Setting Remote Audio to Loud Speaker")
                let audioSession = AVAudioSession.sharedInstance()
                
                // Ensure the audio session is active
                try audioSession.setActive(true)
                
                // Force the audio output to the speaker
                try audioSession.overrideOutputAudioPort(.speaker)
                
                debugAudioRouting()
                
            } catch {
                print("Error setting audio session to loudspeaker: \(error.localizedDescription)")
            }
        }
    
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        self.delegate?.didGenerateCandidate(iceCandidate: candidate)
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
        print("--- did remove stream ---")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
        self.remoteDataChannel = dataChannel
        self.delegate?.didOpenDataChannel()
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {}
    
    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {}
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {}
}

// MARK: - RTCVideoView Delegate
extension WebRTCClient{
    func videoView(_ videoView: RTCVideoRenderer, didChangeVideoSize size: CGSize) {
        let isLandScape = size.width < size.height
        var renderView: RTCEAGLVideoView?
        var parentView: UIView?
        if videoView.isEqual(localRenderView){
            print("local video size changed")
            renderView = localRenderView
            parentView = localView
        }
        
        if videoView.isEqual(remoteRenderView!){
            //Setting to loud speaker after call connected
           
            
            print("remote video size changed to: ", size)
            renderView = remoteRenderView
            parentView = remoteView
            
//             sending disable user type
            let LangType = UserDefaults.standard.string(forKey: "disabilityType")!
            print("<<<>>>>Sending disability type : \(LangType)")
            self.sendMessge(message:  LangType)
        }
        
        guard let _renderView = renderView, let _parentView = parentView else {
            return
        }
        
        if(isLandScape){
            let ratio = size.width / size.height
            _renderView.frame = CGRect(x: 0, y: 0, width: _parentView.frame.height * ratio, height: _parentView.frame.height)
            
            
            
            if self.cameraDevicePosition == .front {
            _parentView.horizontallyMirror()
            }
            else{
             print("back camera called ")
            }
            
            
            _renderView.center.x = _parentView.frame.width/2
        }else{
            let ratio = size.height / size.width
            _renderView.frame = CGRect(x: 0, y: 0, width: _parentView.frame.width, height: _parentView.frame.width * ratio)
            
            //My------------Camera Mirror changing----------------

            _renderView.center.y = _parentView.frame.height/2
        }
    }
}

// MARK: - RTCDataChannelDelegate
extension WebRTCClient {
    func dataChannel(_ dataChannel: RTCDataChannel, didReceiveMessageWith buffer: RTCDataBuffer) {
        DispatchQueue.main.async {
            if buffer.isBinary {
                self.delegate?.didReceiveData(data: buffer.data)
            }else {
                self.delegate?.didReceiveMessage(message: String(data: buffer.data, encoding: String.Encoding.utf8)!)
            }
        }
    }
    
    func dataChannelDidChangeState(_ dataChannel: RTCDataChannel) {
        print("data channel did change state")
        switch dataChannel.readyState {
        case .closed:
            print("closed")
        case .closing:
            print("closing")
            self.delegate?.hunguptapedbyOtherCaller()
        case .connecting:
            print("connecting")
        case .open:
            print("open")
        }
    }
}
// ADded by me *********
extension UIView {
    func captureImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0.0)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        self.layer.render(in: context)
        let capturedImage = UIGraphicsGetImageFromCurrentImageContext()
        return capturedImage
    }
    
    func captureVideoFrame() -> UIImage? {
           guard let videoLayer = layer.sublayers?.first as? AVPlayerLayer,
                 let player = videoLayer.player,
                 let asset = player.currentItem?.asset,
                 player.timeControlStatus == .playing,
                 asset.isPlayable else {
               print("Video layer, player, or asset not available or not playing")
               return nil
           }

           let currentTime = player.currentTime()
           let imageGenerator = AVAssetImageGenerator(asset: asset)
           imageGenerator.appliesPreferredTrackTransform = true

           do {
               let cgImage = try imageGenerator.copyCGImage(at: currentTime, actualTime: nil)
               let image = UIImage(cgImage: cgImage)
               return image
           } catch let error {
               print("Error capturing frame: \(error)")
               return nil
           }
       }
    
}
extension UIView {
    func horizontallyMirror() {
        transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
    }
    func verticallyMirror() {
        transform = CGAffineTransform(scaleX: 1.0, y: -1.0)
    }
}
extension UIView {
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: self.bounds.size)
        let image = renderer.image { ctx in
            self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        }
        return image
    }

}

extension NSMutableData {
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        append(data)
    }
}


