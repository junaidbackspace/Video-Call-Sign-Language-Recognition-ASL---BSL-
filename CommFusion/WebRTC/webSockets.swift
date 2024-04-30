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
    
    
      
    
    // Singleton instance
       static let shared = socketsClass()

       // Weak reference to the current active view controller
       weak var activeViewController: UIViewController?
       
       // Delegate to notify about incoming calls
       weak var incomingCallDelegate: IncomingCallDelegate?

    
var webRTCClient = WebRTCClient()
public var  socket : WebSocket!
var backgroundTask: UIBackgroundTaskIdentifier = .invalid
var ipAddress: String
var userID = ""

init() {
          // Initialize ipAddress here or wherever appropriate in your code
          self.ipAddress = Constants.nodeserverIP
         self.socket = WebSocket(url: URL(string: "ws://" + ipAddress + ":8080")!)
     self.userID = String(UserDefaults.standard.integer(forKey: "userID"))
    
}
    
    func getSocket() -> WebSocket? {
           return socket
       }
    
public func connectSocket(){
            if !socket.isConnected {
                //Because on first time userid not set
                self.userID = String(UserDefaults.standard.integer(forKey: "userID"))
                socket.delegate = self
                self.socket.connect()
                print("Connecting in background")
            }
            else{
            print(" connected in background")
            }
            Thread.sleep(forTimeInterval: 2) // Adjust interval as needed
        }
    

    


func websocketDidConnect(socket: WebSocketClient) {
    print("-- WebSocket did connect --")
    
    // Perform authentication
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

    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
       

//        let receivedMessage = text

        let jsonString = text

        // Remove curly braces and split by comma
        let components = jsonString
            .replacingOccurrences(of: "{", with: "")
            .replacingOccurrences(of: "}", with: "")
            .components(separatedBy: ",")

        // Iterate over key-value pairs
        var type: String?
        var from: String?

        
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
                default:
                    break
                }
            }
        }

        if type == "incoming_call"{
           
            print("incoming call From: \(from)")
            callerid = from!
            receiveIncomingCall()
           
        }
        if type == "ringing" {
            print("user \(from) is ringing ")
            NotificationCenter.default.post(name: Notification.Name("UpdateLabelNotification"), object: nil, userInfo: ["text": "Ringing..."])
              
        }
        if type == "call_accepted"{
           
            print("call acepted by user")
            NotificationCenter.default.post(name: NSNotification.Name("callacepted"), object: nil)

           
        }
        
        // Print variables
       
    }

var callerid = ""


func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
    print("Received data: \(data)")
}
    
    
    func initiateCall(with friendId: String) {
       
         self.connectSocket()
        
        // Send call initiation message
        let callData: [String: Any] = ["type": "call", "from": userID, "to": friendId]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: callData, options: [])
            socket.write(data: jsonData)
        } catch {
            print("Error serializing call initiation data: \(error)")
        }
    }



    func receiveIncomingCall() {
       
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            // Ensure that the delegate is set and the function is implemented
            guard let delegate = self.incomingCallDelegate else {
                print("Incoming call delegate not set")
                
                NotificationCenter.default.post(name: .openViewControllerNotification, object: nil,  userInfo: ["callerid": self.callerid])
                   
                return
            }
            
            
           
            }

        }
    

}
extension Notification.Name {
    static let openViewControllerNotification = Notification.Name("openViewControllerNotification")
}
