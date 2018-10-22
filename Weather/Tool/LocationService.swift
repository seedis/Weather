//
//  LocationService.swift
//  Weather
//
//  Created by Looke on 2017/12/3.
//  Copyright © 2017年 Looke. All rights reserved.
//

import Foundation
import CoreLocation

protocol locationServiceDelegate {
    func locationDidUpdate(location:CLLocation)
    func updateLocation(_ reGeocode: AMapLocationReGeocode)
}

class LocationService:NSObject{
    var delegate:locationServiceDelegate?
    var locationManager=AMapLocationManager()
//    单例
     static let shared = LocationService()
    /// 完成回调
    var compeletion: (_ locaton: CLLocation) -> () = {_ in }
    /// 失败回调
    var failure: () -> () = {}
    
    class func getCurrentCity(compeletion: @escaping (_ locaton: CLLocation) -> (), failure: @escaping () -> () = {}) {
        shared.compeletion = compeletion
        shared.failure = failure
        shared.setupManager()
    }
    
    private func setupManager() {
        locationManager.delegate = self
        // 定位精度
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        // api KEY
        AMapServices.shared().apiKey = "e68b4cb250a8320243828462dbfbbc4d"
        locationManager.locationTimeout=3
        locationManager.reGeocodeTimeout=3
        locationManager.requestLocation(withReGeocode: false, completionBlock: {[weak self](location: CLLocation?, reGeocode: AMapLocationReGeocode?, error: Error?) in
            if let error = error {
                let error = error as NSError
                if error.code == AMapLocationErrorCode.locateFailed.rawValue {
                    //定位错误：此时location和regeocode没有返回值，不进行annotation的添加
                    NSLog("定位错误:{\(error.code) - \(error.localizedDescription)};")
                    return
                }
                else if error.code == AMapLocationErrorCode.reGeocodeFailed.rawValue
                    || error.code == AMapLocationErrorCode.timeOut.rawValue
                    || error.code == AMapLocationErrorCode.cannotFindHost.rawValue
                    || error.code == AMapLocationErrorCode.badURL.rawValue
                    || error.code == AMapLocationErrorCode.notConnectedToInternet.rawValue
                    || error.code == AMapLocationErrorCode.cannotConnectToHost.rawValue {
                    
                    //逆地理错误：在带逆地理的单次定位中，逆地理过程可能发生错误，此时location有返回值，regeocode无返回值，进行annotation的添加
                    NSLog("逆地理错误:{\(error.code) - \(error.localizedDescription)};")
//                    let error=SWError(errorCode: .networkRequestFail)
//                    self?.delegate?.updateError(error: error)
                }
                else {
                    //没有错误：location有返回值，regeocode是否有返回值取决于是否进行逆地理操作，进行annotation的添加
                    }
            }
            if let location = location {
              // 回调
                self?.compeletion(location)
            }
        })
    }
}

extension LocationService:AMapLocationManagerDelegate{
    func amapLocationManager(_ manager: AMapLocationManager!, didUpdate location: CLLocation!) {
        if let location=location{
            print(location)
            self.delegate?.locationDidUpdate(location: location)
        }
    }
    func amapLocationManager(_ manager: AMapLocationManager!, didFailWithError error: Error!) {
        print("定位失败")
    }
}
