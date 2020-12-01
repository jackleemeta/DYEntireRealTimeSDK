//
//  Data+DYAdd.swift
//  DYRealTimeSDKDemo
//
//  Created by beck tian on 2019/11/7.
//  Copyright © 2019 beck tian. All rights reserved.
//

public extension Data {
    
    var jsonString: String? {
        return String (data: self, encoding: .utf8)
    }
    
    var jsonObject: Any? {
        return try? JSONSerialization.jsonObject(with: self, options: .allowFragments)
    }
    
}
