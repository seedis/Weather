//  CitySelectViewController.swift
//  Created by Looke on 2017/12/15.
//  Copyright © 2017年 Looke. All rights reserved.


import UIKit
import Alamofire
import SwiftyJSON

private let nomalCell = "nomalCell"
private let hotCityCell = "hotCityCell"
private let recentCell = "rencentCityCell"
private let currentCell = "currentCityCell"

protocol locationSelectFinishDelegate {
     func locationSelectFinish(_ location:String)
}
class CitySelectViewController: UIViewController {
    var selectDelegate:locationSelectFinishDelegate?
    var cityDetail:String?

    var locateCity:String?{
        didSet{
            self.tableView.reloadData()
        }
    }
    static var selectCity:String?
    var delegate:WeatherServiceDelegate?
    ///单例
     static let shared = CitySelectViewController()
    /// 完成回调
    var compeletion: (_ location: CLLocation) -> () = {_ in }
    /// 失败回调
    var failure: () -> () = {}
    /// 表格
    lazy var tableView: UITableView = UITableView(frame: self.view.frame, style: .plain)
    /// 搜索控制器
    lazy var searchVC: UISearchController = {
        let searchVc = UISearchController(searchResultsController: self.searchResultVC)
        searchVc.delegate = self
        searchVc.searchResultsUpdater = self
        searchVc.view.backgroundColor=myColor
        searchVc.hidesNavigationBarDuringPresentation = false
        searchVc.definesPresentationContext = true
        searchVc.searchBar.frame = CGRect(x:0, y: 0, width: ScreenWidth*3/4, height: 44)
        searchVc.searchBar.placeholder = "输入城市名或拼音查询"
        searchVc.searchBar.delegate = self
        return searchVc
    }()
    /// 搜索结果控制器
    var searchResultVC : ResultTableViewController = ResultTableViewController()
    /// 懒加载 城市数据
    lazy var cityDic: [String: [String]] = { () -> [String : [String]] in
        let path = Bundle.main.path(forResource: "cities.plist", ofType: nil)
        let dic = NSDictionary(contentsOfFile: path ?? "") as? [String: [String]]
        return dic ?? [:]
    }()
    /// 懒加载 热门城市
    lazy var hotCities: [String] = {
        let path = Bundle.main.path(forResource: "hotCities.plist", ofType: nil)
        let array = NSArray(contentsOfFile: path ?? "") as? [String]
        return array ?? []
    }()
    /// 懒加载 标题数组
    lazy var titleArray: [String] = { () -> [String] in
        var array = [String]()
        for str in self.cityDic.keys {
            array.append(str)
        }
        // 标题排序
        array.sort()
        array.insert("热门", at: 0)
        array.insert("最近", at: 0)
        array.insert("当前", at: 0)
        return array
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        LocationService.getCurrentCity(compeletion:{ (location) in
           self.update(location)
        })
        // 设置UI
        setupUI()
    }
    private func setupUI() {
        self.title = "选择城市"
        self.navigationController?.navigationBar.tintColor=UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = {[
            NSAttributedStringKey.foregroundColor: UIColor.white,
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18)
            ]}()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.bounces = false
        tableView.tableHeaderView=searchVC.searchBar
        //设置搜索栏背景及颜色
        searchVC.searchBar.backgroundImage=MainViewController.getImageWithColor(color: myColor)
        searchVC.searchBar.tintColor=UIColor.white
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: nomalCell)
        tableView.register(RecentCitiesTableViewCell.self, forCellReuseIdentifier: recentCell)
        tableView.register(CurrentCityTableViewCell.self, forCellReuseIdentifier: currentCell)
        tableView.register(HotCityTableViewCell.self, forCellReuseIdentifier: hotCityCell)
        // 右边索引
        tableView.sectionIndexColor = myColor
        tableView.sectionIndexBackgroundColor = UIColor.clear
        tableView.separatorStyle = .none
        self.view.addSubview(tableView)
        
        let cityBtn = UIButton(type: .custom)
        cityBtn.setTitle("取消", for: .normal)
        cityBtn.setTitleColor(UIColor.gray, for: .normal)
        cityBtn.sizeToFit()
        cityBtn.addTarget(self, action: #selector(cancelSelect), for: .touchUpInside)
        self.view.addSubview(cityBtn)
        cityBtn.snp.makeConstraints { (make) in
            make.bottom.equalTo(-10)
            make.right.equalTo(-10)
            make.height.equalTo(20)
        }
    }
    @objc func cancelSelect(){
        self.dismiss(animated: true, completion: nil)
    }
    deinit {
//        print("我走了")
    }
    @objc func backToPrevious(){
        self.navigationController!.popViewController(animated: true)
    }
}

// MARK: UISearchResultsUpdating
extension CitySelectViewController: UISearchResultsUpdating, UISearchControllerDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        getSearchResultArray(searchBarText: searchController.searchBar.text ?? "")
    }
    func willPresentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.showsCancelButton = false
    }
    func presentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.showsCancelButton = false
    }
}

// MARK: searchBar 代理方法
extension CitySelectViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
}

// MARK: tableView 代理方法、数据源方法
extension CitySelectViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return titleArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section > 2 {
            let key = titleArray[section]
            return cityDic[key]!.count - 3
        }
        return 1
    }
    
    // MARK: 创建cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: currentCell, for: indexPath) as! CurrentCityTableViewCell
            cell.currentCity = locateCity
                cell.callBack = { [weak self] in
                    self?.navigationController?.pushViewController(WeatherViewController(), animated: true)
                    self?.dismiss(animated: true, completion: nil)
            }
            return cell
            
        }else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: recentCell, for: indexPath) as! RecentCitiesTableViewCell
            // 点击最近城市按钮调用此闭包
            cell.callBack = { [weak self] (btn) in
                // 请求数据
                CitySelectViewController.selectCity=btn.titleLabel?.text ?? "上海"
                CitySelectViewController.getLocation(compeletion: { (location) in
                WeatherService.weatherData(location: location,isSelect : true)
                })
                self?.navigationController?.pushViewController(WeatherViewController(), animated: true)
                self?.dismiss(animated: true, completion: nil)
            }
            return cell
        }else if indexPath.section == 2 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: hotCityCell, for: indexPath) as! HotCityTableViewCell
            
            // 点击热门城市按钮时调用此闭包
            cell.callBack = { [weak self] (btn) in
                cell.textLabel?.text=btn.titleLabel?.text
                CitySelectViewController.selectCity=((btn.titleLabel?.text)!)
                // 请求数据
                CitySelectViewController.getLocation(compeletion: { (location) in
                    WeatherService.weatherData(location: location,isSelect : true)
                })
                self?.navigationController?.pushViewController(WeatherViewController(), animated: true)
                self?.dismiss(animated: true, completion: nil)
            }
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: nomalCell, for: indexPath)
            //            cell.backgroundColor = cellColor
            let key = titleArray[indexPath.section]
            cell.textLabel?.text = cityDic[key]![indexPath.row]
            CitySelectViewController.selectCity = (cell.textLabel?.text)!
            return cell
        }
    }
    // MARK: 点击cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let cell = tableView.cellForRow(at: indexPath)
        if indexPath.section > 2 {
            /// 请求数据
            CitySelectViewController.selectCity=(cell?.textLabel?.text)!
            // 请求数据
            CitySelectViewController.getLocation(compeletion: { (location) in
                WeatherService.weatherData(location: location,isSelect : true)
            })
            self.navigationController?.pushViewController(WeatherViewController(), animated: true)
            self.dismiss(animated: true, completion: nil)
        }else {
            return
        }
    }
    
    // MARK: 右边索引
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return titleArray
    }
    
    // MARK: section头视图
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: sectionMargin))
        let title = UILabel(frame: CGRect(x: 15, y: 5, width: ScreenWidth - 15, height: 28))
        var titleArr = titleArray
        titleArr[0] = "当前定位城市"
        titleArr[1] = "最近选择城市"
        titleArr[2] = "热门城市"
        title.text = titleArr[section]
        title.textColor = UIColor.white
        title.font = UIFont.boldSystemFont(ofSize: 18)
        view.addSubview(title)
        view.backgroundColor = myColor
        if section > 2 {
            view.backgroundColor = myColor
            
            title.textColor = UIColor.white
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sectionMargin
    }
    
    // MARK: row高度
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return btnHeight + 2 * btnMargin
        }else if indexPath.section == 1 {
            return btnHeight + 2 * btnMargin
        }else if indexPath.section == 2 {
            let row = (hotCities.count - 1) / 3
            return (btnHeight + 2 * btnMargin) + (btnMargin + btnHeight) * CGFloat(row)
        }else{
            return 42
        }
    }
}

// MARK: 搜索逻辑
extension CitySelectViewController {
    fileprivate func getSearchResultArray(searchBarText: String) {
        var resultArray:[String] = []
        if searchBarText == "" {
            searchResultVC.resultArray = resultArray
            searchResultVC.tableView.reloadData()
            return
        }
        // 传递闭包 当点击’搜索结果‘的cell调用
        searchResultVC.callBack = { [weak self] in
            // 搜索完成 关闭resultVC
            self?.searchVC.isActive = false
            self?.navigationController?.pushViewController(WeatherViewController(), animated: true)
            self?.dismiss(animated: true, completion: nil)
        }
        // 中文搜索
        if searchBarText.isIncludeChineseIn() {
            // 转拼音
            let pinyin = searchBarText.chineseToPinyin()
            // 获取大写首字母
            let first = String(pinyin[pinyin.startIndex]).uppercased()
            guard let dic = cityDic[first] else {
                return
            }
            for str in dic {
                if str.hasPrefix(searchBarText) {
                    resultArray.append(str)
                }
            }
            searchResultVC.resultArray = resultArray
            searchResultVC.tableView.reloadData()
        }else {
            // 拼音搜索
            // 若字符个数为1
            if searchBarText.count == 1 {
                guard let dic = cityDic[searchBarText.uppercased()] else {
                    return
                }
                resultArray = dic
                searchResultVC.resultArray = resultArray
                searchResultVC.tableView.reloadData()
            }
            if searchBarText.count == 2 {
                guard let dic = cityDic[searchBarText.first().uppercased()] else {
                    return
                }
                for str in dic {
                    // 去空格
                    let py = String(str.chineseToPinyin().filter({ $0 != " "}))
                    let range = py.range(of: searchBarText)
                    if range != nil {
                        resultArray.append(str)
                    }
                }
                // 加入首字母判断 如 cq => 重庆 bj => 北京
                if resultArray.count == 0 {
                    for str in dic {
                        let pinyin = str.chineseToPinyin()
                        let a = pinyin.index(of: " ")
                        let index = pinyin.index(a!, offsetBy: 1)
                        let py = pinyin[...index]
                        let last = py[py.index(py.endIndex, offsetBy: -1)...]
                        let pyIndex = String(pinyin[pinyin.startIndex]) + last
                        if searchBarText.lowercased() == pyIndex {
                            resultArray.append(str)
                        }
                    }
                }
                searchResultVC.resultArray = resultArray
                searchResultVC.tableView.reloadData()
            }
//            城市全名拼音搜索
            else{
                let first = String(searchBarText[searchBarText.startIndex]).uppercased()
                guard let dic = cityDic[first] else {
                    return
                }
                for str in dic {
                    if str.chineseToPinyin().filter({ $0 != " "}).hasPrefix(searchBarText.lowercased()) {
                        resultArray.append(str)
                    }
                }
                searchResultVC.resultArray = resultArray
                searchResultVC.tableView.reloadData()
            }
        }
    }

func update(_ location:CLLocation){
    //高德地址 web api地理及逆地理转换
    let url=URL(string:"http://restapi.amap.com/v3/geocode/regeo?key=63e16fab15277c54c9c476f659b4c54e&location=\(location.coordinate.longitude),\(location.coordinate.latitude)")
    Alamofire.request(url!,method: .get).responseJSON(completionHandler: {
        response in
        let json=JSON(response.data!)
        self.locateCity=(json["regeocode"]["addressComponent"]["city"].string ?? json["regeocode"]["addressComponent"]["province"].string) ?? "未知区域"
    })
    //openstreetmap逆地理转换
    let urlBack=URL(string:"http://nominatim.openstreetmap.org/reverse?format=json&lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&zoom=18&addressdetails=1")
    Alamofire.request(urlBack!,method: .get).responseJSON(completionHandler: {
        response in
        let json=JSON(response.data!)
        self.locateCity=(self.locateCity == "未知区域") ? ((json["address"]["country"] != "null" && json["address"]["state"] != "null") ? "\(json["address"]["state"]) \(json["address"]["country"])":"未知区域"):self.locateCity
        self.cityDetail=(self.cityDetail == "未知区域") ? ((json["address"]["county"] != "null" && json["address"]["road"] != "null") ? "\(json["address"]["road"]) \(json["address"]["county"])":"未知区域"):self.cityDetail
        })
    }

    class func getLocation(compeletion: @escaping (_ location: CLLocation) -> (), failure: @escaping () -> () = {}) {
        shared.compeletion = compeletion
        shared.failure = failure
        shared.cityToLocation(CitySelectViewController.selectCity!)
    }
    func cityToLocation(_ city:String){
        let urlBack=URL(string:"http://restapi.amap.com/v3/geocode/geo?key=63e16fab15277c54c9c476f659b4c54e&address=\(city)".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
        Alamofire.request(urlBack!,method: .get).responseJSON(completionHandler: {
            response in
            guard let json=try?JSON(data:response.data!) else{
                self.delegate?.getWeatherDataFailure()
                return
            }
            guard let _ = json["geocodes"][0]["location"].string else{
                let toast = Toast(title: "选择城市信息异常", duration: 2)
                toast.show(in: self.view)
                return
            }
            let locations=json["geocodes"][0]["location"].string!.split(separator: ",")
            let selectLocation=CLLocation(latitude:Double(locations[1])!,longitude:Double(locations[0])!)
            self.compeletion(selectLocation)
        })
    }
}

extension CitySelectViewController:locationServiceDelegate{
    func locationDidUpdate(location: CLLocation) {
        DispatchQueue.main.async{
            self.update(location)
        }
    }
    
    func updateError() {
//         失败 弹出toast
        let toast = Toast(title: "定位失败", duration: 2)
        toast.show(in: self.view)
        return
    }
    func updateLocation(_ reGeocode: AMapLocationReGeocode) {
        
    }
}
extension CitySelectViewController:WeatherServiceDelegate{
    func getWeatherDataFailure() {
        let toast = Toast(title: "网络异常，请重试", duration: 2)
        toast.show(in: self.view)
        return
    }
}

