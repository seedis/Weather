//
//  WeatherViewController.swift
//  Created by Looke on 2017/11/27.
//  Copyright © 2017年 Looke. All rights reserved.
//

import UIKit
import Foundation
import SwiftyJSON
import CoreLocation
import CoreData
import Alamofire
import SnapKit
import CHIPageControl

class WeatherViewController: UIViewController{
    var error=false
    var errrorMessage=""
    var count=4
    static var pageIndex=0
    static let shared=WeatherViewController()
    var compeletion:(_ num:Int)->()={_ in }
    /// 失败回调
    var failure: () -> () = {}
    var page: CHIPageControlJalapeno = {
        let page = CHIPageControlJalapeno()
        page.numberOfPages = dataArray?.count ?? 0
        page.tintColor = cellColor
        page.currentPageTintColor = UIColor.white
        page.radius = 4
        // 初始位置
        page.progress = 0
        return page
    }()
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: ScreenWidth, height: ScreenHeight)
        layout.scrollDirection = .horizontal
        let collectionViewFrame = CGRect(x: 0, y:0, width: ScreenWidth, height: ScreenHeight)
        let collectionView = UICollectionView(frame: collectionViewFrame, collectionViewLayout: layout)
        collectionView.bounces = false
        collectionView.isPagingEnabled = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator=false
        collectionView.showsVerticalScrollIndicator=false
        collectionView.backgroundColor=myColor
        
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: WeatherDataNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: deleteDataNotificationName, object: nil)
self.navigationItem.backBarButtonItem=UIBarButtonItem(title:"",style:.plain,target:self,action:nil)
        self.navigationItem.title="娜娜天气"
        
        self.view.addSubview(collectionView)
        
         collectionView.register(UINib(nibName: "WeatherViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "WeatherViewCell")
        
        self.navigationController?.view.addSubview(page)
        
        //添加 page 约束
        page.snp.makeConstraints({ make in
            make.top.equalTo((self.navigationController?.navigationBar.frame.height)!-5)
            make.centerX.equalTo((self.navigationController?.view)!)
            make.width.equalTo(100)
            make.height.equalTo(35)
        })
        
        WeatherService.shared.delegate=self
        
        // 若是 push 则添加边缘手势
        if (self.navigationController?.childViewControllers.count)! > 1 {
            DrawerViewController.shared?.addScreenEdgePanGestureRecognizerToView(view: self.collectionView)
        }
}
    // MARK: 收到通知后 更新UI
    @objc private func updateUI() {
        // 更新数据
        DispatchQueue.main.async {
            self.navigationItem.title=dataArray![Int(self.page.progress)].city
            // 设置分页控制器的 总数(当只有一页时不显示)
            let count = dataArray?.count ?? 0
            if count > 1 {
                self.page.numberOfPages = (dataArray?.count)!
            }
            else if count == 1 {
                self.page.numberOfPages = 0
            }
            else {
                // 若没有数据
                DrawerViewController.shared?.hideMenu()
                let vc = CitySelectViewController()
                vc.navigationItem.hidesBackButton = true
                self.navigationController?.pushViewController(vc, animated: false)
                return
            }
            self.collectionView.reloadData()
            let toast = Toast(title: "成功更新数据！", duration: 1.5)
            toast.show(in: self.view)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: UICollectionView 代理方法、数据源方法
extension WeatherViewController: UICollectionViewDelegate,UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let dataArr = dataArray else {
            return 1
        }
        if dataArr.count == 0 {
            return 1
        }
        return dataArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeatherViewCell", for: indexPath) as! WeatherViewCell
        
        guard let dataArray = dataArray else {
            cell.weatherData = Weather()
            return cell
        }
        if dataArray.count == 0 {
            cell.weatherData = Weather()
            return cell
        }
        cell.weatherData = dataArray[indexPath.row]
        return cell
    }
    
    // MARK: 滑动时更新数据
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 更新page
        let offset = scrollView.contentOffset.x + scrollView.frame.width * 0.5
        WeatherViewController.pageIndex = Int(offset / scrollView.frame.width)
        self.page.set(progress: WeatherViewController.pageIndex, animated: true)
        self.navigationItem.title=dataArray?[WeatherViewController.pageIndex].city
        // 当滑动到下一个item时 更新该item的数据
        //待实现
    }
    class func getPage(comeletion:@escaping (_ num:Int)->(),failure:@escaping ()->()={}){
        shared.compeletion=comeletion
        shared.failure=failure
        shared.compeletion(WeatherViewController.pageIndex)
    }
}

extension WeatherViewController:WeatherServiceDelegate{
    func getWeatherDataFailure() {
        // MARK: 更新数据失败
            DispatchQueue.main.async {
                let toast = Toast(title: "更新数据失败，请检查网络连接！", duration: 2.5)
                toast.show(in: self.view)
            }
        }
}



