//
//  SWCollectionViewCell.swift
//  Weather
//
//  Created by Looke on 2017/12/26.
//  Copyright © 2017年 Looke. All rights reserved.
//

import UIKit
import MJRefresh

class WeatherViewCell: UICollectionViewCell,UITableViewDataSource,UITableViewDelegate{
    //声明
     let tableView=UITableView(frame:CGRect(x:0,y:0,width:UIScreen.main.bounds.size.width,height:UIScreen.main.bounds.size.height-3.2*UIApplication.shared.statusBarFrame.height),style: .plain)
    let header=MJRefreshNormalHeader()
    var error=false
    var errrorMessage=""
    var weatherData:Weather?{
        didSet{
            self.tableView.reloadData()
        }
    }
    //函数体
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    private func setupUI() {
        tableView.backgroundColor=UIColor.clear
        //TableView 设置
        self.addSubview(tableView)
        tableView.delegate=self
        tableView.dataSource=self
        tableView.allowsSelection = false
        tableView.showsVerticalScrollIndicator=false
        tableView.register(UINib(nibName:"HourTableViewCell",bundle:Bundle.main), forCellReuseIdentifier: "Hours")
        tableView.register(UINib(nibName:"LocationTableViewCell",bundle:Bundle.main), forCellReuseIdentifier: "Location")
//        tableView.register(UINib(nibName:"CurrentTableViewCell",bundle:Bundle.main), forCellReuseIdentifier: "Current")
//        tableView.register(UINib(nibName:"TodayTableViewCell",bundle:Bundle.main), forCellReuseIdentifier: "Today")
        tableView.register(UINib(nibName:"FutureTableViewCell",bundle:Bundle.main), forCellReuseIdentifier: "Future")
        
        //        第三方组件 MJRefresh刷新天气
        header.setRefreshingTarget(self, refreshingAction:#selector(refreshData))
        self.tableView.mj_header=header
        self.tableView.tableFooterView=UIView(frame:CGRect.zero)
        self.tableView.separatorStyle = .none
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return  1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return  weatherData?.daily?.aqi?.count != nil ?  ((weatherData?.daily?.aqi?.count)!+2):2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row{
            /////////////首页天气//////////////////
        case 0:
            let cell=tableView.dequeueReusableCell(withIdentifier: "Location", for: indexPath) as! LocationTableViewCell

            cell.isIcon.image=weatherData?.cityDetail == "" ? UIImage(named:""):UIImage(named:"定位")
            cell.todayDate.text="\(Weather.getDate(indexPath.row)) \(Weather.getChinaDate(indexPath.row)) \(Weather.getWeekDay(indexPath.row))"
            cell.weatherImage.image=UIImage(named:(weatherData?.realtime?.skycon ?? "")!)
            cell.cityDetail.text=weatherData?.cityDetail ?? "无数据"
            cell.currentAqi.text="空气\(Weather.getAqiLevel(weatherData?.realtime?.aqi ?? 0))：\(weatherData?.realtime?.aqi ?? 0)"
            cell.currentWeather.text="当前：\(Int(weatherData?.realtime?.temperature ?? 0))° "+Weather.weatherIcon(weatherData?.realtime?.skycon ?? "")
            cell.todayDegree.text="\(Int(weatherData?.daily?.temperature![0].min ?? 0))℃"+" - "+"\(Int(weatherData?.daily?.temperature![0].max ?? 0))"+"℃"
            cell.desc.text=weatherData?.minutely?.description ?? ""
            cell.suggest.text=weatherData?.hourly?.description ?? ""
            let separate=UILabel(frame:CGRect(x:cell.frame.origin.x, y:cell.frame.size.height-0.5, width:cell.frame.size.width, height:0.5))
            separate.backgroundColor=UIColor.lightGray
            cell.addSubview(separate)
            return cell
        ///////////////未来24小时天气///////////////////
        case 1:
            let cell=tableView.dequeueReusableCell(withIdentifier: "Hours", for: indexPath) as! HourTableViewCell
            cell.weatherData=weatherData
            cell.hourCollectionViewCell.reloadData()
            let separate=UILabel(frame:CGRect(x:cell.frame.origin.x, y:cell.frame.size.height-0.5, width:cell.frame.size.width, height:0.5))
            separate.backgroundColor=UIColor.lightGray
            cell.addSubview(separate)
            return cell
        ////////////////////今日天气///////////////
//        case 2:
//            let cell=tableView.dequeueReusableCell(withIdentifier: "Current", for: indexPath) as! CurrentTableViewCell
//           cell.cloudrate.text="\(weatherData?.realtime?.cloudrate ?? 0)"
//            cell.pressure.text="\(String(format:"%.0f",(weatherData?.realtime?.pres ?? 0)/100))hPa"
//            cell.humidity.text="\(String(format:"%.0f",(weatherData?.realtime?.humidity ?? 0)*100))%"
//            let windValue=(weatherData?.realtime?.wind?.speed ?? 0)/3.6
//            cell.wind.text="\(String(format:"%.1f",windValue))m/s  |  \(Weather.windLevel(windValue))"

//            let separate=UILabel(frame:CGRect(x:cell.frame.origin.x, y:cell.frame.size.height-1, width:cell.frame.size.width , height:1))
//            separate.backgroundColor=UIColor.white
//            cell.addSubview(separate)
//            return cell
        //////////////当前天气信息//////////////////
//        case 3:
//            let cell=tableView.dequeueReusableCell(withIdentifier: "Today", for: indexPath) as! TodayTableViewCell
//            cell.aqi.text=weatherData?.realtime?.aqi != nil ? (Weather.getAqiLevel(Int((weatherData?.realtime?.aqi)!))):"无数据"
//            cell.ultraviolet.text=weatherData?.daily?.ultraviolet![0].desc
//            cell.sunrise.text=weatherData?.daily?.astro![0].sunrise?.time ?? "无数据"
//              cell.sundown.text=weatherData?.daily?.astro![0].sunset?.time ?? "无数据"
//
//            let separate=UILabel(frame:CGRect(x:cell.frame.origin.x, y:cell.frame.size.height-0.5, width:cell.frame.size.width, height:0.5))
//            separate.backgroundColor=UIColor.lightGray
//            cell.addSubview(separate)
//            return cell
        //////////////未来5或15天天气信息//////////////////
        default:
            let cell=tableView.dequeueReusableCell(withIdentifier: "Future", for: indexPath) as! FutureTableViewCell
            switch indexPath.row{
            case 2:
                cell.day.text=Weather.getWeekDay(indexPath.row-2)+"     今天"
            case 3:
                cell.day.text=Weather.getWeekDay(indexPath.row-2)+"     明天"
            default:
                cell.day.text=Weather.getWeekDay(indexPath.row-2)+"  "+Weather.getDate(indexPath.row-2)
            }
        cell.weatherImage.image=UIImage(named:(weatherData?.daily?.skycon![indexPath.row-2].value ?? "未知"))
        cell.min.text="\(Int(weatherData?.daily?.temperature![indexPath.row-2].min ?? 0))°"
        cell.max.text="\(Int(weatherData?.daily?.temperature![indexPath.row-2].max ?? 0))°"
//        cell.min.text="\(weatherData?.daily?.temperature![indexPath.row-4].min ?? 0)°"
//        cell.max.text="\(weatherData?.daily?.temperature![indexPath.row-4].max ?? 0)°"
        return cell
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return self.frame.height*1.8/3
        case 1:
            return self.frame.height*1/6
//        case 2:
//            return self.frame.height/7
//        case 3:
//            return self.frame.height/6
        default:
            return tableView.estimatedRowHeight
        }
    }
    @objc func refreshData(){
        WeatherViewController.getPage(comeletion: { (num) in
            //当刷新首页时，默认获取定位刷新天气
            if num == 0{
                LocationService.getCurrentCity(compeletion: { (location) in
                    WeatherService.weatherData(location: location)
                })
            }
            //否则刷新选择城市的天气
            else{
            WeatherService.weatherData(location: CLLocation(latitude:dataArray![num].latitude!,longitude:dataArray![num].longitude!),isSelect:true)
            }
        })
        sleep(2)
        self.tableView.mj_header.endRefreshing()
    }
   
}
