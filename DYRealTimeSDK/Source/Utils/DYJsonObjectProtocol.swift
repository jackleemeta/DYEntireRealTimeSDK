//
//  DYJsonObjectProtocol.swift
//  DYRealTimeSDKDemo
//
//  Created by beck tian on 2019/11/7.
//  Copyright © 2019 beck tian. All rights reserved.
//

public protocol DYJsonObjectProtocol {}

public extension DYJsonObjectProtocol {
    
    var jsonString: String? {
        guard let jsonString = data?.jsonString else { return nil }
        return jsonString
    }
    
    var data: Data? {
        if (!JSONSerialization.isValidJSONObject(self)) {
            
            return nil
        }
        
        guard let data = try? JSONSerialization.data(withJSONObject: self, options: []) else { return nil }
        return data
    }
    
}
