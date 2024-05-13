//
//  NotificationsViewController.swift
//  SimpleWebRTC
//
//  Created by Umer Farooq on 14/02/2024.
//  Copyright © 2024 n0. All rights reserved.
//

import UIKit
import DropDown
import AVFoundation
class NotificationsViewController: UIViewController {

    var musicPlayer: AVAudioPlayer?
       
       let names = ["Default","Glow","Smooth", "Shape of you", "Looser"] // Add your music options here
       let musicFiles = ["default","glow", "smooth","shapeofyou","loser"] // Corresponding music file names
       
    @IBAction func btnback(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBOutlet weak var soundOnOff: UISwitch!
    @IBAction func swithSound(_ sender: Any) {
        
    }
    
    @IBAction func rigntoneDrpDown(_ sender: Any) {
        let dropDown = DropDown()
        dropDown.anchorView = ringtoneView
        dropDown.dataSource =  names
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.lblrigntone.text = "\(item)"
            
            if ( item == "Default")
            {
                UserDefaults.standard.setValue("default", forKey: "rigntones")
                playMusic(fileName: musicFiles[index])
            }
        
        else if ( item == "Glow") {
            UserDefaults.standard.setValue("glow", forKey: "rigntones")
            playMusic(fileName: musicFiles[index])
            }
        else if ( item == "Smooth" ){
            UserDefaults.standard.setValue("smooth", forKey: "rigntones")
            playMusic(fileName: musicFiles[index])
        }
        else if ( item == "Shape of you" ){
            UserDefaults.standard.setValue("shapeofyou", forKey: "rigntones")
            playMusic(fileName: musicFiles[index])
        }
        else {
            UserDefaults.standard.setValue("loser", forKey: "rigntones")
            playMusic(fileName: musicFiles[index])
        }
            
        }
        dropDown.show()
    
    }
    @IBOutlet weak var lblrigntone: UILabel!
    @IBOutlet weak var ringtoneView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
//        UserDefaults.standard.setValue(0, forKey: "userID")
        // Do any additional setup after loading the view.
        if UserDefaults.standard.object(forKey: "rigntones") == nil {
            UserDefaults.standard.setValue("default", forKey: "rigntones")
            lblrigntone.text = "Default"
        }
        else {
            lblrigntone.text = UserDefaults.standard.string(forKey: "rigntones")! as String
        }
    }
    func playMusic(fileName: String) {
            guard let path = Bundle.main.path(forResource: fileName, ofType: "mp3") else {
                print("File not found")
                return
            }

            let url = URL(fileURLWithPath: path)

            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
                musicPlayer = try AVAudioPlayer(contentsOf: url)
                musicPlayer?.play()
            } catch {
                print("Error playing music: \(error.localizedDescription)")
            }
        }
    

    

}
