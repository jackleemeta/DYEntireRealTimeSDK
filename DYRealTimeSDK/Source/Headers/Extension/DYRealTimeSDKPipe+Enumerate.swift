//
//  DYRealTimeSDKPipe+Enumerate.swift
//  DYRealTimeSDK
//
//  Created by diff on 2020/7/30.
//  Copyright © 2020 beck tian. All rights reserved.
//

extension DYRealTimeSDKPipe {
    
    func enumerate(_ callBack: @escaping (DYRealTimeSDKPipe) -> ()) {
        Self.inner_enumerate(self, callBack)
    }
    
    var describeString: String {
        switch self {
        case .mqtt: return "MQTT"
        case .tim: return "TIM"
        case .rtc: return "RTC"
        case .signal: return "信令"
        case .all: return "ALL"
        default: return "other"
        }
    }
    
    static func inner_enumerate(_ pipe: Self,
                                _ callBack: @escaping (DYRealTimeSDKPipe) -> ()) {
        var temp = pipe
        if temp.contains(.mqtt) {
            callBack(.mqtt)
            temp.subtract(.mqtt)
            inner_enumerate(temp, callBack)
        } else if temp.contains(.tim) {
            callBack(.tim)
            temp.subtract(.tim)
            inner_enumerate(temp, callBack)
        } else if temp.contains(.rtc) {
            callBack(.rtc)
            temp.subtract(.rtc)
            inner_enumerate(temp, callBack)
        } else if temp.contains(.signal) {
            callBack(.signal)
            temp.subtract(.signal)
            inner_enumerate(temp, callBack)
        }
    }
}
