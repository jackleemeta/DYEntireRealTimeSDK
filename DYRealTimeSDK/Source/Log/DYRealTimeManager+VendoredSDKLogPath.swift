//
//  DYRealTimeManager+VendoredSDKLogPath.swift
//  DYRealTimeSDKDemo
//
//  Created by beck tian on 2019/12/18.
//  Copyright © 2019 beck tian. All rights reserved.
//

import Device
import CocoaLumberjack

//腾讯sdk/声网sdk log
extension DYRealTimeManager {
    
    //获取 DDLogFileInfo
    public class var sortedAgoraLogFileInfos: [DDLogFileInfo]? {
        var isDirectory: ObjCBool = true
        let fileManager: FileManager = .default
        
        var logDirectory = cachePath
        
        if self is AgoraManager.Type {
            logDirectory.append(agoraLogs)
        } else {
            logDirectory.append(trtcLogs)
        }
        
        if !(fileManager.fileExists(atPath: logDirectory, isDirectory: &isDirectory) && isDirectory.boolValue) { return nil }
        
        guard let filePathArray = try? fileManager.contentsOfDirectory(atPath: logDirectory) else { return nil }
        
        guard filePathArray.count > 0 else { return nil }
        
        var fileInfoArray = [DDLogFileInfo]()
        filePathArray.forEach { path in
            let fileFullPath = logDirectory.appending("/\(path)")
            let fileInfo = DDLogFileInfo(filePath: fileFullPath)
            fileInfoArray.append(fileInfo)
        }
        return fileInfoArray
    }
    
    /// agora日志路径
    class var agoraLogFilePath: String {
        var basePath = cachePath
        
        let directoryName = agoraLogs//文件名
        
        basePath.append(directoryName)
        
        let fileManager: FileManager = .default
        var isDirectory: ObjCBool = true
        if !(fileManager.fileExists(atPath: basePath, isDirectory: &isDirectory) && isDirectory.boolValue) {
            _ = try? fileManager.createDirectory(atPath: basePath, withIntermediateDirectories: true, attributes: nil)
        }
        
        let fileName =  "/" + getLogFileName() + ".log"//文件名
        basePath.append(fileName)
        return basePath
    }
    
    /// trtcl日志路径
    class var trtcLogFilePath: String {
        var basePath = cachePath
        
        let directoryName = trtcLogs //文件夹名
        
        basePath.append(directoryName)
        
        let fileManager: FileManager = .default
        var isDirectory: ObjCBool = true
        if !(fileManager.fileExists(atPath: basePath, isDirectory: &isDirectory) && isDirectory.boolValue) {
            _ = try? fileManager.createDirectory(atPath: basePath, withIntermediateDirectories: true, attributes: nil)
        }
        return basePath
    }
    
    //定义logFileName
    private class func getLogFileName() -> String {
        let now = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyy_MM_dd"
        format.timeZone = TimeZone(identifier: "Asia/Shanghai")
        let beijingtime =  format.string(from: now)
        let temp = Device.isPad() ? "_iPad" : "_iPhone"
        let fileName = "Agora_" + MyApp.bundleId + temp + "_v\(MyApp.version)" + "_\(beijingtime)"
        return fileName
    }
    
    /// cachePath
    private class var cachePath: String {
        return NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
    }
    
    private class var agoraLogs: String {
        return "/agoraLogs"
    }
    
    private class var trtcLogs: String {
        return "/trtcLogs"
    }
    
    
}
