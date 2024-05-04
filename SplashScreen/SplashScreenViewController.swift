//
//  SplashScreenViewController.swift
//  CommFusion
//
//  Created by Umer Farooq on 04/05/2024.
//  Copyright © 2024 n0. All rights reserved.
//

import UIKit

class SplashScreenViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        if UserDefaults.standard.integer(forKey: "userID") != 0{
            let controller = self.storyboard!.instantiateViewController(identifier: "dashboard")
            controller.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(controller, animated: true)
        }

        // Do any additional setup after loading the view.
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
