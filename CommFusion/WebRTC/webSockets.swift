//
//  webSockets.swift
//  SimpleWebRTC
//
//  Created by Umer Farooq on 22/04/2024.
//  Copyright © 2024 n0. All rights reserved.
//
import WebRTC
import Starscream
import Foundation


protocol IncomingCallDelegate: AnyObject {
    func presentIncomingCallScreen(isRecieving : Bool)
   
}


class socketsClass: WebSocketDelegate{
    
    
    func hunguptapedbyOtherCaller() {
        
    }
    
    //callbacks
      var endCallClosure: (() -> Void)?
   
    // Singleton instance
       static let shared = socketsClass()

       // Weak reference to the current active view controller
       weak var activeViewController: UIViewController?
       
       // Delegate to notify about incoming calls
       weak var incomingCallDelegate: IncomingCallDelegate?

        
        

public var  socket : WebSocket!
var backgroundTask: UIBackgroundTaskIdentifier = .invalid
var ipAddress: String
var userID = ""

   
    
init() {
          // Initialize ipAddress here or wherever appropriate in your code
          self.ipAddress = Constants.nodeserverIP
         self.socket = WebSocket(url: URL(string: "ws://" + ipAddress + ":8081")!)
     self.userID = String(UserDefaults.standard.integer(forKey: "userID"))
 
    
    
}
    
    func getSocket() -> WebSocket? {
           return socket
       }
    
    
    func isConnected() -> Bool {
            return socket.isConnected
        }
    
public func connectSocket(){
    
    if self.socket == nil {
        
        
        self.ipAddress = Constants.nodeserverIP
        self.socket = WebSocket(url: URL(string: "ws://" + ipAddress + ":8081")!)
        self.userID = String(UserDefaults.standard.integer(forKey: "userID"))
        socket.delegate = self
        self.socket.connect()
    }
    if !self.socket.isConnected {
                //Because on first time userid not set
                self.userID = String(UserDefaults.standard.integer(forKey: "userID"))
                socket.delegate = self
                self.socket.connect()
                print("Connecting in webSocket")
            }
            else{
            print(" already connected in websockets")
            }
            Thread.sleep(forTimeInterval: 2) // Adjust interval as needed
        }
    
    func disconnect() {
        if self.socket.isConnected {
                print("Disconnecting sockets")
                self.socket.disconnect()
                self.socket = nil
            }
        }
    


func websocketDidConnect(socket: WebSocketClient) {
    print("-- WebSocket did connect --")
    
    // Perform authentication
    
    userID = String(UserDefaults.standard.integer(forKey: "userID"))
            let authData: [String: Any] = ["userId": userID]
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: authData, options: [])
                socket.write(data: jsonData)
            } catch {
                print("Error serializing authentication data: \(error)")
            }
}

func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
    print("-- WebSocket did disconnect --")
    if let error = error {
        print("Error: \(error)")
    }
}

    var type: String?
    var from: String?
    var vid : Int?
    var checkReciever = 0
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
       

//        let receivedMessage = text

        let jsonString = text

        // Remove curly braces and split by comma
        let components = jsonString
            .replacingOccurrences(of: "{", with: "")
            .replacingOccurrences(of: "}", with: "")
            .components(separatedBy: ",")

        // Iterate over key-value pairs
        
        
        for component in components {
            // Split each component by colon
            let keyValue = component.components(separatedBy: ":")
            if keyValue.count == 2 {
               
                // Remove surrounding quotes and whitespace
                let key = keyValue[0].trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\"", with: "")
                let value = keyValue[1].trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\"", with: "")
                
                // Store key-value pair in variables
                switch key {
                case "type":
                    type = value
                case "from":
                    from = value
                case "to":
                    from = value
                case "sessionDescription":
                    from = value
                default:
                    break
                }
            }
            else {
               
                // Remove surrounding quotes and whitespace
                let key = keyValue[0].trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\"", with: "")
                let value = keyValue[1].trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\"", with: "")
                let videocallID = keyValue[2].trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\"", with: "")
                
                // Store key-value pair in variables
                switch key {
                case "type":
                    type = value
                case "from":
                    from = value
                case "to":
                    from = value
                case "sessionDescription":
                    from = value
                case "vid":
                    vid = Int(videocallID)
                    UserDefaults.standard.setValue(vid, forKey: "vid")
                default:
                    break
                }
            }
        }
        print("\n Json String : \(jsonString)")

        if type == "incoming_call"{
            checkReciever = 1
            print("incoming call From: \(from)")
            callerid = from!
            
            receiveIncomingCall()
           
        }
        if type == "ringing" {
            print("user \(from) is ringing ")
            NotificationCenter.default.post(name: Notification.Name("UpdateLabelNotification"), object: nil, userInfo: ["text": "Ringing..."])
              
        }
        if type == "busy" {
            print("user \(from) is busy")
            NotificationCenter.default.post(name: Notification.Name("UpdateLabelNotification"), object: nil, userInfo: ["text": "Busy in other call..."])
              
        }
        if type == "call_accepted"{
           
            print("call acepted by user")
            NotificationCenter.default.post(name: NSNotification.Name("callacepted"), object: nil)

           
        }
        if type == "call_ended"{
            print("within sockets call ended by user in viewcontroller")
            NotificationCenter.default.post(name: Notification.Name("CallEndedNotification"), object: nil)


        }
        if type == "call_cancell"{

            print("within Reciver call cancelled by user")
            NotificationCenter.default.post(name: Notification.Name("CallCancelledFromCallerNotification"), object: nil)

                print("within Caller call cancelled by user")
                NotificationCenter.default.post(name: Notification.Name("CallCancelledFromReciverNotification"), object: nil)

        }
        
        else{

            
            do{
                let signalingMessage = try JSONDecoder().decode(SignalingMessage.self, from: jsonString.data(using: .utf8)!)
                if signalingMessage.type == "call_ended"{
                    print("call ended by user in viewcontroller")
                    self.hunguptapedbyOtherCaller()
                }
                
                else if signalingMessage.type == "offer" {
                    var controller = ViewController()
                   
                    let messageTuple: (WebSocketClient, String) = (socket, text)
                    NotificationCenter.default.post(name: .didReceiveMessage, object: nil, userInfo: ["messageTuple": messageTuple])
                        
                  
                }
                else if signalingMessage.type == "answer" {
                   
                    let messageTuple: (WebSocketClient, String) = (socket, text)
                    NotificationCenter.default.post(name: .didReceiveMessage, object: nil, userInfo: ["messageTuple": messageTuple])
                        
                    
                }else if signalingMessage.type == "candidate" {
                    print("Candidate recieved")
                    
                    let messageTuple: (WebSocketClient, String) = (socket, text)
                    NotificationCenter.default.post(name: .didReceiveMessage, object: nil, userInfo: ["messageTuple": messageTuple])
                        
                }
                else{
                    print("something revieved:\n\(signalingMessage)")
                }
            }catch{
                print(error)
            }
            }
        
        
        // Print variables
       
    }

    
        
var callerid = ""
var videocallid = 0

func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
    print("Received data: \(data)")
}
    
    
    func initiateCall(with friendId: String , videocall_id : Int) {
        if !self.socket.isConnected{
        self.connectSocket()
        }
       userID = String(UserDefaults.standard.integer(forKey: "userID"))
        // Send call initiation message
        let callData: [String: Any] = ["type": "call", "from": userID, "to": friendId , "videocallid": String(videocall_id)]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: callData, options: [])
            socket.write(data: jsonData)
            videocallid = Int(videocallid)
            print("local side initiating call: \(callData)")
            
        } catch {
            print("Error serializing call initiation data: \(error)")
        }
    }



    func receiveIncomingCall() {
       
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            // Ensure that the delegate is set and the function is implemented
            guard let delegate = self.incomingCallDelegate else {
                print("Incoming call delegate not set")
                
                NotificationCenter.default.post(name: .openViewControllerNotification, object: nil,  userInfo: ["callerid": self.callerid])
                   
                return
            }
            
            
           
            }

        }
    func CancellCall(with friendId: String) {
       
        self.connectSocket()
       userID = String(UserDefaults.standard.integer(forKey: "userID"))
        // Send call initiation message
        let callData: [String: Any] = ["type": "cancellcall", "from": userID, "to": friendId]
        do {
            print("\n \(callData)")
            let jsonData = try JSONSerialization.data(withJSONObject: callData, options: [])
            socket.write(data: jsonData)
            print("canceling call...")
        } catch {
            print("Error serializing call canceling data: \(error)")
        }
    }
    

}
extension Notification.Name {
    static let openViewControllerNotification = Notification.Name("openViewControllerNotification")
    static let didReceiveMessage = Notification.Name("didReceiveMessage")
    
}
