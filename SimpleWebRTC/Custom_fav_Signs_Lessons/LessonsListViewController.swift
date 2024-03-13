//
//  LessonsListViewController.swift
//  SimpleWebRTC
//
//  Created by Umer Farooq on 28/02/2024.
//  Copyright © 2024 n0. All rights reserved.
//

import UIKit

class LessonsListViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var trainingname = ""
    var lesson_level = ""
   
    let ContentName =  ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]

    let Content = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
    
    @IBOutlet weak var lblLeasonName : UILabel?
    
    @IBAction func btnback(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        ContentName.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let randomColor = UIColor(    red: .random(in: 0...1),
                                      green: .random(in: 0...1),
                                      blue: .random(in: 0...1),
                                      alpha: 0.5)
            
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! Custom_LessonsListCollectionViewCell
//               cell.backgroundColor = .lightGray
               
        cell.btn_play.tag = indexPath.row
        cell.btn_play.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        cell.lblLectureName.text = ContentName[indexPath.item]
        
        
        cell.viewcolor.backgroundColor = randomColor
        cell.viewcolor.layer.cornerRadius = 15
              
               return cell
    }
    @objc func buttonTapped(_ sender: UIButton) {
         let row = sender.tag
        let controller = self.storyboard?.instantiateViewController(identifier: "playerController") as! PlayerLessonsViewController
        controller.trainingname = self.trainingname
        controller.lesson_level = self.lesson_level
        controller.signtext = ContentName[row]
        controller.hidesBottomBarWhenPushed = true
        controller.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(controller, animated: true)
        }

    
    @IBOutlet weak var collectionview: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionview.dataSource = self
        collectionview.delegate = self
        lblLeasonName?.text = trainingname

        // Do any additional setup after loading the view.
    }
    

   

}
