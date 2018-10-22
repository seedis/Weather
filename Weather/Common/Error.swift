//
//  Error.swift
//  Weather
//
//  Created by Looke on 2017/12/6.
//  Copyright © 2017年 Looke. All rights reserved.
//

import Foundation

struct SWError{
    let errorCode:Code
    enum Code:Int{
        case urlError                =           3001
        case networkRequestFail      =           3002
        case jsonparsingfail         =           3003
        case jsonSerialization       =           3004
        case locationError           =           3005
    }
}
