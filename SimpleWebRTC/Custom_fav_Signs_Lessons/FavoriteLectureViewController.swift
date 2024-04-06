//
//  FavoriteLectureViewController.swift
//  SimpleWebRTC
//
//  Created by Umer Farooq on 10/02/2024.
//  Copyright © 2024 n0. All rights reserved.
//

import UIKit

class FavoriteLectureViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  

    var content  = [User]()
    var fav_less = [Int]()
    var serverWrapper = APIWrapper()
    
    @IBOutlet weak var tble: UITableView!
    @IBAction func back_btn(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Guesters count : \(content.count)")
        return content.count
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        var cell = tble.dequeueReusableCell(withIdentifier: "c1") as? FavoriteSignsTableViewCell
        
        let randomColor = UIColor(    red: .random(in: 0...1),
                                      green: .random(in: 0...1),
                                      blue: .random(in: 0...1),
                                      alpha: 0.2)
            
        cell?.backgroundColor = randomColor
        cell?.Category.text = content[indexPath.row].Les_Des
        cell?.signtext.text =  " Tap to view"
        cell?.btnfavorite.setBackgroundImage(UIImage(systemName: "star.fill"), for: .normal)
        cell?.btnfavorite.addTarget(self, action: #selector(btn_favpriteClick(_:)), for: .touchUpInside)
        return cell!
    }
    @objc func btn_favpriteClick(_ sender:UIButton)
    {
        sender.setBackgroundImage(UIImage(systemName: "star"), for: .normal)
        print("clicked",sender.tag)
        
        let gestureid = self.content[sender.tag].Gesture_id
        
        let Url = "\(Constants.serverURL)/userfavoritegesture"
        guard let userID = UserDefaults.standard.string(forKey: "userID") else {
                print("User ID not found")
                return
            }
        
        let Dic: [String: Any] = [
            "user_id": userID,
            "gesture_id": gestureid
        ]

        serverWrapper.deleteData(baseUrl: Url,  data: Dic) { responseString, error in
            if let error = error {
                print("\n\nError:", error)
              
            }
            if let responseString = responseString {
                print("Lessons response:", responseString)
                
                
                self.fav_less.removeAll { $0 == gestureid }
                UserDefaults.standard.setValue(self.fav_less, forKey: "fav_Les")
                
                
                self.content.removeAll { $0.Gesture_id == gestureid }
                
                self.tble.reloadData()
               
                }
                    
        }
  }
   
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tble.cellForRow(at: indexPath)
               cell?.backgroundColor = .white
        //let selectedRow = indexPath.row
        let controller = self.storyboard?.instantiateViewController(identifier: "playerController") as! PlayerLessonsViewController
        controller.trainingname = "Favorite Sign"
        controller.lesson_level = " "
        controller.signtext = content[indexPath.row].Les_Des
        controller.lesson_id = content[indexPath.row].Les_id
        controller.guester_id = content[indexPath.row].Gesture_id
        controller.Resource_URL = content[indexPath.row].Les_Res
        
        controller.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(controller, animated: true)
           }
           
       
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let retrievedArray = UserDefaults.standard.array(forKey: "fav_Les") as? [Int] {
            let Fav_Lessons = retrievedArray
           
            self.fav_less = Fav_Lessons
        DispatchQueue.global().async {
            self.fetchfavouriteLectures()
           
             }
        }
    }
    

    func fetchfavouriteLectures()
    {
        guard let userID = UserDefaults.standard.string(forKey: "userID") else {
                print("User ID not found")
                return
            }
            
            let Url = "\(Constants.serverURL)/userfavoritegesture/\(userID)"
            print("URL: "+Url)
          
            let url = URL(string: Url)!
            serverWrapper.fetchData(baseUrl: url, structure: [UserFavouriteLessons].self) { FavouriteLes, error in
                if let error = error {
                    print("Error:", error.localizedDescription)
                   
                } else if let jsonData = FavouriteLes {
                    print("JSON Data:", jsonData)
                   
                    self.processContactsData(jsonData)
                } else {
                    print("No data received from the server")
                }
            }
        
        }

        func processContactsData(_ jsonArray: [UserFavouriteLessons]) {
                for userObject in jsonArray {
                    let Ges_Id = userObject.GestureId
                  
                    
                    // Now you can use these properties as needed
                    print("Guesture id : \(Ges_Id)")
                    DispatchQueue.global().async {
                        self.fetchGuesture(gesid : Ges_Id)
                    }
                }
        
        
        }
    
    func fetchGuesture(gesid :Int)
    {
        guard let userID = UserDefaults.standard.string(forKey: "userID") else {
                print("User ID not found")
                return
            }
            
            let Url = "\(Constants.serverURL)/gesture/single/\(gesid)"
            print("URL: "+Url)
          
            let url = URL(string: Url)!
            serverWrapper.fetchData(baseUrl: url, structure: [Lesson].self) { FavouriteGes, error in
                if let error = error {
                    print("Error:", error.localizedDescription)
                   
                } else if let jsonData = FavouriteGes {
                    print("JSON Data:", jsonData)
                   
                    self.processGuesturesData(jsonData)
                } else {
                    print("No data received from the server")
                }
            }
        
        }

        func processGuesturesData(_ jsonArray: [Lesson]) {
            for userObject in jsonArray {
                let GestId = userObject.Id
                let Lid = userObject.LessonId
                let Des = userObject.Description
                let Res = userObject.Resource
              

                // Now you can use these properties as needed
                print("Guester_ID: \(GestId), Lesson Id : \(Lid), Description: \(Des), Resource: \(Res)")

                // Optionally, you can create a User object and append it to contacts array
                var user = User()
                user.Gesture_id = GestId
                user.Les_id = Lid
                user.Les_Des = Des
                user.Les_Res = Res
                
                self.content.append(user)
            }
            DispatchQueue.main.async {
                self.tble.dataSource = self
                self.tble.delegate = self
                
                self.tble.reloadData()
            }
        }
    

}
