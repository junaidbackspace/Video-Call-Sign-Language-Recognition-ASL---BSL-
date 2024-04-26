//
//  FavoriteSignsTableViewCell.swift
//  SimpleWebRTC
//
//  Created by Umer Farooq on 10/02/2024.
//  Copyright © 2024 n0. All rights reserved.
//

import UIKit

class FavoriteSignsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var Category: UILabel!
    @IBOutlet weak var signtext: UILabel!
    @IBOutlet weak var btnfavorite: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
