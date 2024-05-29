//
//  leassonsViewController.swift
//  SimpleWebRTC
//
//  Created by Umer Farooq on 07/02/2024.
//  Copyright © 2024 n0. All rights reserved.
//

import UIKit

class leassonsViewController: UIViewController {

    
    @IBOutlet weak var viewBeginner: UIView!
    @IBOutlet weak var viewIntermediate: UIView!
    @IBOutlet weak var viewExpert: UIView!
    
    @IBAction func btn_settings(_ sender: Any) {
    let controller = self.storyboard!.instantiateViewController(identifier: "settings")
        controller.modalPresentationStyle = .fullScreen
        controller.hidesBottomBarWhenPushed = true
      self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func btn_CustomGuesters(_ sender: Any) {
        let controller = self.storyboard?.instantiateViewController(identifier: "CustomSignsList")
       
        controller!.modalPresentationStyle = .fullScreen
        controller!.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(controller!, animated: true)
    }
    
    @IBAction func btn_beginner(_ sender: Any) {
        let controller = self.storyboard?.instantiateViewController(identifier: "beginerLevelScreen")
        controller?.hidesBottomBarWhenPushed = true
        controller?.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(controller!, animated: true)
    }
    @IBAction func btn_intermediate(_ sender: Any) {
        let controller = self.storyboard?.instantiateViewController(identifier: "intermediateLevelScreen")
        controller?.hidesBottomBarWhenPushed = true
        controller?.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(controller!, animated: true)
    }
    @IBAction func btn_expert(_ sender: Any) {
        let controller = self.storyboard?.instantiateViewController(identifier: "expertLevelScreen")
        controller?.hidesBottomBarWhenPushed = true
        controller?.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(controller!, animated: true)
    }
    
    
    @IBAction func btn_Favorite(_ sender: Any) {
        
        let controller = self.storyboard?.instantiateViewController(identifier: "favoriteSigns")
        
        controller?.modalPresentationStyle = .fullScreen
        controller?.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(controller!, animated: true)
        
    }
    @IBAction func btn_addCustomSigns(_ sender: Any) {
        
        let controller = self.storyboard?.instantiateViewController(identifier: "addCustomSigns")
        
        controller?.modalPresentationStyle = .fullScreen
        controller?.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(controller!, animated: true)
    }
    @IBOutlet weak var btnOutlet_add_CustomSign: UIButton!
    @IBOutlet weak var viewCustomGuesters: UIView!
 
    @IBOutlet weak var FavoriteView: UIView!

    
    func setupUI()
    {
        
        btnOutlet_add_CustomSign.layer.cornerRadius = 20
        btnOutlet_add_CustomSign.layer.borderWidth = 1.0
        btnOutlet_add_CustomSign.layer.borderColor = UIColor.black.cgColor
        
       
        viewCustomGuesters.layer.cornerRadius = 30
        viewCustomGuesters.layer.borderWidth = 1.0
        viewCustomGuesters.layer.borderColor = UIColor.black.cgColor
        
        
       
        
        
        viewCustomGuesters.layer.cornerRadius = 30
        viewCustomGuesters.layer.borderWidth = 1.0
        viewCustomGuesters.layer.borderColor = UIColor.black.cgColor
        
        
        
        FavoriteView.layer.cornerRadius = 30
        FavoriteView.layer.borderWidth = 1.0
        FavoriteView.layer.borderColor = UIColor.black.cgColor
        
        viewBeginner.layer.cornerRadius = 20
        viewBeginner.layer.borderWidth = 1.0
        viewBeginner.layer.borderColor = UIColor.black.cgColor
        
        viewIntermediate.layer.cornerRadius = 20
        viewIntermediate.layer.borderWidth = 1.0
        viewIntermediate.layer.borderColor = UIColor.black.cgColor
        
        viewExpert.layer.cornerRadius = 20
        viewExpert.layer.borderWidth = 1.0
        viewExpert.layer.borderColor = UIColor.black.cgColor
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
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
