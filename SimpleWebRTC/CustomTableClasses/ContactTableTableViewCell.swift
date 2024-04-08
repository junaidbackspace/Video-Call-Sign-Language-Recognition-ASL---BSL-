//
//  ContactTableTableViewCell.swift
//  SimpleWebRTC
//
//  Created by Umer Farooq on 06/02/2024.
//  Copyright © 2024 n0. All rights reserved.
//

import UIKit

class ContactTableTableViewCell: UITableViewCell {

    @IBOutlet weak var pin: UIImageView!
    @IBOutlet weak var mute: UIImageView!
    @IBOutlet weak var isActive: UIImageView!
    
    @IBOutlet weak var call: UIButton!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var about: UILabel!
    @IBOutlet weak var profilepic: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
