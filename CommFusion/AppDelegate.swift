
import UIKit
import WebRTC


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate{

    var window: UIWindow?

    var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    let socketObj = socketsClass()
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
//        Thread.sleep(forTimeInterval:2)
//        let window = UIWindow(frame: UIScreen.main.bounds)
//            self.window = window
//            
//        if UserDefaults.standard.integer(forKey: "userID") != 0{
//                // User is logged in, navigate to Dashboard
//                print("Navigating to Dashboard")
//                let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                let dashboardViewController = storyboard.instantiateViewController(withIdentifier: "dashboard")
//                let navigationController = UINavigationController(rootViewController: dashboardViewController)
//                window.rootViewController = navigationController
//            } else {
//                // User is not logged in, navigate to Login
//                print("Navigating to Login")
//                let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
//                let navigationController = UINavigationController(rootViewController: loginViewController)
//                window.rootViewController = navigationController
//            }
//            
//            window.makeKeyAndVisible()
        
        socketObj.connectSocket()

        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
        let online = onlineContactsViewController()
        print("termination app, turning offline status")
        online.getOnlineStatus(status: 0)
       
        backgroundTask = application.beginBackgroundTask {
            // End background task if time expires
            application.endBackgroundTask(self.backgroundTask)
            self.backgroundTask = .invalid
        }
        
        DispatchQueue.global().async {
            while true {
                if !self.socketObj.socket.isConnected {
                    self.socketObj.socket.connect()
                    print("Connecting in background")
                }
                else{
                print(" connected in background")
                    break
                }
                Thread.sleep(forTimeInterval: 2) // Adjust interval as needed
            }
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        application.endBackgroundTask(backgroundTask)
        backgroundTask = .invalid
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
