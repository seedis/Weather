//  MyCitiesTableViewCell.swift
//  Created by Looke on 2017/12/15.
//  Copyright © 2017年 Looke. All rights reserved.
//  抽屉菜单视图控制

import UIKit

class MyCitiesTableViewCell: UITableViewCell {

    /// 温度标签
    @IBOutlet weak var tempLabel: UILabel!
    /// 天气图标
    @IBOutlet weak var weatherIcon: UIImageView!
    /// 天气标签
    @IBOutlet weak var weatherLabel: UILabel!
    /// 城市标签
    @IBOutlet weak var cityLabel: UILabel!
    /// 详细温度标签
    @IBOutlet weak var detailLabel: UILabel!
    /// 数据
    var weatherData: Weather? {
        didSet {
            tempLabel.text = "\(Int(weatherData?.realtime?.temperature ?? 0))°"
            weatherLabel.text = Weather.weatherIcon(weatherData?.realtime?.skycon ?? "")
            cityLabel.text = weatherData?.locateDis ?? weatherData?.city ?? ""
            weatherIcon.image=UIImage(named:(weatherData?.daily?.skycon![0].value ?? "未知"))
            detailLabel.text = "\(Int(weatherData?.daily?.temperature![0].min ?? 0))℃ - \(Int(weatherData?.daily?.temperature![0].max ?? 0))℃"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        self.backgroundView = UIImageView(image: UIImage(named: "bg"))
//        self.selectedBackgroundView = UIImageView(image: UIImage(named: "bg"))
        self.backgroundView = UIImageView(image:MainViewController.getImageWithColor(color:myColor))
              self.backgroundView = UIImageView(image:MainViewController.getImageWithColor(color:myColor))
        
        self.backgroundColor = UIColor.clear
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // 遍历cell的subviews 自定义左滑删除btn
        for view in subviews {
            view.backgroundColor = UIColor.clear
            if view.isKind(of: NSClassFromString("UITableViewCellDeleteConfirmationView")!) {
                for btn in view.subviews {
                    if btn is UIButton {
                        (btn as! UIButton).setBackgroundImage(MainViewController.getImageWithColor(color:myColor), for: .normal)
                        (btn as! UIButton).backgroundColor = UIColor.clear
                    }
                }
            }
        }
    }
}
