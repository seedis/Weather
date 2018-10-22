//  AppDelegate.swift
//  Weather
//
//  Created by Looke on 2017/11/27.
//  Copyright © 2017年 Looke. All rights reserved.
//

import UIKit
import CoreData
import SwiftyJSON

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //.导航栏
//        启动页面延时加载
//        sleep(2)
        window = UIWindow(frame: ScreenBounds)
        window?.rootViewController = DrawerViewController(rootViewController: MainViewController(rootViewController: WeatherViewController()), menuViewController: MenuViewController())
        window?.makeKeyAndVisible()
        

        // 若第一次启动 定位获取城市 并请求数据
        LocationService.getCurrentCity(compeletion: { (location) in
            WeatherService.weatherData(location:location)
        })

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        /// 存储数据数组(数据持久化)
        if let dataArray = dataArray {
            if dataArray.count != 0 {
                let data=try?JSONEncoder().encode(dataArray) as NSData
                data?.write(toFile: dataArrPath, atomically: true)
                print("保存数据成功")
            }
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        /// 若有缓存数据 则更新数据
        let cacheJson=try?JSON(data:NSData(contentsOfFile:dataArrPath) as Data)
        if(cacheJson != nil){
            dataArray=try?JSONDecoder().decode([Weather].self,from: (cacheJson?.rawString()?.data(using: .utf8))!)
//            print("dataArray:\(dataArray?[0].current?.temperature?.value)")
        }
//        guard let latitude=dataArray?[0].latitude,let longitude=dataArray?[0].longitude else {
//            return
//        }
//        let location = CLLocation(latitude:latitude,longitude:longitude)
//        WeatherService.weatherData(location: location)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Weather")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

