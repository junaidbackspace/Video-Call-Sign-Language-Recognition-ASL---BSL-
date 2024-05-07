//
//  CallObserverViewController.swift
//  CommFusion
//
//  Created by Umer Farooq on 07/05/2024.
//  Copyright © 2024 n0. All rights reserved.
//

import UIKit

class CallObserverViewController: UITabBarController, IncomingCallDelegate {
    func presentIncomingCallScreen(isRecieving: Bool) {
        print("\nrecieveing \(isRecieving)")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(openViewController(_:)), name: .openViewControllerNotification, object: nil)
         
        let sharedSockets = socketsClass.shared
            sharedSockets.connectSocket()
            sharedSockets.incomingCallDelegate = self
            
            // Set the active view controller
            sharedSockets.activeViewController = self
            
            // Simulate receiving an incoming call
            sharedSockets.receiveIncomingCall()
        // Do any additional setup after loading the view.
    }
    
    @objc func openViewController(_ notification: Notification) {
          
        if let value = notification.userInfo?["callerid"] as? String {
            
        let callReceiverVC = storyboard?.instantiateViewController(withIdentifier: "callRecieverscreen") as! CallRecieverViewController
        callReceiverVC.hidesBottomBarWhenPushed = true
            callReceiverVC.calllerid = value
        navigationController?.pushViewController(callReceiverVC, animated: true)
        }
       }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
