//
//  GroupsViewController.swift
//  CommFusion
//
//  Created by Umer Farooq on 29/05/2024.
//  Copyright © 2024 n0. All rights reserved.
//

import UIKit

class GroupsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tble.dequeueReusableCell(withIdentifier: "c2") as! GroupsTableTableViewCell
        cell.grp_img.image = UIImage(named: "profilepic", in: Bundle.main, compatibleWith: nil)
        cell.grp_msg.text = "Hi how are you"
        cell.grp_name.text = "Friends"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tble.cellForRow(at: indexPath)
               cell?.backgroundColor = .white
        
        
        let controller = self.storyboard?.instantiateViewController(identifier: "chatScreen") as! ChatScreenViewController
      
        controller.modalPresentationStyle = .fullScreen
        controller.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(controller, animated: true)
           
    
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    @IBOutlet weak var tble : UITableView!
    
    
    @IBAction func Create_grp(_ sender : Any)
    {
        let controller = self.storyboard!.instantiateViewController(identifier: "creategroupScreen")
        controller.modalPresentationStyle = .fullScreen
            controller.hidesBottomBarWhenPushed = true
          self.navigationController?.pushViewController(controller, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

       
        tble.delegate = self
        tble.dataSource = self
        // Add right swipe gesture recognizer
                let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
                rightSwipe.direction = .right
                self.view.addGestureRecognizer(rightSwipe)
                
                // Add left swipe gesture recognizer
                let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
                leftSwipe.direction = .left
                self.view.addGestureRecognizer(leftSwipe)
        
       
    }
    

    @objc func handleSwipes(_ gesture: UISwipeGestureRecognizer) {
           guard let tabBarController = self.tabBarController else { return }
           
           let numberOfTabs = tabBarController.viewControllers?.count ?? 0
           let selectedIndex = tabBarController.selectedIndex
           
           if gesture.direction == .right {
               if selectedIndex > 0 {
                   tabBarController.selectedIndex = selectedIndex - 1
               }
           } else if gesture.direction == .left {
               if selectedIndex < numberOfTabs - 1 {
                   tabBarController.selectedIndex = selectedIndex + 1
               }
           }
       }

    
    
}
