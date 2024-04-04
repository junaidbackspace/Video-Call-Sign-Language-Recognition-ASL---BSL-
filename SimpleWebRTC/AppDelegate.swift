
import UIKit
import WebRTC
import Starscream

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WebSocketDelegate {

    var window: UIWindow?
    var webRTCClient: WebRTCClient!
    var socket: WebSocket!
    var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    let ipAddress: String = "192.168.31.105"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        webRTCClient = WebRTCClient()
        socket = WebSocket(url: URL(string: "ws://" + ipAddress + ":8080/")!)
        socket.delegate = self
        socket.connect()
        var online = onlineContactsViewController()
        print("termination app, turning offline status")
        online.getOnlineStatus(status: 0)
        

        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
       
        backgroundTask = application.beginBackgroundTask {
            // End background task if time expires
            application.endBackgroundTask(self.backgroundTask)
            self.backgroundTask = .invalid
        }
        
        DispatchQueue.global().async {
            while true {
                if !self.socket.isConnected {
                    self.socket.connect()
                    print("Connected in background")
                }
                print("trying to connect in background")
                Thread.sleep(forTimeInterval: 2) // Adjust interval as needed
            }
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        application.endBackgroundTask(backgroundTask)
        backgroundTask = .invalid
    }

    func websocketDidConnect(socket: WebSocketClient) {
        print("-- WebSocket did connect --")
    }

    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("-- WebSocket did disconnect --")
        if let error = error {
            print("Error: \(error)")
        }
    }

    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        // Handle received message
    }

    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        // Handle received data
    }
    
    
}





//
//import UIKit
//import WebRTC
//import Starscream
//
//@UIApplicationMain
//class AppDelegate: UIResponder, UIApplicationDelegate, WebSocketDelegate {
//
//    var window: UIWindow?
//    var webRTCClient: WebRTCClient!
//    var socket: WebSocket!
//    var backgroundTask: UIBackgroundTaskIdentifier = .invalid
//    let ipAddress: String = "192.168.31.105"
//
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        // Override point for customization after application launch.
//        webRTCClient = WebRTCClient()
//        socket = WebSocket(url: URL(string: "ws://" + ipAddress + ":8080/")!)
//        socket.delegate = self
//        socket.connect()
//
//        return true
//    }
//
//    func applicationDidEnterBackground(_ application: UIApplication) {
//        backgroundTask = application.beginBackgroundTask {
//            // End background task if time expires
//            application.endBackgroundTask(self.backgroundTask)
//            self.backgroundTask = .invalid
//        }
//        self.socket.disconnect()
//        DispatchQueue.global().async {
//            while true {
//                if !self.socket.isConnected {
//                    self.socket.connect()
//                    print("Connected in background")
//                }
//                print("trying to connect in background")
//                Thread.sleep(forTimeInterval: 2) // Adjust interval as needed
//            }
//        }
//    }
//
//    func applicationWillEnterForeground(_ application: UIApplication) {
//        application.endBackgroundTask(backgroundTask)
//        backgroundTask = .invalid
//    }
//
//    func websocketDidConnect(socket: WebSocketClient) {
//        print("-- WebSocket did connect --")
//    }
//
//    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
//        print("-- WebSocket did disconnect --")
//        if let error = error {
//            print("Error: \(error)")
//        }
//    }
//
//    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
//        // Handle received message
//    }
//
//    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
//        // Handle received data
//    }
//}
