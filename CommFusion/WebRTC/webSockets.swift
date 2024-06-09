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

    var groupChat_AcceptId = " "
    var caller1 = " "
    var caller2 = " "
    var type: String?
    var from: String?
    var chatSenderID = ""
    var chatMsg : String?
    var vid  = 0
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
                case "user1":
                    caller1 = value
                case "user2":
                    caller2 = value
                case "vid":
                    vid = Int(value)!
                case "userid":
                    groupChat_AcceptId = value
                case "msg":
                    chatMsg = value
                case "chatsender":
                    chatSenderID = value
                case "chatuserid":
                    print("chat accepted : \(value)")
                    chatSenderID = value
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
                    vid = Int(videocallID)!
                    
                default:
                    break
                }
            }
        }
       

        if type == "incoming_call"{
            checkReciever = 1
            print("incoming call From: \(from)")
            callerid = from!
            
            receiveIncomingCall()
           
        }
        
        if type == "incoming_group_call"{
           
            print("incoming Group call From: \(caller1)&\(caller2)")
            callerid = caller1
            UserDefaults.standard.setValue("1", forKey: "groupchat")
            
            self.receiveGroupCall(firstuser_id: Int(caller1)!, SecondUser_id: Int(caller2)!, Vid: vid)
           
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
            
            print("\nwithin sockets call ended by user in viewcontroller")
            NotificationCenter.default.post(name: Notification.Name("CallEndedNotification"), object: nil)
            
            DispatchQueue.main.asyncAfter(deadline: .now()+0.2 ){
                print("Dispatch queue continued")
                
            let groupchatisEnabled = UserDefaults.standard.string(forKey: "groupchat")
            if groupchatisEnabled == "1"
            {
                print("\nAlso Closing group Chat : \(self.chatSenderID)")
                self.EndGroupChat(friendId: self.chatSenderID)
               
                UserDefaults.standard.setValue("0", forKey: "groupchat")
                
            }
            else{
                print("in else again saving 0 in groupcall check")
                UserDefaults.standard.setValue("0", forKey: "groupchat")
            }

            }
            
        }
        
        if type == "groupChat_ended"{
            
            print("Ending Group Chat")
            NotificationCenter.default.post(name: Notification.Name("groupChatEnd"), object: nil)
            UserDefaults.standard.setValue("0", forKey: "groupchat")
            
        }
        
        if type == "call_cancell"{

            print("within Reciver call cancelled by user")
            NotificationCenter.default.post(name: Notification.Name("CallCancelledFromCallerNotification"), object: nil)

                print("within Caller call cancelled by user")
                NotificationCenter.default.post(name: Notification.Name("CallCancelledFromReciverNotification"), object: nil)

        }
        
        if type == "group_chat_accept"{
            
            print("Group chat accepted friend id : \(chatSenderID)")
            
            UserDefaults.standard.setValue("1", forKey: "groupchat")
            UserDefaults.standard.setValue(chatSenderID, forKey: "groupchatmember")
            Group_Chat_Accepted()
           
        }
        
        if type == "msg"{
            
            print("Group Msg Recieved: \(chatMsg) , from : \(chatSenderID)")
            
           
                if let msg = chatMsg{
                    print("\n within sockets chatMessage Recieved: \(msg)")
            Recieve_ChatMessage(From: chatSenderID, Message: msg)
                }
            
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



    func Group_Chat_Accepted() {
       
        UserDefaults.standard.setValue("1", forKey: "groupchat")
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            // Ensure that the delegate is set and the function is implemented
           
                NotificationCenter.default.post(name: .grouchatAccepted, object: nil,  userInfo: ["callerid": self.groupChat_AcceptId])
                   
                return
           
           
            }

        }
    
    func EndGroupChat( friendId: String) {
        
        print("Also Notifying to end Group Call:\(friendId) , chat sender\(chatSenderID)")
        if !self.socket.isConnected{
        self.connectSocket()
        }
       
        let callData: [String: Any] = ["type": "groupchatend", "to": friendId]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: callData, options: [])
            socket.write(data: jsonData)
            videocallid = Int(videocallid)
            
            print("Sending end GroupChat Msg: \(callData)")
            
        } catch {
            print("Error serializing ChatEnd initiation data: \(error)")
        }
    }

    func receiveIncomingCall() {
       
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            // Ensure that the delegate is set and the function is implemented
            guard let delegate = self.incomingCallDelegate else {
               
                
                NotificationCenter.default.post(name: .openViewControllerNotification, object: nil,  userInfo: ["callerid": self.callerid])
                   
                return
            }
            
            
           
            }

        }
    
    func receiveGroupCall(firstuser_id : Int , SecondUser_id : Int , Vid : Int) {
       
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            // Ensure that the delegate is set and the function is implemented
            guard let delegate = self.incomingCallDelegate else {
                print("Incoming call delegate not set")
                
                let userInfo: [String: Any] = [
                               "firstuser": firstuser_id,
                               "seconduser": SecondUser_id,
                               "videocallid": Vid
                           ]
                
                NotificationCenter.default.post(name: .openGroupCallNotification, object: nil, userInfo: userInfo)
                          
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
    
    func GroupChatCall(with friendId: String ,caller1 : String , Caller2 : String ,  vid : Int) {
       
        self.connectSocket()
       userID = String(UserDefaults.standard.integer(forKey: "userID"))
        // Send call initiation message
        let callData: [String: Any] = ["type": "groupchat", "caller1": caller1, "caller2": Caller2 ,"newUser" : friendId, "videocallid" : vid]
        do {
            print("\n \(callData)")
            let jsonData = try JSONSerialization.data(withJSONObject: callData, options: [])
            socket.write(data: jsonData)
            print("Group call initiated...")
            UserDefaults.standard.setValue("1", forKey: "groupchat")
        } catch {
            print("Error serializing call canceling data: \(error)")
        }
    }
    
    func GroupCallAccepted( caller1: String , caller2 : String) {
       
        self.connectSocket()
       userID = String(UserDefaults.standard.integer(forKey: "userID"))
        // Send call initiation message
        let callData: [String: Any] = ["type": "group_call_accepted", "from": userID, "caller1": caller1,"caller2":caller2]
        do {
            print("\nAccepting group call : \(callData)")
            let jsonData = try JSONSerialization.data(withJSONObject: callData, options: [])
            socket.write(data: jsonData)
            
        } catch {
            print("Error serializing call canceling data: \(error)")
        }
    }
    
    func Send_GroupChatMsg(friendId: String ,Message : String , from : String ) {
       
        self.connectSocket()
       userID = String(UserDefaults.standard.integer(forKey: "userID"))
        var chatmember = UserDefaults.standard.string(forKey: "groupchatmember")
        // Send call initiation message
        let Data: [String: Any] = ["type": "groupMsg","from": userID,"to": chatmember, "msg": Message]
        do {
            print("\n \(Data)")
            let jsonData = try JSONSerialization.data(withJSONObject: Data, options: [])
            socket.write(data: jsonData)
            print("Group msg send...")
        } catch {
            print("Error serializing call canceling data: \(error)")
        }
    }
    
    func Send_GroupChatMsgByDeaf(friendId: String ,Message : String , from : String ) {
       
        self.connectSocket()
       
        
        // Send call initiation message
        let Data: [String: Any] = ["type": "groupMsg","from": from,"to": friendId, "msg": Message]
        do {
            print("\n \(Data)")
            let jsonData = try JSONSerialization.data(withJSONObject: Data, options: [])
            socket.write(data: jsonData)
            print("Group msg send by deaf...")
        } catch {
            print("Error serializing call canceling data: \(error)")
        }
    }
    
    
    func Recieve_ChatMessage(From : String  , Message : String) {
       
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            // Ensure that the delegate is set and the function is implemented
            guard let delegate = self.incomingCallDelegate else {
                print("Chat Message Recieve  delegate not set")
                
                let userInfo: [String: Any] = [
                               "from": From,
                               "message": Message
                           ]
                
                NotificationCenter.default.post(name: .chatMsg_Recieve, object: nil, userInfo: userInfo)
                          
                return
                        }
            
                    }
            }

}
extension Notification.Name {
    
    static let chatMsg_Recieve = Notification.Name("ChatMsg_Recieved")
    static let grouchatAccepted = Notification.Name("Noti_GroupChatAccepted")
    static let openViewControllerNotification = Notification.Name("openViewControllerNotification")
    
    static let openGroupCallNotification = Notification.Name("openGroupCallViewControllerNotification")
    
    static let didReceiveMessage = Notification.Name("didReceiveMessage")
    
    
}
