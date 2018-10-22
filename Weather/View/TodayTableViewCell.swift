//
//  TodayTableViewCell.swift
//  Weather
//
//  Created by Looke on 2017/12/25.
//  Copyright © 2017年 Looke. All rights reserved.
//

import UIKit

class TodayTableViewCell: UITableViewCell {
    @IBOutlet weak var aqi:UILabel!
    @IBOutlet weak var ultraviolet:UILabel!
    @IBOutlet weak var sunrise:UILabel!
    @IBOutlet weak var sundown:UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor=UIColor.clear
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
