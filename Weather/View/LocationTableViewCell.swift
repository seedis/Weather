//
//  LocationTableViewCell.swift
//  Weather
//
//  Created by Looke on 2017/12/24.
//  Copyright © 2017年 Looke. All rights reserved.
//

import UIKit

class LocationTableViewCell: UITableViewCell {
    @IBOutlet weak var cityDetail:UILabel!
    @IBOutlet weak var currentWeather:UILabel!
    @IBOutlet weak var weatherImage:UIImageView!
    @IBOutlet weak var desc:UILabel!
    @IBOutlet weak var suggest:UILabel!
    @IBOutlet weak var todayDegree:UILabel!
    @IBOutlet weak var todayDate:UILabel!
    @IBOutlet weak var currentAqi:UILabel!
    @IBOutlet weak var isIcon:UIImageView!
    

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
