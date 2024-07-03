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
        // Instantiate view controllers from the storyboard
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
                guard let firstVC = storyboard.instantiateViewController(withIdentifier: "onlineContacts") as? onlineContactsViewController,
                      let secondVC = storyboard.instantiateViewController(withIdentifier: "createclass") as? AddClassMemberViewController,
                      let  thirdVC = storyboard.instantiateViewController(withIdentifier: "calllogs") as? CallLogsViewController,
                      let forthVC = storyboard.instantiateViewController(withIdentifier: "leassonsDashbaord") as? leassonsViewController else {
                    fatalError("Unable to instantiate one or more view controllers from storyboard")
                }
                
                // Set tab bar items
        firstVC.tabBarItem = UITabBarItem(title: "Online Contacts", image: UIImage(systemName: "person.2"), tag: 0)
        secondVC.tabBarItem = UITabBarItem(title: "Groups", image: UIImage(systemName: "person.3"), tag: 1)
        thirdVC.tabBarItem = UITabBarItem(title: "Call History", image: UIImage(systemName: "phone.fill"), tag: 2)
        forthVC.tabBarItem = UITabBarItem(title: "Lessons", image: UIImage(named: "lessons_TAB"), tag: 3)

                
        viewControllers = [firstVC ,secondVC, thirdVC , forthVC]
        
        NotificationCenter.default.addObserver(self, selector: #selector(openViewController(_:)), name: .openViewControllerNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(openGroupCallController(_:)), name: .openGroupCallNotification, object: nil)
        
         
        let sharedSockets = socketsClass.shared
     
            print("--->Conecting sockets..\n")
            sharedSockets.connectSocket()
            sharedSockets.incomingCallDelegate = self
            sharedSockets.activeViewController = self
            sharedSockets.receiveIncomingCall()
        // Do any additional setup after loading the view.
    
    }
    
    @objc func openViewController(_ notification: Notification) {
         print("opening recieving call screen")
        if let value = notification.userInfo?["callerid"] as? String {
            
        let callReceiverVC = storyboard?.instantiateViewController(withIdentifier: "callRecieverscreen") as! CallRecieverViewController
        callReceiverVC.hidesBottomBarWhenPushed = true
            callReceiverVC.calllerid = value
        navigationController?.pushViewController(callReceiverVC, animated: true)
        }
       }
    
    @objc func openGroupCallController(_ notification: Notification) {
         print("opening recieving call screen")
        
        let callReceiverVC = storyboard?.instantiateViewController(withIdentifier: "callRecieverscreen") as! CallRecieverViewController
        
        if let userInfo = notification.userInfo,
               let firstuser = userInfo["firstuser"] as? Int,
               let seconduser = userInfo["seconduser"] as? Int,
               let videocallid = userInfo["videocallid"] as? Int {
                // Handle the values here
                print("First User ID: \(firstuser)")
                print("Second User ID: \(seconduser)")
                print("Video Call ID: \(videocallid)")
            
            
            callReceiverVC.hidesBottomBarWhenPushed = true
            callReceiverVC.caller1_id = firstuser
            callReceiverVC.caller2_id = seconduser
            callReceiverVC.vid = videocallid
//            callReceiverVC.calllerid = ""
            
            }
        navigationController?.pushViewController(callReceiverVC, animated: true)
        
    }

    

}
