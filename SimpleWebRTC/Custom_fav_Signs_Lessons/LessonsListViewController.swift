//
//  LessonsListViewController.swift
//  SimpleWebRTC
//
//  Created by Umer Farooq on 28/02/2024.
//  Copyright © 2024 n0. All rights reserved.
//

import UIKit

class LessonsListViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
   
    var serverWrapper = APIWrapper()
    var content  = [User]()
    var trainingname = ""
    var lesson_level = ""
    var les_id = 0
   
    let ContentName =  ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]

    let Content = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
    
    @IBOutlet weak var lblLeasonName : UILabel?
    
    @IBAction func btnback(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        content.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let randomColor = UIColor(    red: .random(in: 0...1),
                                      green: .random(in: 0...1),
                                      blue: .random(in: 0...1),
                                      alpha: 0.5)
            
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! Custom_LessonsListCollectionViewCell

               
        cell.btn_play.tag = indexPath.row
        cell.btn_play.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        cell.lblLectureName.text = content[indexPath.row].Les_Des
        
        
        cell.viewcolor.backgroundColor = randomColor
        cell.viewcolor.layer.cornerRadius = 15
              
               return cell
    }
    @objc func buttonTapped(_ sender: UIButton) {
         let row = sender.tag
        let controller = self.storyboard?.instantiateViewController(identifier: "playerController") as! PlayerLessonsViewController
        controller.trainingname = self.trainingname
        controller.lesson_level = self.lesson_level
        controller.signtext = content[row].Les_Des
        controller.lesson_id = content[row].Les_id
        print("")
        controller.hidesBottomBarWhenPushed = true
        controller.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(controller, animated: true)
        }

    
    @IBOutlet weak var collectionview: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        lblLeasonName?.text = trainingname
        DispatchQueue.global().async {
               self.fetchLessonsData()
           }
    }
    
    func fetchLessonsData() {
       
        let Url = "\(Constants.serverURL)/gesture/\(les_id)"
        print("URL: "+Url)
      
        let url = URL(string: Url)!
        serverWrapper.fetchData(baseUrl: url, structure: [Lesson].self) { Lessoncontent, error in
            if let error = error {
                print("Error:", error.localizedDescription)
               
            } else if let jsonData = Lessoncontent {
                print("JSON Data:", jsonData)
               
                self.processContactsData(jsonData)
            } else {
                print("No data received from the server")
            }
        }
    
    }

    func processContactsData(_ jsonArray: [Lesson]) {
            for userObject in jsonArray {
                let Id = userObject.Id
                let Lid = userObject.LessonId
                let Des = userObject.Description
                let Res = userObject.Resource
              

                // Now you can use these properties as needed
                print("ID: \(Id), Lesson Id : \(Lid), Description: \(Des), Resource: \(Res)")

                // Optionally, you can create a User object and append it to contacts array
                var user = User()
                user.Les_id = Lid
                user.Les_Des = Des
                user.Les_Res = Res
                
                self.content.append(user)
            }
        

        
        DispatchQueue.main.async {
            self.collectionview.dataSource = self
            self.collectionview.delegate = self
            self.collectionview.reloadData()
          
        }
    }
   

}
