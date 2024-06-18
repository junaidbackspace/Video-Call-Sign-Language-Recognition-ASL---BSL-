//
//  WordsSignsPlayer.swift
//  CommFusion
//
//  Created by Umer Farooq on 18/06/2024.
//  Copyright © 2024 n0. All rights reserved.
//

import Foundation
let videocall = ViewController()
class GifManager {
    
    
    private var playedGifs: Set<String> = []
    private var wordToGifMap: [String: String] = [
        "hello": "hello.gif",
        "how": "howareyou.gif",
        "cool": "cool.gif",
        "happy": "happy.gif",
        "fine": "iamfine.gif",
        "learning": "iamlearning.gif",
        "love": "iloveyou.gif",
        "calm": "keepcalmandstayhome.gif",
        "kiss": "kiss.gif",
        "me": "me.gif",
        "meet": "nicetomeetyou.gif",
        "no": "no.gif",
        "ok": "ok.gif",
        "please": "please.gif",
        "sorry": "sorry.gif",
        "super": "super.gif",
        "thankyou": "thankyou.gif",
        "try": "tryagain.gif",
        "understand": "understand.gif",
        "from": "whereareyoufrom.gif",
        "wonderful": "wonderful.gif",
        "you": "you.gif"
        // Add more mappings as needed
    ]
    
    func processTranscription(_ transcription: String) {
        let words = transcription.lowercased().split(separator: " ")
        
        for word in words {
            let wordStr = String(word)
            if let gifName = wordToGifMap[wordStr], !playedGifs.contains(wordStr) {
                playGif(named: gifName)
//                playedGifs.insert(wordStr) play_sign_video
                
                print("giving text for video : \(wordStr)")
                videocall.play_sign_video(name: wordStr)
            }
        }
    }
    
    private func playGif(named gifName: String) {
       
        }
    
}
