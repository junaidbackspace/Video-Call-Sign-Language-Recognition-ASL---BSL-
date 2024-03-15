//
//  CallTranscriptionViewController.swift
//  SimpleWebRTC
//
//  Created by Umer Farooq on 15/03/2024.
//  Copyright © 2024 n0. All rights reserved.
//

import UIKit

class CallTranscriptionViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var tble: UITableView!
    @IBOutlet weak var txtFeedBackMsg: UITextField!
    @IBOutlet weak var TableConstraints: NSLayoutConstraint!
    @IBOutlet weak var FeedBackView: UIView!
    @IBOutlet weak var lbltagedMsg: UILabel!
    @IBOutlet weak var FeedBack_DoneView: UIView!
    
    
    var longPressGesture: UILongPressGestureRecognizer!
    var longPressIndexPath: IndexPath?
    
    let messages = [
        "Junaid: Hey Umer how are you?",
        "Umer: I am fine what about you?",
        "Junaid: I'm doing well, thanks for asking.",
        "Umer: Did you watch the game last night?",
        "Junaid: Yes, it was incredible! I couldn't believe the final score.",
        "Umer: Yeah, it was a nail-biter until the end.",
        "Junaid: Definitely. We should watch the next game together.",
        "Umer: Sounds like a plan!",
        "Junaid: Great, looking forward to it.",
        "Umer: Me too!"
    ]

    
    let containerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 100))
    
    func setupUI()
    {
      
        txtFeedBackMsg.frame.size.height += 150

        addDoneButtonToKeyboard(for: txtFeedBackMsg)
        
        self.view.addSubview(containerView)

        containerView.frame = CGRect(x: 10, y: 580, width: UIScreen.main.bounds.width, height: 100)

        containerView.addSubview(FeedBack_DoneView)
        containerView.isHidden = true
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        TableConstraints.constant = 0
        FeedBackView.isHidden = true
        tble.delegate = self
        tble.dataSource = self
        tble.separatorStyle = .none
        
        setupUI()
        
        
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        tble.addGestureRecognizer(longPressGesture)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleScreenTap(sender:)))
            // Make sure the recognizer doesn't cancel other touch events, like table view cell selections
            tapGestureRecognizer.cancelsTouchesInView = false
            view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func handleScreenTap(sender: UITapGestureRecognizer) {
        let location = sender.location(in: view)

       
        if customView.isHidden == false && !customView.frame.contains(location) {
            customView.isHidden = true
            print("Hiding view")
            }
    }

    
    var selectedrow = 0
   
    var customView = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 30))
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
       
            if gestureRecognizer.state == .began {
              
                let point = gestureRecognizer.location(in: tble)
                          if let indexPath = tble.indexPathForRow(at: point), let cell = tble.cellForRow(at: indexPath) {
                              longPressIndexPath = indexPath
                              selectedrow = indexPath.row

                    customView.subviews.forEach { $0.removeFromSuperview() }
                            let lightBlueColor = UIColor(red: 50/255, green: 50/255, blue: 230/255, alpha: 1.0)

                            customView.backgroundColor = lightBlueColor
                    customView.alpha = 0.9
                    customView.isHidden = false

                   
                    
                    // Add Like button
                    let likeButton = UIButton(type: .system)
                    likeButton.setBackgroundImage(UIImage(named: "like"), for: .normal)
                    likeButton.frame = CGRect(x: 10, y: 5, width: 23, height: 20)
                    likeButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
                    customView.addSubview(likeButton)

                    // Add Dislike button
                    let dislikeButton = UIButton(type: .system)
                    dislikeButton.setBackgroundImage(UIImage(named: "dislike"), for: .normal)
                    dislikeButton.frame = CGRect(x: 50, y: 8, width: 23, height: 20)
                    dislikeButton.addTarget(self, action: #selector(dislikeButtonTapped), for: .touchUpInside)
                    customView.addSubview(dislikeButton)
                        
                        customView.removeFromSuperview()
                    
                    
                    let cellRect = cell.convert(cell.bounds, to: view)
                                    let cellCenter = CGPoint(x: cellRect.midX, y: cellRect.midY)

                                    // Set customView's center to the cell's center
                                    customView.center = cellCenter
                    // Add the custom view to your view hierarchy
                    view.addSubview(customView)
                }
            }
        
    }




    
    
        
        @objc func likeButtonTapped() {
           
            customView.isHidden = true
             print("Like Tapped on \(selectedrow)")
            
        }
        
    
    
    
        @objc func dislikeButtonTapped() {
          
            customView.isHidden = true
            print("Dislike Taped on \(selectedrow)")
            lbltagedMsg.text = messages[selectedrow]
            TableConstraints.constant = 357
            FeedBackView.isHidden = false
           
        }
        
    
    @IBAction func btnSubmit(_ sender: Any) {
        
        TableConstraints.constant = 0
        FeedBackView.isHidden = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            
            self.containerView.isHidden = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            
            self.containerView.isHidden = true
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return messages.count
       }

    
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "c1", for: indexPath) as! CallTranscriptionTableViewCell
        
      
        if indexPath.row % 2 == 0{
            
            cell.lblMsg.text = messages[indexPath.row]
            cell.msgView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 1, alpha: 0.5)
            cell.msgViewLeadingConstraints.constant = 20
            cell.msgViewTrailingConstraints.constant = 10
          
        }
       
        else{
            cell.lblMsg.text = messages[indexPath.row]
            cell.msgView.backgroundColor = UIColor.init(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.5)
            cell.msgViewLeadingConstraints.constant = -10
            cell.msgViewTrailingConstraints.constant = -20
            
            
        }
            return cell
       }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    func addDoneButtonToKeyboard(for textField: UITextField) {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .close, target: textField, action: #selector(UIResponder.resignFirstResponder))
        toolbar.items = [doneButton]
        
        textField.inputAccessoryView = toolbar
    }
        
        
        

}
