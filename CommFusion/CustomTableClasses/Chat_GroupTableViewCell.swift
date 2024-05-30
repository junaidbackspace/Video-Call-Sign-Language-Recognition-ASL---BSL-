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
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
