//
//  expertlevelViewController.swift
//  SimpleWebRTC
//
//  Created by Umer Farooq on 28/02/2024.
//  Copyright © 2024 n0. All rights reserved.
//

import UIKit

class expertlevelViewController: UIViewController {

    @IBAction func btnback(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBOutlet weak var viewphrases: UIView!
    @IBOutlet weak var viewNumbers: UIView!
    @IBOutlet weak var viewAlphabets: UIView!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewphrases.layer.cornerRadius = 20
        viewphrases.layer.borderWidth = 1.0
        viewphrases.layer.borderColor = UIColor.black.cgColor
        
        viewNumbers.layer.cornerRadius = 20
        viewNumbers.layer.borderWidth = 1.0
        viewNumbers.layer.borderColor = UIColor.black.cgColor
        
        viewAlphabets.layer.cornerRadius = 20
        viewAlphabets.layer.borderWidth = 1.0
        viewAlphabets.layer.borderColor = UIColor.black.cgColor
    }
    

    @IBAction func btn_Phrases(_ sender: Any) {
        let controller = self.storyboard?.instantiateViewController(identifier: "LessonsGallery") as! LessonsListViewController
        controller.trainingname = "Phrases"
        controller.lesson_level = "Expert"
        controller.hidesBottomBarWhenPushed = true
        controller.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func btn_Numbers(_ sender: Any) {
        let controller = self.storyboard?.instantiateViewController(identifier: "LessonsGallery") as! LessonsListViewController
        controller.trainingname = "Numbers"
        controller.lesson_level = "Expert"
        controller.hidesBottomBarWhenPushed = true
        controller.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(controller, animated: true)
    }
    @IBAction func btn_Alphabets(_ sender: Any) {
        let controller = self.storyboard?.instantiateViewController(identifier: "LessonsGallery") as! LessonsListViewController
        controller.trainingname = "Alphbets"
        controller.lesson_level = "Expert"
        controller.hidesBottomBarWhenPushed = true
        controller.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(controller, animated: true)
    }

}
