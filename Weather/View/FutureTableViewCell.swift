//
//  FutureTableViewCell.swift
//  Weather
//
//  Created by Looke on 2017/12/25.
//  Copyright © 2017年 Looke. All rights reserved.
//

import UIKit

class FutureTableViewCell: UITableViewCell {
    @IBOutlet  weak var day:UILabel!
    @IBOutlet  weak var weatherImage:UIImageView!
    @IBOutlet  weak var min:UILabel!
    @IBOutlet  weak var max:UILabel!

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
