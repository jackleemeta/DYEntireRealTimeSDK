//
//  DYRealTimeSDK+MYAdd.swift
//  DYRealTimeSDK
//
//  Created by beck tian on 2019/12/16.
//  Copyright © 2019 beck tian. All rights reserved.
//

import CocoaLumberjack

let DYMQTTTopicTypeFlag: UnsafeRawPointer! = UnsafeRawPointer(bitPattern: "DYMQTTTopicTypeFlag".hashValue)

/// Internal Invoke Method - Common
extension DYRealTimeSDK {
    
    // 生成Manager
    func generateManager(sdk: DYRealTimeSDKType, authenticationConfig: DYRealTimeSDKAuthenticationConfig, userConfig: DYRealTimeSDKUserConfig, delegate: DYRealTimeSDKProtocol) -> DYRealTimeManager? {
        
        DYRealTimeSDKActionLog.sdk = sdk
        
        let manager: DYRealTimeManager?
        switch sdk {
        case .agora:
            manager = AgoraManager(sdk: sdk,
                                   authenticationConfig: authenticationConfig,
                                   userConfig: userConfig,
                                   delegate: delegate)
        case .trtc:
            manager = TRTCManager(sdk: sdk,
                                  authenticationConfig: authenticationConfig,
                                  userConfig: userConfig,
                                  delegate: delegate)
        default: manager = nil
        }
        
        manager?.extrusionCallBack = { [weak self] in
            guard let `self` = self else { return }
            self.leaveRoom()
        }
        
        return manager
    }
    
    func flameout(_ callBack: ((Bool)->())? = nil) {
        disconnectMQTT()
        leaveTIMKit()
        
        let manager = Self.manager
        manager?.destroy { isSuccess in
            callBack?(isSuccess)
            if manager == Self.manager {//Self.manager未重新指向，手动Self.manager指向nil; Self.manager重新指向，原manager destroy回调后自动释放
                Self.manager = nil
            }
        }
    }
    
}

