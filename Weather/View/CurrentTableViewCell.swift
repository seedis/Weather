//
//  CurrentTableViewCell.swift
//  Weather
//
//  Created by Looke on 2017/12/25.
//  Copyright © 2017年 Looke. All rights reserved.
//

import UIKit

class CurrentTableViewCell: UITableViewCell {
    @IBOutlet weak var cloudrate:UILabel!
    @IBOutlet weak var humidity:UILabel!
    @IBOutlet weak var pressure:UILabel!
    @IBOutlet weak var wind:UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor=UIColor.clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
