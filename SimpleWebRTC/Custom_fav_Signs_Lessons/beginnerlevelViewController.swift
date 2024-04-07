//
//  Lessons_LevelsViewController.swift
//  SimpleWebRTC
//
//  Created by Umer Farooq on 27/02/2024.
//  Copyright © 2024 n0. All rights reserved.
//

import UIKit

class Lessons_LevelsViewController: UIViewController {

   var lessonstrct =  [LessonStrct]()
    var serverWrapper = APIWrapper()
    
    @IBAction func btnback(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    

    @IBOutlet weak var viewNumbers: UIView!
    @IBOutlet weak var viewAlphabets: UIView!
    @IBOutlet weak var viewWords: UIView!
    @IBOutlet weak var viewGreeting: UIView!
   

    
    var trainingname = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewNumbers.layer.cornerRadius = 20
        viewNumbers.layer.borderWidth = 1.0
        viewNumbers.layer.borderColor = UIColor.black.cgColor
        
        viewAlphabets.layer.cornerRadius = 20
        viewAlphabets.layer.borderWidth = 1.0
        viewAlphabets.layer.borderColor = UIColor.black.cgColor
        
        viewWords.layer.cornerRadius = 20
        viewWords.layer.borderWidth = 1.0
        viewWords.layer.borderColor = UIColor.black.cgColor
        
        viewGreeting.layer.cornerRadius = 20
        viewGreeting.layer.borderWidth = 1.0
        viewGreeting.layer.borderColor = UIColor.black.cgColor
        
        
        let Url = "\(Constants.serverURL)/lesson/query"
        
        var signtype = UserDefaults.standard.string(forKey: "SignType")!
        // Define your parameters
        let Dic: [String: Any] = [
            "LanguageType": signtype,
            "LessonLevel": "Beginner"
        ]

        serverWrapper.insertData(baseUrl: Url,  userDictionary: Dic) { responseString, error in
            if let error = error {
                print("\n\nError:", error)
              
            }
            if let responseString = responseString {
                print("Lessons response:", responseString)
                
                guard let responseData = responseString.data(using: .utf8) else {
                    print("Error converting response data to UTF-8")
                    return
                }

                do {
                    // Parse the response as an array of dictionaries
                    let jsonArray = try JSONSerialization.jsonObject(with: responseData, options: []) as? [[String: Any]]
                    
                    guard let lessonsArray = jsonArray else {
                        print("Invalid JSON format")
                        return
                    }
                    
                    
                    for lessonDict in lessonsArray {
                        var lessondata = LessonStrct()
                        if let lessonId = lessonDict["LessonId"] as? Int {
                            lessondata.Les_id = lessonId
                               
                        }
                        
                        if let lessonType = lessonDict["LessonType"] as? String {
                            lessondata.Les_type = lessonType
                            
                        }
                        self.lessonstrct.append(lessondata)
                    }
                } catch {
                    print("Error parsing JSON data: \(error)")
                }
            }

        }
            
    }
        
    

    
    @IBAction func btn_Alphabets(_ sender: Any) {
        
       
        let controller = self.storyboard?.instantiateViewController(identifier: "LessonsGallery") as! LessonsListViewController
        controller.trainingname = "Words"
        controller.lesson_level = "Beginner"
        print("lesson id is \(lessonstrct[0].Les_id)")
        controller.les_id = lessonstrct[0].Les_id
        controller.hidesBottomBarWhenPushed = true
        controller.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(controller, animated: true)
    }
    @IBAction func btn_Numbers(_ sender: Any) {
        
       
        let controller = self.storyboard?.instantiateViewController(identifier: "LessonsGallery") as! LessonsListViewController
        controller.trainingname = "Alphabets"
        controller.lesson_level = "Beginner"
        controller.les_id = lessonstrct[1].Les_id
        controller.hidesBottomBarWhenPushed = true
        controller.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(controller, animated: true)
    }
 
    @IBAction func btn_Words(_ sender: Any) {
        
       
        let controller = self.storyboard?.instantiateViewController(identifier: "LessonsGallery") as! LessonsListViewController
        controller.trainingname = "Greetings"
        controller.lesson_level = "Beginner"
        controller.les_id = lessonstrct[2].Les_id
        controller.hidesBottomBarWhenPushed = true
        controller.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(controller, animated: true)
    }
    @IBAction func btn_Greetings(_ sender: Any) {
        
       
        let controller = self.storyboard?.instantiateViewController(identifier: "LessonsGallery") as! LessonsListViewController
        controller.trainingname = "Numbers"
        controller.lesson_level = "Beginner"
        controller.les_id = lessonstrct[3].Les_id
        controller.hidesBottomBarWhenPushed = true
        controller.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(controller, animated: true)
    }
   
    

}
