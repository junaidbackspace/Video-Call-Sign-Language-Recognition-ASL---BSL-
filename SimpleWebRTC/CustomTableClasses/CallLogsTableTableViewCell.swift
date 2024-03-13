//
//  CallLogsTableTableViewCell.swift
//  SimpleWebRTC
//
//  Created by Umer Farooq on 09/02/2024.
//  Copyright © 2024 n0. All rights reserved.
//

import UIKit

class CallLogsTableTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBOutlet weak var callStatus: UIImageView!
    @IBOutlet weak var isActive: UIImageView!
    
    @IBOutlet weak var call: UIButton!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var callTime: UILabel!
    @IBOutlet weak var profilepic: UIImageView!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
