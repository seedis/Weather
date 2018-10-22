//  header.swift
//  Created by Looke on 2017/12/15.
//  Copyright © 2017年 Looke. All rights reserved.

import Foundation
import UIKit

let ScreenWidth: CGFloat = UIScreen.main.bounds.size.width
let ScreenHeight: CGFloat = UIScreen.main.bounds.size.height
let ScreenBounds: CGRect = UIScreen.main.bounds


/// document路径
let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
/// 天气数据路径
let dataArrPath = documentPath + "/dataArray.data"
/// 全局天气数据
//var dataArray: [Weather]?
var dataArray: [Weather]?=try?JSONDecoder().decode([Weather].self,from: NSData(contentsOfFile:dataArrPath) as Data)

/// 主配色
let mainColor = UIColor.color(hex: "#707070")
/// 浅灰 cell背景色
let cellColor = UIColor.color(hex: "#EAEAEA")

let myColor=UIColor.color(hex: "#1e3851")
/// btn 高亮背景色
let btnHighlightColor = UIColor.color(hex: "#efeff4")
/// btn 高亮图片
let btnHighlightImage = UIColor.creatImageWithColor(color: btnHighlightColor)

/// 主页指标btn Attributes
let btnAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17),NSAttributedStringKey.foregroundColor: mainColor]

/// section间距
let sectionMargin: CGFloat = 38

/// 热门城市btn
let btnMargin: CGFloat = 15
let btnWidth: CGFloat = (ScreenWidth - 90) / 3
let btnHeight: CGFloat = 36

/// 菜单栏宽度
let menuViewWidth = ScreenWidth*4/5
/// 菜单头部视图高度
let menuHeadViewHeight: CGFloat = ScreenHeight/11
/// 菜单栏我的城市cell高度
let myCitiesCellHeight: CGFloat = 95
/// 我的城市间距
let myCityMargin: CGFloat = 10

/// 请求数据完成通知
let WeatherDataNotificationName = Notification.Name(rawValue: "GetWeatherDataSuccessfuly")
/// 删除数据完成通知
let deleteDataNotificationName = NSNotification.Name(rawValue: "DeleteDataSuccessfuly")
let deleteDataNotificationWarn = NSNotification.Name(rawValue: "can't delete located city’")
/// 获取定位城市完成通知
let locateCityNotificationName = NSNotification.Name("locateCityNotificationName")
