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

class sockets: WebSocketDelegate{
    
var webRTCClient = WebRTCClient()
var  socket : WebSocket!
var backgroundTask: UIBackgroundTaskIdentifier = .invalid
var ipAddress: String
var userID = ""

init() {
          // Initialize ipAddress here or wherever appropriate in your code
          self.ipAddress = Constants.nodeserverIP
         self.socket = WebSocket(url: URL(string: "ws://" + ipAddress + ":8080")!)
    self.userID = UserDefaults.standard.string(forKey: "userID")!
}
    

    
func connectSocket(){
            if !socket.isConnected {
                
                socket.delegate = self
                socket.connect()
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
    
    print("Received message: \(text)")
}

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




}
