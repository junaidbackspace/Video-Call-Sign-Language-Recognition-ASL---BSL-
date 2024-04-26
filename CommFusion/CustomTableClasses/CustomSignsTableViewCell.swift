//
//  CustomSignsTableViewCell.swift
//  SimpleWebRTC
//
//  Created by Umer Farooq on 11/02/2024.
//  Copyright © 2024 n0. All rights reserved.
//

import UIKit

class CustomSignsTableViewCell: UITableViewCell {

    @IBOutlet weak var Approvalstatus: UIImageView!
    @IBOutlet weak var signtext: UILabel!
    @IBOutlet weak var signimg: UIImageView!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
