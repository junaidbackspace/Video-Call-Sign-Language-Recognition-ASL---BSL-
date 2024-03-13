//
//  CustomSignsViewController.swift
//  SimpleWebRTC
//
//  Created by Umer Farooq on 11/02/2024.
//  Copyright © 2024 n0. All rights reserved.
//

import UIKit

class CustomSignsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        tble.delegate = self
        tble.dataSource = self
        // Do any additional setup after loading the view.
    }
    

    var signtext = ["Hello Junaid","Whats going on","i am fine","How was the day","Did you do diner","i am Beautiful"]
    let ApprovalstatusImages = ["approved", "rejected", "pending"]

    @IBOutlet weak var tble: UITableView!
    @IBAction func back_btn(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return signtext.count
    }
    
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        var cell = tble.dequeueReusableCell(withIdentifier: "c1") as? CustomSignsTableViewCell
        
        let randomColor = UIColor(    red: .random(in: 0...1),
                                      green: .random(in: 0...1),
                                      blue: .random(in: 0...1),
                                      alpha: 0.2)
            
        cell?.backgroundColor = randomColor
        
        let randomIndex = Int(arc4random_uniform(UInt32(ApprovalstatusImages.count)))
        let randomImage = ApprovalstatusImages[randomIndex]
        if let image = UIImage(named: randomImage, in: Bundle.main, compatibleWith: nil) {
            cell?.Approvalstatus?.image = image
                }
       
        cell?.signtext.text =  signtext[indexPath.row]
        
       
        return cell!
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tble.cellForRow(at: indexPath)
               cell?.backgroundColor = .white
        //let selectedRow = indexPath.row
        
        let controller = self.storyboard?.instantiateViewController(identifier: "playerController") as! PlayerLessonsViewController
        controller.trainingname =  "Custom Sign"
        controller.signtext = signtext [indexPath.row]
        controller.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(controller, animated: true)
        
        
           }
           
  


}
