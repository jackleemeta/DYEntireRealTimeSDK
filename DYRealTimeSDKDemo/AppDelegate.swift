//
//  AppDelegate.swift
//  DYRealTimeSDKDemo
//
//  Created by beck tian on 2019/12/15.
//  Copyright © 2019 beck tian. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow.init(frame: UIScreen.main.bounds)
        window?.rootViewController = ViewController()
        window?.makeKeyAndVisible()//makeKeyAndVisible不对window强引用
        
        return true
    }

}

