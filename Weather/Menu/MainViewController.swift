//  MainViewController.swift
//  Created by Looke on 2017/12/7.
//  Copyright © 2017年 Looke. All rights reserved.

import UIKit

class MainViewController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor=UIColor.clear
        self.navigationController?.navigationBar.isTranslucent=true
        self.navigationBar.tintColor = UIColor.white
        self.navigationBar.titleTextAttributes = [NSAttributedStringKey(rawValue: "NSForegroundColorAttributeName"): UIColor.white]
        self.navigationBar.setBackgroundImage(MainViewController.getImageWithColor(color:myColor), for: .default)
        self.navigationBar.shadowImage=MainViewController.getImageWithColor(color:myColor)
        self.navigationBar.titleTextAttributes = {[
            NSAttributedStringKey.foregroundColor: UIColor.white
            ]}()
    }

   class func getImageWithColor(color:UIColor)->UIImage{
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
}



