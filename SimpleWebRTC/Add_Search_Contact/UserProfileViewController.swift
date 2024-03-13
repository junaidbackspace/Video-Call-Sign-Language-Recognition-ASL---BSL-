//
//  UserProfileViewController.swift
//  SimpleWebRTC
//
//  Created by Umer Farooq on 07/02/2024.
//  Copyright © 2024 n0. All rights reserved.
//

import UIKit

class UserProfileViewController: UIViewController {
    @IBOutlet weak var lblname: UILabel!
    
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        
    }
    @IBOutlet weak var profilepic: UIImageView!
    @IBOutlet weak var disabilityImg: UIImageView!
    @IBOutlet weak var lblabout: UILabel!
    
    
    @IBAction func btncall(_ sender: Any) {
        
           let controller = self.storyboard?.instantiateViewController(identifier: "callerscreen") //as! CallerViewController
//        controller.name =  lblname.text!
//        controller.isringing = "Calling"
//        controller.profilepic = profilepic.image!
        controller?.modalPresentationStyle = .fullScreen
        controller?.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(controller!, animated: true)
    }
    
    @IBAction func btnBlock(_ sender: Any) {
    }
    var name = " "
    var about = " "
    var distype = " "
    var img = UIImage()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        lblname.text = name
        lblabout.text = about
        profilepic.image = img
        
        if distype == "deff"
        {
            if let image = UIImage(named: "deff", in: Bundle.main, compatibleWith: nil) {
                disabilityImg.image = image
                    }
            
        }
        else if distype == "blind"
        {
            
        }
        else{
            
        }
        // Do any additional setup after loading the view.
    }
    

    

}
