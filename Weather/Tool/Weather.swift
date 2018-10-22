//
//  Weather.swift
//  Weather
//
//  Created by Looke on 2017/11/30.
//  Copyright © 2017年 Looke. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreData
import HandyJSON
import ObjectMapper


class Weather:Codable{
    var city:String?
    var locateDis:String?
    var cityDetail:String?
    var latitude:Double?
    var longitude:Double?
    
    var hourly:Hourly?
    var minutely:Minutely?
    var daily:Daily?
    var realtime:Realtime?
    
    static func getWeekDay(_ index:Int)->String{
        let interval = Int(Date.timeIntervalSinceReferenceDate+Date.timeIntervalBetween1970AndReferenceDate)+TimeZone.current.secondsFromGMT()
        let days = Int(interval/86400) // 24*60*60
        let weekday = ((days + 4)%7+7)%7
        switch (weekday+index)%7 {
        case 0:return "周日"
        case 1:return "周一"
        case 2:return "周二"
        case 3:return "周三"
        case 4:return "周四"
        case 5:return "周五"
        case 6:return "周六"
        default:
            return ""
        }
    }
    static func windLevel(_ value:Double)->String{
        switch value{
        case 0..<0.3: return "0级"
        case 0.3..<1.5:return "1级"
        case 1.5..<3.4:return "2级"
        case 3.4..<5.5:return "3级"
        case 5.5..<8.0: return "4级"
        case 8.0..<10.8:return "5级"
        case 10.8..<13.9:return "6级"
        case 13.9..<17.2:return "7级"
        case 17.2..<20.8:return "8级"
        case 20.8..<24.5:return "9级"
        case 24.5..<28.5:return "10级"
        case 28.5..<32.7:return "11级"
        case 32.7...36.9:return "12级"
        default:
            return "12级以上"
        }
    }
    
    static func weatherIcon(_ value:String) -> String{
        switch value {
        case "CLEAR_DAY":return "晴天"
        case "CLEAR_NIGHT":return "晴夜"
        case "PARTLY_CLOUDY_DAY":return "多云"
        case "PARTLY_CLOUDY_NIGHT":return "多云"
        case "CLOUDY":return "阴"
        case "RAIN":return "雨"
        case "SNOW":return "雪"
        case "WIND":return "风"
        case "FOG":return "雾"
        case "HAZE":return "霾"
        case "SLEET":return "冻雨"
         
        case "0":return "晴"
        case "1":return "多云"
        case "2":return "阴"
        case "3":return "阵雨"
        case "4":return "雷阵雨"
        case "5":return "雷阵雨并伴有冰雹"
        case "6":return "雨夹雪"
        case "7":return "小雨"
        case "8":return "中雨"
        case "9":return "大雨"
        case "10":return "暴雨"
        case "11":return "大暴雨"
        case "12":return "特大暴雨"
        case "13":return "阵雪"
        case "14":return "小雪"
        case "15":return "中雪"
        case "16":return "大雪"
        case "17":return "暴雪"
        case "18":return "雾"
        case "19":return "冻雨"
        case "20":return "沙尘暴"
        case "21":return "小雨-中雨"
        case "22":return "中雨-大雨"
        case "23":return "大雨-暴雨"
        case "24":return "暴雨-大暴雨"
        case "25":return "大暴雨-特大暴雨"
        case "26":return "小雪-中雪"
        case "27":return "中雪-大雪"
        case "28":return "大雪-暴雪"
        case "29":return "浮沉"
        case "30":return "扬沙"
        case "31":return "强沙尘暴"
        case "32":return "飑"
        case "33":return "龙卷风"
        case "34":return "若高吹雪"
        case "35":return "轻雾"
        case "53":return "霾"
        case "无数据":return ""
        default:
            return "未知"
        }
    }
    static  func getHour(_ value:Int) -> String{
        let dateFormatter=DateFormatter()
        dateFormatter.dateFormat="HH"
        var hour=Int(dateFormatter.string(from: Date()))!
        hour = (hour + value) % 24
        return "\(hour):00"
    }
    static func getDate(_ value:Int) -> String{
        let formatter=DateFormatter()
        formatter.dateFormat="  MM/dd"
        let interval = value*24*60*60
        var  date=Array(formatter.string(from:Date(timeIntervalSince1970:TimeInterval(Date.timeIntervalSinceReferenceDate+Date.timeIntervalBetween1970AndReferenceDate+Double(interval)))))
        if(date[2]=="0"){date.remove(at: 2)}
        if(date[4]=="0"){date.remove(at: 4)}
        return String(date)
    }
    
    static func getChinaDate(_ value:Int) -> String{
        let formatter=DateFormatter()
        formatter.locale=Locale(identifier:"zh_CN")
        formatter.calendar = Calendar.init(identifier: .chinese)
        formatter.dateStyle = .medium
        let interval = value*24*60*60
        let dateString = formatter.string(from:Date(timeIntervalSince1970:TimeInterval(Date.timeIntervalSinceReferenceDate+Date.timeIntervalBetween1970AndReferenceDate+Double(interval))))
        return String(dateString[dateString.index(dateString.startIndex, offsetBy: 5)...])
    }
    
    static func getAqiLevel(_ value:Int) -> String{
        switch value{
            case 0...50:return "优"
            case 51...100:return "良"
            case 101...150:return "轻度污染"
            case 151...200:return "中度污染"
            case 201...300:return "重度污染"
            default:
            return "重度污染"
        }
    }
}

///////////////////////////////
////////////Realtime///////////
///////////////////////////////
class Realtime:Codable{
    var status:String?
    var temperature:Double?
    var skycon:String?
    var cloudrate:Double?
    var aqi:Int?
    var humidity:Double?
    var pres:Double?
    var pm25:Int?
    var precipitation:PrecipitationDaily?
    var wind:WindHourly?
}


///////////////////////////////
///////////////Hourly//////////
///////////////////////////////
class Hourly:Codable{
    var status:String?
    var description:String?
    var skycon:[SkyconHourly]?
    var clouddrate:[CloudrateHourly]?
    var aqi:[AqiHourly]?
    var humidity:[HumidityHourly]?
    var pres:[PresHourly]?
    var pm25:[Pm25Hourly]?
    var precipitation:[PrecipitationHourly]?
    var wind:[WindHourly]?
    var temperature:[TemperatureHourly]?
}
///////////////////////////////
////////Minutely///////////////
///////////////////////////////
class Minutely:Codable{
    var status:String?
    var description:String?
    var probability:[Double]?
    var datasource:String?
    var precipitation_2h:[Double]?
    var precipitation:[Double]?
}

///////////////////////////////
/////////Daily/////////////////
///////////////////////////////
class Daily:Codable{
    var status:String?
    var coldRisk:[ColdRisk]?
    var temperature:[TemperatureDaily]?
    var skycon:[SkyconDaily]?
    var cloudrate:[CloudrateDaily]?
    var aqi:[AqiDaily]?
    var humidity:[HumidityDaily]?
    var astro:[Astro]?
    var pres:[PresDaily]?
    var ultraviolet:[Ultraviolet]?
    var pm25:[Pm25Daily]?
    var dressing:[Dressing]?
    var carWashing:[CarWashing]?
    var precipitation:[PrecipitationDaily]?
    var wind:[WindDaily]?
    var desc:[Desc]?
    var primary:Int?
}

class SkyconHourly:Codable{
    var value:String?
    var datetime:String?
}
class SkyconDaily:Codable{
    var value:String?
    var date:String?
}
class CloudrateHourly:Codable{
    var value:Double?
    var datetime:String?
}
class CloudrateDaily:Codable{
    var date:String?
    var max:Double?
    var avg:Double?
    var min:Double?
}
class  AqiHourly:Codable{
    var value:Int?
    var datetime:String?
}
class  AqiDaily:Codable{
    var date:String?
    var max:Double?
    var avg:Double?
    var min:Double?
}
class HumidityHourly:Codable{
    var value:Double?
    var datetime:String?
}
class HumidityDaily:Codable{
    var date:String?
    var max:Double?
    var avg:Double?
    var min:Double?
}
class PresHourly:Codable{
    var value:Double?
    var datetime:String?
}
class PresDaily:Codable{
    var date:String?
    var max:Double?
    var avg:Double?
    var min:Double?
}
class  Pm25Hourly:Codable{
    var value:Int?
    var datetime:String?
}
class  Pm25Daily:Codable{
    var date:String?
    var max:Double?
    var avg:Double?
    var min:Double?
}
class PrecipitationHourly:Codable{
    var value:Double?
    var datetime:String?
}
class PrecipitationDaily:Codable{
    var date:String?
    var max:Double?
    var avg:Double?
    var min:Double?
    var nearest:Nearest?
    var local:Local?
}
class PrecipitationRealtime:Codable{

    var nearest:Nearest?
    var local:Local?
}
class Nearest:Codable{
    var staus:String?
    var distance:Double?
    var intensity:Double?
}
class Local:Codable{
    var staus:String?
    var intensity:Double?
    var datasource:String?
}
class WindHourly:Codable{
    var datetime:String?
    var direction:Double?
    var speed:Double?
}
class WindDaily:Codable{
    var max:Max?
    var avg:Avg?
    var min:Min?
    var date:String?
}
class Desc:Codable{
    var date:String?
    var value:String?
}
class WindCurrent:Codable{
    var direction:Double?
    var speed:Double?
}
class Max:Codable{
    var direction:Double?
    var speed:Double?
}
class Avg:Codable{
    var direction:Double?
    var speed:Double?
}
class Min:Codable{
    var direction:Double?
    var speed:Double?
}
class TemperatureHourly:Codable{
    var value:Double?
    var datetime:String?
}
class TemperatureDaily:Codable{
    var date:String?
    var max:Double?
    var avg:Double?
    var min:Double?
}
class ColdRisk:Codable{
    var index:String?
    var desc:String?
    var datetime:String?
}
class Astro:Codable{
    var datetime:String?
    var sunset:Sunset?
    var sunrise:Sunrise?
    var date:String?
}
class Sunset:Codable{
    var time:String?
}
class Sunrise:Codable{
    var time:String?
}
class Ultraviolet:Codable{
    var index:String?
    var desc:String?
    var datetime:String?
}
class Dressing:Codable{
    var index:String?
    var desc:String?
    var datetime:String?
}
class CarWashing:Codable{
    var index:String?
    var desc:String?
    var datetime:String?
}


