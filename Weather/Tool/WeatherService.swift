//
//  WeatherService.swift
//  Weather
//
//  Created by Looke on 2017/12/1.
//  Copyright © 2017年 Looke. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreLocation
import Alamofire

protocol WeatherServiceDelegate: NSObjectProtocol {
    func getWeatherDataFailure()
}
class WeatherService{
    var locateCity:String?
    var locateDis:String?
    var locateCityDetail:String?
    var selectCity:String?
    var latitude:Double?
    var longitude:Double?
    /// 创建单例
    static let shared = WeatherService()
    /// 代理
    weak var delegate:WeatherServiceDelegate?
    let weatherJson=try?JSON(data:NSData(contentsOfFile:Bundle.main.path(forResource: "weather", ofType: "json")!) as Data)
    
    class func weatherData(location: CLLocation, isUpdateData: Bool = false,isSelect:Bool=false) {
        self.shared.retrieveWeatherInfo(location: location, isUpdateData: isUpdateData,isSelect:isSelect)
    }

    private func retrieveWeatherInfo(location: CLLocation, isUpdateData: Bool = false,isSelect: Bool=false){
        var dict=[String:Any]()
        var dictDaily:[String:Any]?
        var flag:Int=0{
            didSet{
                if(flag == 2)
                {
                let json=JSON(dict)
                    let weatherData=try?JSONDecoder().decode(Weather.self,from:(json.rawString()?.data(using: .utf8))!)
                // 全局数据数组增加数据
                self.dataArrayaddData(data: weatherData!, isUpdateData: isUpdateData,isSelect:isSelect)
                // 数据请求完毕后 发送通知
                NotificationCenter.default.post(name: WeatherDataNotificationName, object: nil, userInfo: nil)
                }
            }
        }
        var overFlag:Bool=false{
            didSet{
                let sessionConfig=URLSessionConfiguration.default
                let session=URLSession(configuration:sessionConfig)
                guard let url2=URL(string:"https://api.caiyunapp.com/v2/cTPSa3N7LRcKo9j3/\(location.coordinate.longitude),\(location.coordinate.latitude)/forecast.json?dailysteps=15") else {
                    self.delegate?.getWeatherDataFailure()
                    return
                }
                guard let url1=URL(string:"https://api.caiyunapp.com/v2/cTPSa3N7LRcKo9j3/\(location.coordinate.longitude),\(location.coordinate.latitude)/realtime") else {
                    self.delegate?.getWeatherDataFailure()
                    return
                }
             
                print(url1)
                 print(url2)
                let task1=session.dataTask(with:url1,completionHandler:{(data,response,error) in
                    guard error==nil else{
                        self.delegate?.getWeatherDataFailure()
                        return
                    }
                    guard let data=data else{
                        self.delegate?.getWeatherDataFailure()
                        return
                    }
                    guard let json=try?JSON(data:data) else{
                        self.delegate?.getWeatherDataFailure()
                        return
                    }
                    dict["realtime"]=json["result"].dictionaryObject! as [String:Any]
                    if isSelect==true{
                        dict["city"]=self.selectCity
                        dict["cityDetail"]=""
                    }
                    else{
                        
                        dict["city"]=self.locateCity
                        dict["cityDetail"]=self.locateCityDetail
                        dict["locateDis"]=self.locateDis
                    }
                    dict["latitude"]=self.latitude
                    dict["longitude"]=self.longitude
                    flag=flag+1
                })
                
                let task2=session.dataTask(with:url2,completionHandler:{(data,response,error) in
                    guard error==nil else{
                        self.delegate?.getWeatherDataFailure()
                        return
                    }
                    guard let data=data else{
                        self.delegate?.getWeatherDataFailure()
                        return
                    }
                    guard let json=try?JSON(data:data) else{
                        self.delegate?.getWeatherDataFailure()
                        return
                    }
                    dictDaily=json["result"].dictionaryObject! as [String:Any]
                    for (key,value) in dictDaily! as [String:Any]{
                        dict[key]=value
                    }
                    flag=flag+1
                })
                task1.resume()
                task2.resume()
            }
        }
        self.latitude=location.coordinate.latitude
        self.longitude=location.coordinate.longitude
        let url1=URL(string:"http://restapi.amap.com/v3/geocode/regeo?key=63e16fab15277c54c9c476f659b4c54e&location=\(location.coordinate.longitude),\(location.coordinate.latitude)")
        Alamofire.request(url1!,method: .get).responseJSON(completionHandler: {
            response in
            guard let json=try?JSON(data:response.data!) else{
                self.delegate?.getWeatherDataFailure()
                return
            }
            self.locateCityDetail=(json["regeocode"]["addressComponent"]["neighborhood"]["name"].string != nil ? json["regeocode"]["addressComponent"]["neighborhood"]["name"].string!:((json["regeocode"]["addressComponent"]["streetNumber"]["street"].string != nil && json["regeocode"]["addressComponent"]["streetNumber"]["number"].string != nil) ? (json["regeocode"]["addressComponent"]["streetNumber"]["street"].string!+json["regeocode"]["addressComponent"]["streetNumber"]["number"].string!):"未知区域")) == "未知区域" ? ((json["regeocode"]["addressComponent"]["township"].string != nil) ? json["regeocode"]["addressComponent"]["township"].string!:"未知区域"):(json["regeocode"]["addressComponent"]["neighborhood"]["name"].string != nil ? json["regeocode"]["addressComponent"]["neighborhood"]["name"].string!:((json["regeocode"]["addressComponent"]["streetNumber"]["street"].string != nil && json["regeocode"]["addressComponent"]["streetNumber"]["number"].string != nil) ? (json["regeocode"]["addressComponent"]["streetNumber"]["street"].string!+json["regeocode"]["addressComponent"]["streetNumber"]["number"].string!):"未知区域"))
            self.locateCity=(json["regeocode"]["addressComponent"]["country"].string != nil && json["regeocode"]["addressComponent"]["province"].string != nil) ? json["regeocode"]["addressComponent"]["province"].string!+(json["regeocode"]["addressComponent"]["city"].string != nil ? json["regeocode"]["addressComponent"]["city"].string!:"")+(json["regeocode"]["addressComponent"]["district"].string != nil ? json["regeocode"]["addressComponent"]["district"].string!:""): "未知区域"
             self.selectCity=json["regeocode"]["addressComponent"]["city"].string ?? json["regeocode"]["addressComponent"]["province"].string ?? "未知区域"
            overFlag=self.locateCity !=  "未知区域" ? true:false
            self.locateDis=json["regeocode"]["addressComponent"]["district"].string ??  json["regeocode"]["addressComponent"]["city"].string ?? "未区区域"
    
           
        })
        //openstreetmap逆地理转换
        let urlBack=URL(string:"http://nominatim.openstreetmap.org/reverse?format=json&lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&zoom=18&addressdetails=1")
        Alamofire.request(urlBack!,method: .get).responseJSON(completionHandler: {
            response in
            let json=JSON(response.data!)
            self.locateCity=(self.locateCity == "未知区域") ? (( json["address"]["state"] != "null") ? "\(json["address"]["state"])":"未知区域"):self.locateCity
            self.locateCityDetail=(self.locateCityDetail == "未知区域") ? ((json["address"]["county"] != "null" && json["address"]["road"] != "null") ? "\(json["address"]["road"]) \(json["address"]["county"])":"未知区域"):self.locateCityDetail
            self.locateDis=(self.locateDis == "未知区域") ? "\(json["address"]["city"]))":self.locateDis
//             overFlag=self.locateCity !=  "未知区域" ? true:false
        })
    }
    // MARK: 全局数据数组增加数据
    private func dataArrayaddData(data: Weather, isUpdateData: Bool = false,isSelect:Bool=false) {
        guard var dataArr = dataArray else {
            // 若 dataArray为空 则初始化数组 并添加数据
            dataArray = []
            dataArray?.append(data)
            return
        }
//        print("\(dataArr)")
        
        //若是定位信息有更新，则更新首页天气数据
//        print("isSelect B:\(isSelect)")
        if isSelect == false {
            dataArr[0]=data
            dataArray=dataArr
            //缓存最新数据
            let data=try?JSONEncoder().encode(dataArray) as NSData
            data?.write(toFile: dataArrPath, atomically: true)
            return
        }
        //选择城市数据更新，若有重复城市，则更新并替换该城市天气数据
        for i in 1..<dataArr.count {
            if data.city == dataArr[i].city{
                dataArr[i]=data
                dataArray=dataArr
                //缓存最新数据
                let data=try?JSONEncoder().encode(dataArray) as NSData
                data?.write(toFile: dataArrPath, atomically: true)
                return
            }
        }
        dataArr.insert(data, at: dataArr.count)
        dataArray = dataArr
        
        if dataArr.count != 0 {
            let data=try?JSONEncoder().encode(dataArray) as NSData
            data?.write(toFile: dataArrPath, atomically: true)
            print("保存数据成功")
        }
    }
}


