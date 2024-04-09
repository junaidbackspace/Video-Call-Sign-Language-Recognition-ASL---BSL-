//
//  PlayerLessonsViewController.swift
//  SimpleWebRTC
//
//  Created by Umer Farooq on 09/02/2024.
//  Copyright © 2024 n0. All rights reserved.
//

import UIKit
import SwiftGifOrigin
import ImageIO

class PlayerLessonsViewController: UIViewController {

    var fav_less = [Int]()
    var gifData: Data?
    var gifImage: UIImage?
    var pausedImage: UIImage?
    var isGifPaused = false
    var logindefaults = UserDefaults.standard
    var serverWrapper = APIWrapper()

    var trainingname = ""
    var signtext = "Lecture name here"
    var lesson_level = ""
    var Resource_URL = ""
    var lesson_id = 0
    var guester_id = 0
    
    var filenames = [String]()

   

    var isAnimating = true
    var userid = UserDefaults.standard.integer(forKey: "userID")
    
    @IBAction func btnback(_ sender: Any) {
        self.navigationController?.popViewController(animated: true) 
    }
    @IBAction func btn_back_lesson(_ sender: Any) {
        
        //Setting next gif path
        var count = 0
        for i in 0..<26 {
            let letter = Character(UnicodeScalar(97 + i)!)
            let filename = "\(letter).gif"
            print("\n letter: \(filename)")
            filenames.append(filename)
             }
        //minimum id
        if guester_id > 41 {
        for name in filenames{
            if name == Resource_URL{
               
                Resource_URL = filenames[count-1]
                break
            }
            count += 1
        }
            guester_id -= 1
        }
            let parts = Resource_URL.split(separator: ".")
            let firstPart = String(parts.first ?? "")
            lbl_Current_Content_name.text = "Sign for \(firstPart)"
            getLessonGIF()
           
      
        
        timer?.invalidate()
        timer = nil
        
        elapsedTime = 0
        pgrbar_Time.progress = 0
        isPaused = !isPaused
           
        startTimer()
        if fav_less.contains(guester_id)
        {
        if let currentImage = OutLetisfaviorteStar.currentBackgroundImage,
               currentImage == UIImage(systemName: "star.fill")?.withTintColor(UIColor.yellow) {
        }
        }
        else{
            self.OutLetisfaviorteStar.setBackgroundImage(UIImage(systemName: "star"), for: .normal)
           
        }
    }
    @IBAction func btn_pause_lesson(_ sender: Any) {
        
        if isGifPaused {
           
                    print("Animation is started")
                    // Resume GIF playback
                    resumeGif()
                   
                } else {
                    print("Animation is stoped")
                    // Pause GIF playback
                    pauseGif()
                   
                }
                isGifPaused.toggle()
            
            // Toggle the timer state
            if isPaused {
               
              
                // Resume the timer
                startTimer()
                if let image = UIImage(systemName: "pause.circle")?.withTintColor(UIColor.white) {
                    Outlet_btnPause.setBackgroundImage(image, for: .normal)
                }
            } else {
            
                
                // Pause the timer
                timer?.invalidate()
                timer = nil
                if let image = UIImage(systemName: "arrowtriangle.right.circle")?.withTintColor(UIColor.white) {
                    Outlet_btnPause.setBackgroundImage(image, for: .normal)
                }
            }
            isPaused = !isPaused
    }
    @IBAction func btn_next_lesson(_ sender: Any) {
        
        
        //Setting next gif path
        var count = 0
        for i in 0..<26 {
            let letter = Character(UnicodeScalar(97 + i)!)
            let filename = "\(letter).gif"
            print("\n letter: \(filename)")
            filenames.append(filename)
             }
        //max Limit
        if guester_id < 66 {
        for name in filenames{
            if name == Resource_URL{
               
                Resource_URL = filenames[count+1]
                break
            }
            count += 1
        }
    
            guester_id += 1
        }
            let parts = Resource_URL.split(separator: ".")
            let firstPart = String(parts.first ?? "")
            lbl_Current_Content_name.text = "Sign for \(firstPart)"
            getLessonGIF()
           
      
        
        timer?.invalidate()
        timer = nil
        
        elapsedTime = 0
        pgrbar_Time.progress = 0
        
        isPaused = !isPaused
           
        startTimer()
        if fav_less.contains(guester_id)
        {
            self.OutLetisfaviorteStar.setBackgroundImage(UIImage(systemName: "star.fill"), for: .normal)
        }
        else{
            self.OutLetisfaviorteStar.setBackgroundImage(UIImage(systemName: "star"), for: .normal)
           
        }
            
        
    }
    
    
    @IBAction func isFavorite_Start(_ sender: Any) {
        
       
        
        print("Gesture id : \(guester_id), char is \(lbl_Current_Content_name.text)")
        if fav_less.contains(guester_id)
        {
        if let currentImage = OutLetisfaviorteStar.currentBackgroundImage,
               currentImage == UIImage(systemName: "star.fill")?.withTintColor(UIColor.yellow) {
            
            print("going to unlike ....")
                // Change the button's background image to the default state
            let Url = "\(Constants.serverURL)/userfavoritegesture"

           
            let Dic: [String: Any] = [
                "user_id": userid,
                  "gesture_id": guester_id
            ]

            serverWrapper.deleteData(baseUrl: Url,  data: Dic) { responseString, error in
                if let error = error {
                    print("\n\nError:", error)
                  
                }
                if let responseString = responseString {
                    print("Lessons response:", responseString)
                    
                    self.OutLetisfaviorteStar.setBackgroundImage(UIImage(systemName: "star"), for: .normal)
                        
                    //Update Array in User Default
                    self.fav_less.removeAll { $0 == self.guester_id }
                    UserDefaults.standard.setValue(self.fav_less, forKey: "fav_Les")
                    
                    }
                        
                    }
            }
            
        }
    else {
                print("Not in list \(lbl_Current_Content_name.text)")
                
                let Url = "\(Constants.serverURL)/userfavoritegesture/add"

                var userid = self.logindefaults.integer(forKey: "userID")
                let Dic: [String: Any] = [
                    "user_id": userid,
                      "gesture_id": guester_id
                ]

                serverWrapper.insertData(baseUrl: Url,  userDictionary: Dic) { responseString, error in
                    if let error = error {
                        print("\n\nError:", error)
                      
                    }
                    if let responseString = responseString {
                        print("Lessons response:", responseString)
                        
                        if let image = UIImage(systemName: "star.fill")?.withTintColor(UIColor.yellow) {
                            self.OutLetisfaviorteStar.setBackgroundImage(image, for: .normal)
                            
                            //Store Array in User Default
                            self.fav_less.append(self.guester_id)
                            UserDefaults.standard.setValue(self.fav_less, forKey: "fav_Les")
                            
                    
                    }
                }
                
                
            }
    }
        //updating current list
        if let retrievedArray = UserDefaults.standard.array(forKey: "fav_Les") as? [Int] {
            let Fav_Lessons = retrievedArray
           
            fav_less = Fav_Lessons
         }
    }
    //to make round blue footer
    @IBOutlet weak var viewplayer: UIView!
    @IBOutlet weak var OutLetisfaviorteStar: UIButton!
    @IBOutlet weak var Outlet_btnPause: UIButton!
    @IBOutlet weak var lbl_endTime: UILabel!
    @IBOutlet weak var lbl_starttime: UILabel!
    @IBOutlet weak var imageplayer: UIImageView!
    @IBOutlet weak var pgrbar_Time: UIProgressView!
    @IBOutlet weak var lbl_Current_Content_name: UILabel!
    @IBOutlet weak var lbl_Training_name: UILabel!
    @IBOutlet weak var lbl_Lessonlevel: UILabel!
    var timer: Timer?
     let duration: TimeInterval = 10 // Duration of the video in seconds
     var elapsedTime: TimeInterval = 0
     var isPaused: Bool = false // Track if the video is paused
       
 
func usergetLesson()
{
    let Url = "\(Constants.serverURL)/usertakeslesson/add"
   
    
    
    // Define your parameters
    let Dic: [String: Any] = [
        "UserId": userid,
          "LessonId": lesson_id
    ]

    serverWrapper.insertData(baseUrl: Url,  userDictionary: Dic) { responseString, error in
        if let error = error {
            print("\n\nError:", error)
          
        }
        if let responseString = responseString {
            print("w response:", responseString)
            
            guard let responseData = responseString.data(using: .utf8) else {
                print("Error converting response data to UTF-8")
                return
            }

            
          
        }

    }
}
    

    var  urlString = String()
    func getLessonGIF()
    {
        let category = trainingname.lowercased()
        var signtype = UserDefaults.standard.string(forKey: "SignType")!.lowercased()
         urlString = "\(Constants.serverURL)/gesture/\(signtype)/\(category)/\(Resource_URL)"
        print ("URL IS : \(urlString)")
        if let url = URL(string: urlString) {
               fetchGifDataFromServer(url: url) { (gifData, error) in
                   if let error = error {
                       print("Error fetching GIF data: \(error.localizedDescription)")
                       return
                   }
                   
                   if let gifData = gifData {
                       DispatchQueue.main.async {
                         
                           print("GIF data received:", gifData)
                        
                        if let temporaryFileURL = self.saveGifDataToTemporaryFile(gifData) {
                                    
                                   
                                    
                                    let localURL = temporaryFileURL
                            
                            self.gifData = try? Data(contentsOf: localURL)
                            self.gifImage = UIImage.gif(data: gifData)
                            self.pausedImage =  self.extractFrame(fromGif: localURL, atIndex: 0)
                            
                            self.imageplayer.image = self.gifImage

                                } else {
                                    print("Failed to save GIF data to temporary file")
                                }
                        
                       
                       
                       
                
                       }
                   } else {
                       print("Failed to fetch GIF data")
                   }
               }
           }
    }
    func saveGifDataToTemporaryFile(_ gifData: Data) -> URL? {
        // Create a unique temporary file URL
        let temporaryDirectory = FileManager.default.temporaryDirectory
        let temporaryFilename = UUID().uuidString + ".gif"
        let temporaryFileURL = temporaryDirectory.appendingPathComponent(temporaryFilename)
        
        // Write the GIF data to the temporary file
        do {
            try gifData.write(to: temporaryFileURL)
            return temporaryFileURL
        } catch {
            print("Error saving GIF data to temporary file:", error)
            return nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if let retrievedArray = UserDefaults.standard.array(forKey: "fav_Les") as? [Int] {
            let Fav_Lessons = retrievedArray
           
            fav_less = Fav_Lessons
         }
        if fav_less.contains(guester_id)
        {
            if let image = UIImage(systemName: "star.fill")?.withTintColor(UIColor.yellow) {
                self.OutLetisfaviorteStar.setBackgroundImage(image, for: .normal)
            }
        }
        
        lbl_Current_Content_name.text = "Sign for \(signtext)"
        lbl_Training_name.text = trainingname
       print("\n\n\nGif URL :\(Resource_URL)")
        lbl_Lessonlevel.text = lesson_level
        viewplayer.layer.cornerRadius = 20
        viewplayer.layer.borderWidth = 1.0
        viewplayer.layer.borderColor = UIColor.black.cgColor
        
        //fetching gif from server
        getLessonGIF()
       
              

        usergetLesson()
        startGifAnimation()
        pgrbar_Time.progress = 0
        // Set total time label
        lbl_endTime.text = formatTime(duration)
        // Start the timer
        startTimer()
    }
    
    func startTimer() {
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
        }
        
        @objc func updateProgress() {
            if !isPaused {
                // Increment elapsed time
                elapsedTime += 0.1
                
                // Calculate progress
                let progress = Float(elapsedTime / duration)
                
                // Update progress view
                pgrbar_Time.progress = progress
                
                // Update start time label
                lbl_starttime.text = formatTime(elapsedTime)
                
                // Check if video playback is completed
                if elapsedTime >= duration {
                    // Stop the timer
                   
                    pauseGif()
                    // Pause the timer
                    timer?.invalidate()
                    timer = nil
                    if let image = UIImage(systemName: "arrowtriangle.right.circle")?.withTintColor(UIColor.white) {
                        Outlet_btnPause.setBackgroundImage(image, for: .normal)

                        elapsedTime = 0
                        pgrbar_Time.progress = 0
                        isGifPaused.toggle()
                        isPaused = !isPaused
                    }
                }
            }
        }
        
        func formatTime(_ timeInterval: TimeInterval) -> String {
            let minutes = Int(timeInterval) / 60
            let seconds = Int(timeInterval) % 60
            return String(format: "%02d:%02d", minutes, seconds)
        }
    
    //GIF Pausing Setup
    func startGifAnimation() {
            guard let gifImage = gifImage else { return }
            imageplayer.image = gifImage
        }

        func pauseGif() {
            // Display the first frame of the GIF when pausing
            imageplayer.image = pausedImage
        }

        func resumeGif() {
            // Resume GIF playback
            imageplayer.image = gifImage
        }
    func extractFrame(fromGif gifURL: URL, atIndex index: Int) -> UIImage? {
        guard let source = CGImageSourceCreateWithURL(gifURL as CFURL, nil) else { return nil }
        guard let cgImage = CGImageSourceCreateImageAtIndex(source, index, nil) else { return nil }
        return UIImage(cgImage: cgImage)
    }
    
    
    func fetchGifDataFromServer(url: URL, completion: @escaping (Data?, Error?) -> Void) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, NSError(domain: "NoData", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"]))
                return
            }
            
            completion(data, nil)
        }.resume()
    }


    
}
