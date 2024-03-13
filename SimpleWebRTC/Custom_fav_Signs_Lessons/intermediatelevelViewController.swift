//
//  intermediatelevelViewController.swift
//  SimpleWebRTC
//
//  Created by Umer Farooq on 28/02/2024.
//  Copyright © 2024 n0. All rights reserved.
//

import UIKit

class intermediatelevelViewController: UIViewController {

    @IBOutlet weak var viewPhrases: UIView!

    
    @IBAction func btnback(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewPhrases.layer.cornerRadius = 20
        viewPhrases.layer.borderWidth = 1.0
        viewPhrases.layer.borderColor = UIColor.black.cgColor

        // Do any additional setup after loading the view.
    }
    

    @IBAction func btn_Numbers(_ sender: Any) {
        let controller = self.storyboard?.instantiateViewController(identifier: "LessonsGallery") as! LessonsListViewController
        controller.trainingname = "Numbers"
        controller.lesson_level = "Intermediate"
        controller.hidesBottomBarWhenPushed = true
        controller.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(controller, animated: true)
    }

}
