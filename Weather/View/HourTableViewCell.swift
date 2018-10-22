//
//  HourTableViewCell.swift
//  Weather
//
//  Created by Looke on 2017/12/23.
//  Copyright © 2017年 Looke. All rights reserved.
//

import UIKit
import SwiftyJSON

class HourTableViewCell: UITableViewCell,UICollectionViewDelegate,UICollectionViewDataSource {

    @IBOutlet weak var hourCollectionViewCell: UICollectionView!
    var weatherData:Weather?
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 24
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier: "HourCollectionViewCell", for: indexPath) as! HourCollectionViewCell
        cell.hour.text=indexPath.row == 0 ? "现在":Weather.getHour(indexPath.row)
        cell.weather.image=indexPath.row == 0 ? UIImage(named:(weatherData?.realtime?.skycon ?? "")!):UIImage(named:(weatherData?.hourly?.skycon![indexPath.row].value ?? "未知"))
//        cell.degree.text="\(weatherData?.realtime?.temperature ?? 0)°"
        cell.degree.text=indexPath.row == 0 ? "\(String(format:"%.0f",weatherData?.realtime?.temperature ?? 0))°":"\(String(format:"%.0f",(weatherData?.hourly?.temperature![indexPath.row].value ?? 0)))°"
        return cell
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor=UIColor.clear
        
        // Initialization code
       
        hourCollectionViewCell.backgroundColor=UIColor.clear
        hourCollectionViewCell.dataSource=self
        hourCollectionViewCell.delegate=self
        hourCollectionViewCell.showsHorizontalScrollIndicator=false
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width:ScreenWidth/7, height: 100)
        layout.scrollDirection = .horizontal
        hourCollectionViewCell.collectionViewLayout = layout
      hourCollectionViewCell.register(UINib(nibName:"HourCollectionViewCell",bundle:Bundle.main), forCellWithReuseIdentifier: "HourCollectionViewCell")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
