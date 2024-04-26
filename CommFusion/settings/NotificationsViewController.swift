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
       
       let names = ["Loser", "Perfect", "Baby"] // Add your music options here
       let musicFiles = ["loser", "perfect", "baby"] // Corresponding music file names
       
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
            
            if ( item == "Loser")
            {
                playMusic(fileName: musicFiles[index])
            }
        
        else if ( item == "Perfect") {
            playMusic(fileName: musicFiles[index])
            }
        else{
            playMusic(fileName: musicFiles[index])
        }
            
        }
        dropDown.show()
    
    }
    @IBOutlet weak var lblrigntone: UILabel!
    @IBOutlet weak var ringtoneView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    func playMusic(fileName: String) {
            guard let path = Bundle.main.path(forResource: fileName, ofType: "mp3") else {
                print("File not found")
                return
            }

            let url = URL(fileURLWithPath: path)

            do {
                musicPlayer = try AVAudioPlayer(contentsOf: url)
                musicPlayer?.play()
            } catch {
                print("Error playing music: \(error.localizedDescription)")
            }
        }
    

    

}
