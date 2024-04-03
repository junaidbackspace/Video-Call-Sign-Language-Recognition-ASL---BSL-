//
//  intermediatelevelViewController.swift
//  SimpleWebRTC
//
//  Created by Umer Farooq on 28/02/2024.
//  Copyright © 2024 n0. All rights reserved.
//

import UIKit

class intermediatelevelViewController: UIViewController {

    var lessonstrct =  [LessonStrct]()
     var serverWrapper = APIWrapper()
    @IBOutlet weak var viewNumbers: UIView!
    @IBOutlet weak var viewGrammer: UIView!
    @IBOutlet weak var viewVocablary: UIView!
    @IBOutlet weak var viewExpression: UIView!
    
    @IBAction func btnback(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewNumbers.layer.cornerRadius = 20
        viewNumbers.layer.borderWidth = 1.0
        viewNumbers.layer.borderColor = UIColor.black.cgColor
        
        viewGrammer.layer.cornerRadius = 20
        viewGrammer.layer.borderWidth = 1.0
        viewGrammer.layer.borderColor = UIColor.black.cgColor
        
        viewVocablary.layer.cornerRadius = 20
        viewVocablary.layer.borderWidth = 1.0
        viewVocablary.layer.borderColor = UIColor.black.cgColor
        
        viewExpression.layer.cornerRadius = 20
        viewExpression.layer.borderWidth = 1.0
        viewExpression.layer.borderColor = UIColor.black.cgColor

        
        
        let Url = "\(Constants.serverURL)/lesson/query"

        // Define your parameters
        let Dic: [String: Any] = [
            "LanguageType": "ASL",
            "LessonLevel": "Intermediate"
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
    

    @IBAction func btn_Numbers(_ sender: Any) {
        
       
        let controller = self.storyboard?.instantiateViewController(identifier: "LessonsGallery") as! LessonsListViewController
        controller.trainingname = "Numbers"
        controller.lesson_level = "Intermediate"
        controller.les_id = lessonstrct[0].Les_id
        controller.hidesBottomBarWhenPushed = true
        controller.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(controller, animated: true)
    }
 
    @IBAction func btn_Grammers(_ sender: Any) {
        
       
        let controller = self.storyboard?.instantiateViewController(identifier: "LessonsGallery") as! LessonsListViewController
        controller.trainingname = "Grammer"
        controller.lesson_level = "Intermediate"
        controller.les_id = lessonstrct[1].Les_id
        controller.hidesBottomBarWhenPushed = true
        controller.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(controller, animated: true)
    }
 
    @IBAction func btn_Vocab(_ sender: Any) {
        
       
        let controller = self.storyboard?.instantiateViewController(identifier: "LessonsGallery") as! LessonsListViewController
        controller.trainingname = "Vocabuary"
        controller.lesson_level = "Intermediate"
        controller.les_id = lessonstrct[2].Les_id
        controller.hidesBottomBarWhenPushed = true
        controller.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(controller, animated: true)
    }
 
    @IBAction func btn_Expressions(_ sender: Any) {
        
       
        let controller = self.storyboard?.instantiateViewController(identifier: "LessonsGallery") as! LessonsListViewController
        controller.trainingname = "Expressions"
        controller.lesson_level = "Intermediate"
        controller.les_id = lessonstrct[3].Les_id
        controller.hidesBottomBarWhenPushed = true
        controller.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(controller, animated: true)
    }
 

}
