//
//  GroupsViewController.swift
//  CommFusion
//
//  Created by Umer Farooq on 29/05/2024.
//  Copyright © 2024 n0. All rights reserved.
//

import UIKit

class GroupsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
              rightSwipe.direction = .right
              self.view.addGestureRecognizer(rightSwipe)
              
              // Add left swipe gesture recognizer
              let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
              leftSwipe.direction = .left
              self.view.addGestureRecognizer(leftSwipe)
        
    }
    
   // MARK:-
    
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
