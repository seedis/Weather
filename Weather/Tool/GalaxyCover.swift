//  GalaxyCover.swift
//  Created by Looke on 2017/12/15.
//  Copyright © 2017年 Looke. All rights reserved.


import UIKit

class GalaxyCover: UIView {
    
    static let shared = GalaxyCover()
    
    var callBack: () -> () = {}
    
    enum background {
        case clear
        case gray
    }
    
    /// 显示蒙版
    ///
    /// - type: 蒙版类型 -（透明、灰色）（默认为透明）
    /// - clickCallBack: - 点击蒙版回调（默认为空）
    class func show(frame: CGRect, type: background = .gray, clickCallBack: @escaping () -> () = {} ) {
        
        shared.frame = frame
        switch type {
        case .clear:
            shared.backgroundColor = UIColor.clear
        case .gray:
            shared.backgroundColor = UIColor.black
            shared.alpha = 0.5
        }
        shared.callBack = clickCallBack
        UIApplication.shared.delegate?.window??.addSubview(shared)
    }
    
    class func hide() {
        shared.removeFromSuperview()
    }
    
    // MARK: 点击蒙版调用
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        callBack()
    }
    
    override func removeFromSuperview() {
        // 如果存在手势 则移除
        if let gestureRecognizers = GalaxyCover.shared.gestureRecognizers {
            for gesture in gestureRecognizers {
                GalaxyCover.shared.removeGestureRecognizer(gesture)
            }
            super.removeFromSuperview()
        }
    }
    
}
