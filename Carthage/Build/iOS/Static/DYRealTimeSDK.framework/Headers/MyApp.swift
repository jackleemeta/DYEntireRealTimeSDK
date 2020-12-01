//
//  MyApp.swift
//  DYRealTimeSDKDemo
//
//  Created by beck tian on 2019/10/30.
//  Copyright © 2019 beck tian. All rights reserved.
//


public class MyApp {
    
    ///获取包名
    public static var displayName: String {
        return infoDictionary["CFBundleDisplayName"] as! String
    }
    
    /// 获取包id
    public static var bundleId: String {
        return infoDictionary["CFBundleIdentifier"] as! String
    }
    
    /// 获取版本号
    public static var version: String {
        return majorVersion
    }
    
    /// 获取build号
    public static var build: String {
        return minorVersion
    }
    
    private static let infoDictionary = Bundle.main.infoDictionary!
    
    private static var majorVersion: String {
        return infoDictionary["CFBundleShortVersionString"]  as! String
    }
    
    private static var minorVersion: String {
        return infoDictionary["CFBundleVersion"]  as! String
    }
    
}
