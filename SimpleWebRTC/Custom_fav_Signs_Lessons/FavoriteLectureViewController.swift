//
//  FavoriteLectureViewController.swift
//  SimpleWebRTC
//
//  Created by Umer Farooq on 10/02/2024.
//  Copyright © 2024 n0. All rights reserved.
//

import UIKit

class FavoriteLectureViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var cat = ["Alphabets","Numbers","Phrases","Alphabets","Numbers","Phrases"]
    var signtext = ["G","5","i am fine","T","6","i am Beautiful",]

    @IBOutlet weak var tble: UITableView!
    @IBAction func back_btn(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cat.count
    }
    
    var n = 0
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        var cell = tble.dequeueReusableCell(withIdentifier: "c1") as? FavoriteSignsTableViewCell
        
        let randomColor = UIColor(    red: .random(in: 0...1),
                                      green: .random(in: 0...1),
                                      blue: .random(in: 0...1),
                                      alpha: 0.2)
            
        cell?.backgroundColor = randomColor
        cell?.Category.text = cat[indexPath.row]
        cell?.signtext.text =  signtext[indexPath.row]
        cell?.btnfavorite.addTarget(self, action: #selector(btn_favpriteClick(_:)), for: .touchUpInside)
        return cell!
    }
    @objc func btn_favpriteClick(_ sender:UIButton)
    {
        sender.setBackgroundImage(UIImage(systemName: "star"), for: .normal)
        print("clicked",sender.tag)
        
        //delete data from table
            
        tble.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tble.cellForRow(at: indexPath)
               cell?.backgroundColor = .white
        //let selectedRow = indexPath.row
        let controller = self.storyboard?.instantiateViewController(identifier: "playerController") as! PlayerLessonsViewController
        controller.trainingname =  cat[indexPath.row]
        controller.signtext = signtext [indexPath.row]
        controller.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(controller, animated: true)
           }
           
       
    override func viewDidLoad() {
        super.viewDidLoad()
        tble.dataSource = self
        tble.delegate = self
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
