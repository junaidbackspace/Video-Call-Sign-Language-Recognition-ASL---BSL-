//
//  ChatScreenViewController.swift
//  CommFusion
//
//  Created by Umer Farooq on 30/05/2024.
//  Copyright © 2024 n0. All rights reserved.
//

import UIKit

class ChatScreenViewController: UIViewController {

    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var Outlettextmsg : UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
       }

    func setup(){
        // Create a tap gesture recognizer
               let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(textFieldTapped))
        Outlettextmsg.addGestureRecognizer(tapGestureRecognizer)
        Outlettextmsg.isUserInteractionEnabled = true
        
        // Register for keyboard notifications
           NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
           NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
       deinit {
           // Unregister from keyboard notifications
           NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
           NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
       }
    
    
    @objc func textFieldTapped() {
            print("Text field tapped")
        Outlettextmsg.becomeFirstResponder()
        }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            // Update the bottom constraint by the height of the keyboard
            bottomConstraint.constant = keyboardSize.height
            
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        // Reset the bottom constraint
        bottomConstraint.constant = 0
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
    }


}
