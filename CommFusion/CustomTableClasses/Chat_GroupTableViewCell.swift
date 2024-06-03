//
//  Chat_GroupTableViewCell.swift
//  CommFusion
//
//  Created by Umer Farooq on 30/05/2024.
//  Copyright © 2024 n0. All rights reserved.
//

import UIKit

class Chat_GroupTableViewCell: UITableViewCell {
    
    @IBOutlet weak var msgViewLeadingConstraints: NSLayoutConstraint!
    @IBOutlet weak var msgViewTrailingConstraints: NSLayoutConstraint!
    
  
    @IBOutlet weak var msgView: UIView!
    @IBOutlet weak var lblMsg: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // Set accessibility properties
                lblMsg.isAccessibilityElement = true
                lblMsg.accessibilityLabel = lblMsg.text
                
                // Optional: If you want the entire customView to be accessible as well
        msgView.isAccessibilityElement = true
        msgView.accessibilityLabel = lblMsg.text
    }
    
    
    func configure(with message: String) {
        lblMsg.text = message
            // Update accessibilityLabel to reflect the new message
        lblMsg.accessibilityLabel = message
            
            // Optional: If customView is set as an accessibility element
        msgView.accessibilityLabel = message
        }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
