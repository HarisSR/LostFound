//
//  StuffTableViewCell.swift
//  LostFound
//
//  Created by Haris Shobaruddin Roabbni on 18/09/19.
//  Copyright © 2019 Haris Shobaruddin Robbani. All rights reserved.
//

import UIKit

class StuffTableViewCell: UITableViewCell {
    @IBOutlet weak var stuffImage: UIImageView!
    @IBOutlet weak var stuffName: UILabel!
    @IBOutlet weak var postDate: UILabel!
    @IBOutlet weak var currentlyIn: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
