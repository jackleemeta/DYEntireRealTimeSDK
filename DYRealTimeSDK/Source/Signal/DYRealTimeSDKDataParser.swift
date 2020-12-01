//
//  DYRealTimeSDKDataParser.swift
//  RealTimeDemo
//
//  Created by beck tian on 2020/7/3.
//  Copyright © 2020 beck tian. All rights reserved.
//

import Foundation

class DYRealTimeSDKDataParser {
    
    static let instance = DYRealTimeSDKDataParser()
    
    weak var delegage: DYRealTimeSDKProtocol?
    
    func parseMSGID_UID_ROOMIDFor(message: String) -> (msgId: String?, uid: String?, roomId: String?)? {
        return delegage?.parseMSGID_UID_ROOMIDFor(message: message)
    }
    
    func parseType(forMessage message: String) -> NSObject? {
        return delegage?.parseType(forMessage: message)
    }
    
    private init() { }
}
