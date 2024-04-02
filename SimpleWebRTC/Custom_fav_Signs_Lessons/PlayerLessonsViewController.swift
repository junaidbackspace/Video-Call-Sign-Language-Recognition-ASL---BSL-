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
    var animatedImage: UIImage?
    var isAnimating = true
    
    @IBAction func btnback(_ sender: Any) {
        self.navigationController?.popViewController(animated: true) 
    }
    @IBAction func btn_back_lesson(_ sender: Any) {
        
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
    }
    
    
    @IBAction func isFavorite_Start(_ sender: Any) {
        
        if let currentImage = OutLetisfaviorteStar.currentBackgroundImage,
               currentImage == UIImage(systemName: "star.fill")?.withTintColor(UIColor.yellow) {
            
            print("going to unlike ....")
                // Change the button's background image to the default state
            let Url = "\(Constants.serverURL)/userfavoritegesture"

            var userid = self.logindefaults.integer(forKey: "userID")
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
                        
                        
                    guard let responseData = responseString.data(using: .utf8) else {
                        print("Error converting response data to UTF-8")
                        return
                    }
                        
                    }
            }
            
        }
              
             else {
                
                
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
                            
                            
                        guard let responseData = responseString.data(using: .utf8) else {
                            print("Error converting response data to UTF-8")
                            return
                        }
                            
                        }
                    }
                }
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
       
 

    
    override func viewDidLoad() {
        super.viewDidLoad()
        lbl_Current_Content_name.text = "Sign for \(signtext)"
        lbl_Training_name.text = trainingname
       print("\n\n\nGif URL :\(Resource_URL)")
        lbl_Lessonlevel.text = lesson_level
        viewplayer.layer.cornerRadius = 20
        viewplayer.layer.borderWidth = 1.0
        viewplayer.layer.borderColor = UIColor.black.cgColor
        
        // Load the GIF data
                if let gifURL = Bundle.main.url(forResource: "test", withExtension: "gif") {
                    gifData = try? Data(contentsOf: gifURL)
                    gifImage = UIImage.gif(data: gifData!)
                    pausedImage =  extractFrame(fromGif: gifURL, atIndex: 0)
                    
                }

        
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
                    timer?.invalidate()
                    timer = nil
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
    
}
