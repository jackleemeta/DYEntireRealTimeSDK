//
//  String+DYAdd.swift
//  RealTimeDemo
//
//  Created by beck tian on 2019/12/4.
//  Copyright © 2019 beck tian. All rights reserved.
//

public extension String {
    var jsonData: Data? {
        return data(using: .utf8)
    }
    
    var jsonObject: Any? {
        guard let jsonData = jsonData else { return nil }
        return try? JSONSerialization.jsonObject(with: jsonData, options: .allowFragments)
    }
}
