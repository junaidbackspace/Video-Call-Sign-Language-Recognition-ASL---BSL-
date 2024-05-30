//
//  ChatScreenViewController.swift
//  CommFusion
//
//  Created by Umer Farooq on 30/05/2024.
//  Copyright © 2024 n0. All rights reserved.
//

import UIKit

class ChatScreenViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var Outlettextmsg : UITextView!
    @IBOutlet weak var TableBottom_Constraints: NSLayoutConstraint!
    @IBOutlet weak var tble: UITableView!
    
    
    let messages = [
        "Junaid: Hey Umer how are you?",
        "Umer: I am fine what about you?",
        "Junaid: I'm doing well, thanks for asking.",
        "Umer: Did you watch the game last night?",
        "Junaid: Yes, it was incredible! I couldn't believe the final score,Yeah, it was a nail-biter until the end.",
        "Umer: Yeah, it was a nail-biter until the end.",
        "Junaid: Definitely. We should watch the next game together.",
        "Umer: Sounds like a plan!",
        "Junaid: Great, looking forward to it.",
        "Umer: Me too!"
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupTable()
       }
    
    @IBAction func Back(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func setupTable()
    {
        tble.delegate = self
        tble.dataSource = self
        tble.separatorStyle = .none
    }
    

    func setup(){
        
        
        // Create a tap gesture recognizer
               let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(textFieldTapped))
        Outlettextmsg.addGestureRecognizer(tapGestureRecognizer)
        Outlettextmsg.isUserInteractionEnabled = true
        
        
        // Create a tap gesture recognizer for the view
               let KeyboardRecognizer = UITapGestureRecognizer(target: self, action: #selector(hidekeyboard))
               view.addGestureRecognizer(KeyboardRecognizer)
                                         
       
           NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        
           NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
       deinit {
           // Unregister from keyboard notifications
           NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
           NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
       }
    
    
    @objc func hidekeyboard() {
            print("hidind keybioard tapped")
        self.view.endEditing(true)
        }
    
    @objc func textFieldTapped() {
            print("Text field tapped")
        Outlettextmsg.becomeFirstResponder()
        }
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
           if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
               // Debugging: Log keyboard size
               print("Keyboard Size: \(keyboardSize)")
               
               // Update the bottom constraint by the height of the keyboard
               bottomConstraint.constant = keyboardSize.height+110
            TableBottom_Constraints.constant = keyboardSize.height+50
               // Debugging: Log bottom constraint value
               print("Bottom Constraint (Keyboard Will Show): \(bottomConstraint.constant)")
               
               UIView.animate(withDuration: 0.3, animations: {
                   self.view.layoutIfNeeded()
               })
           }
       }
       
       @objc func keyboardWillHide(notification: NSNotification) {
           // Reset the bottom constraint
           bottomConstraint.constant = 50
        TableBottom_Constraints.constant = 90
           
           // Debugging: Log bottom constraint reset
           print("Bottom Constraint (Keyboard Will Hide): \(bottomConstraint.constant)")
           
           UIView.animate(withDuration: 0.3, animations: {
               self.view.layoutIfNeeded()
           })
       }

    
    //MARK:-
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return messages.count
       }

    
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "c1", for: indexPath) as! Chat_GroupTableViewCell
        
        let messageHeight = heightForMessage(messages[indexPath.row]) // Calculate height of the message
            
        
        if indexPath.row % 2 == 0{
            
            cell.lblMsg.text = messages[indexPath.row]
            cell.msgView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 1, alpha: 0.5)
            cell.msgViewLeadingConstraints.constant = 80
            cell.msgViewTrailingConstraints.constant = -10
          
        }
       
        else{
            cell.lblMsg.text = messages[indexPath.row]
            cell.msgView.backgroundColor = UIColor.init(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.5)
            cell.msgViewLeadingConstraints.constant = -10
            cell.msgViewTrailingConstraints.constant = -20
            
            
        }
        cell.msgView.frame.size.height = messageHeight+20
       
        
            return cell
       }
    
    func heightForMessage(_ message: String) -> CGFloat {
        let width = UIScreen.main.bounds.width - 20 // Adjust the width as needed
        let font = UIFont.systemFont(ofSize: 17) // Adjust the font as needed
        let maxSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let textSize = message.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(textSize.height) + 20 // Add padding as needed
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    

}
