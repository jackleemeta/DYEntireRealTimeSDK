//
//  DYRealTimeSDKActionLog+MYAdd+MYAdd.swift
//  DYRealTimeSDK
//
//  Created by beck tian on 2019/12/17.
//  Copyright © 2019 beck tian. All rights reserved.
//

import CocoaLumberjack

//双sdk行为日志
class DYSDKLogManager: DDLogFileManagerDefault {
    private let kDYLoggerFileNamePrefix = "Action_"
    override public var newLogFileName: String {
        get {
            let fileName = DYRealTimeSDKActionLog.fileName
            if fileName != nil {
                return fileName!
            }
            let now = Date()
            let format = DateFormatter.init()
            format.dateFormat = "yyyy_MM_dd"
            format.timeZone = TimeZone(identifier: "Asia/Shanghai")
            let timestamp = Int(now.timeIntervalSince1970)
            let beijingtime =  format.string(from: now)
            return kDYLoggerFileNamePrefix + MyApp.bundleId + "_v\(MyApp.version)" + "_\(beijingtime)" + "_\(timestamp)" + ".log"
        }
    }
    
    override public func isLogFile(withName fileName: String) -> Bool {
        let hasAppName = fileName.hasPrefix(kDYLoggerFileNamePrefix)
        let hasProperSuffix = fileName.hasSuffix(".log")
        return hasAppName && hasProperSuffix
    }
}

extension DYRealTimeSDKActionLog {
    
    class func dateString(date: Date, formatter: String) -> String {
        let dateFormatter        = DateFormatter()
        dateFormatter.dateFormat = formatter
        return dateFormatter.string(from: date)
    }
    
    class func log(actionName: String,
                   param: [String: Any]?,
                   type: String,
                   level: DDLogLevel = .all) {
        
        let content = param?.jsonString ?? ""
        
        let date = Date()
        var timestamp = Int64(date.timeIntervalSince1970 * 1000)
        
        if let offset = timeOffset {
            timestamp += Int64(offset)
        }
        
        let dateStr = dateString(date: date, formatter: "yyyy-MM-dd HH:mm:ss")
        
        let sdkName: String
        
        if sdk == .agora {
            sdkName = "声网系"
        } else {
            sdkName = "腾讯系"
        }
        
        var elements = ["【\(dateStr)】",
            "【\(type)】",
            "【\(sdkName)】",
            "【App版本 = \(MyApp.version)】",
            "【\(actionName)】",
            "【\(timestamp)】"]
        
        if content.count > 0 {
            elements.append("【参数 = \(content)】")
        }
        
        let elementsString = elements.joined(separator: ",")
        
        let messageStr = "\n" + elementsString + "\n"
        
        let message = DDLogMessage(message: messageStr, level: level, flag: .info, context: 0, file: "", function: "", line: 0, tag: nil, options: [.copyFile, .copyFunction], timestamp: Date())
        
        fileLogger?.loggerQueue.async {
            fileLogger?.log(message: message)
        }
    }
    
    class func type(ofAction action: String) -> String {
        let type: String
        if action.contains("失败") ||
            action.contains("失去") ||
            action.contains("错误") ||
            action.contains("断开"){
            type = "ERROR"
        } else {
            type = "NORMAL"
        }
        return type
    }
    
    private static var manager: DYSDKLogManager? = {
        let filePath = DYRealTimeSDKActionLog.filePath
        if filePath != nil {
            let mString  = (filePath! as NSString)
            let lastPathComponent = mString.lastPathComponent
            let deletingLastPathComponent = mString.deletingLastPathComponent
            DYRealTimeSDKActionLog.fileName = lastPathComponent
            let manager = DYSDKLogManager(logsDirectory: deletingLastPathComponent)
            return manager
        }
        
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        let basedir = paths.first ?? ""
        let logDirectory = (basedir as NSString).appendingPathComponent("actionLogs")
        return DYSDKLogManager(logsDirectory: logDirectory)
    }()
    
    static var fileLogger: DDFileLogger? = {
        guard let manager = manager else { return nil }
        let fileLogger = DDFileLogger(logFileManager: manager)
        fileLogger.logFormatter = nil
        return fileLogger
    }()
    
}
