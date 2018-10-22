//
//  WeatherViewCollectionViewCell.swift
//  Weather
//
//  Created by Looke on 2017/12/22.
//  Copyright © 2017年 Looke. All rights reserved.
//

import UIKit

class HourCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var degree: UILabel!
    @IBOutlet weak var weather: UIImageView!
    @IBOutlet weak var hour: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor=UIColor.clear
    }

}
