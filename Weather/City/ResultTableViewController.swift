//  ResultTableViewController.swift
//  Created by Looke on 2017/12/15.
//  Copyright © 2017年 Looke. All rights reserved.

import UIKit

private let resultCell = "resultCell"

class ResultTableViewController: UITableViewController {
    
    var resultArray:[String] = []
    var isFrameChange = false
    /// 点击cell回调闭包
    var callBack: () -> () = {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 控制器根据所在界面的status bar，navigationbar，与tabbar的高度，不自动调整scrollview的 inset
        self.automaticallyAdjustsScrollViewInsets = false
        tableView.tableFooterView=UIView(frame:CGRect.zero)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: resultCell)
        tableView.separatorStyle = .none
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return resultArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: resultCell, for: indexPath)
        cell.textLabel?.text = resultArray[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        CitySelectViewController.selectCity=(cell?.textLabel?.text)!
        // 请求数据
        CitySelectViewController.getLocation(compeletion: { (location) in
            WeatherService.weatherData(location: location,isSelect : true)
        })
        callBack()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if isFrameChange == false {
            view.frame = CGRect(x: 0, y: (UIApplication.shared.statusBarFrame.height*3.2+30), width: ScreenWidth, height: ScreenHeight-30-UIApplication.shared.statusBarFrame.height*3.2)
            isFrameChange = true
        }

    }
}

