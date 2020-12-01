//
//  DYRealTimeSDKActionLog.swift
//  RealTimeDemo
//
//  Created by 88 on 2017/6/6.
//  Copyright © 2017年 DT. All rights reserved.
//

import CocoaLumberjack

//事件类型
enum DYRealTimeSDKActionName: String {
    
    case video_set_local_video = "本地视频绑定view"
    case video_video_frame_first = "第一个视频帧Size解析成功"
    case video_remote_video_decode_first = "第一个远程视频帧解码成功"
    case video_muted = "视频静默"
    
    case video_enabled = "远程用户video可用与否"
    case audio_quality = "音频质量"
    case audio_restarted = "音频重启"
    case audio_audioMixingFinishedCallBack = "混音完成"
    
    case network_quality = "实时网络质量监测"
    
    case joinchannel = "加入房间"
    case joinchannel_success = "加入房间成功"
    case joinchannel_falilure = "加入房间失败"
    case rejoinchannel = "重新加入房间"
    
    case exitchannel = "退出房间"
    case exitchannel_success = "退出房间成功"
    case exitchannel_failure = "退出房间失败"
    case exitchannel_excrusion = "被挤出房间"
    case exitchannel_offline = "掉线离开房间"
    
    case message_send = "发送消息"
    case message_send_success = "发送自定义消息成功"
    case message_send_failure = "发送自定义消息失败"
    case message_received = "收到自定义消息"
    
    case connect_connecting = "网络正在连接"
    case connect_succeed = "网络已连接"
    case connect_failed = "网络连接失败"
    case connect_disconnected = "网络连接断开"
    case connect_recovery = "网络连接已恢复"
    
    case occur_warning = "出现警告"
    case occur_error = "出现错误"
    
    case `default` = "默认"
}

public class DYRealTimeSDKActionLog {
    
    public static var timeOffset: Int64?
    public static var sdk: DYRealTimeSDKType?
    static var filePath: String?
    static var fileName: String?
    
    /// 获取日志路径
    class var ddFileLogger: DDFileLogger?  {
        return fileLogger
    }
    
    /// action 为ActionName枚举
    /// - Parameters:
    ///   - action: 事件名
    ///   - pipe: 通道：rtc signal mqtt
    ///   - param: 参数
    class func log(_ action: DYRealTimeSDKActionName, pipe: DYRealTimeSDKPipe, param: [String: Any]? = nil) {
        let pipeStr = pipe.describeString//rtc
        let actionStr = action.rawValue//加入房间
        let value = pipeStr + "-" + actionStr
        log(value, param, level(ofAction: action.rawValue))
    }
    
    class func ddLogInfo(_ message: @autoclosure () -> String,
                         level: DDLogLevel = DDDefaultLogLevel,
                         context: Int = 0,
                         file: StaticString = #file,
                         function: StaticString = #function,
                         line: UInt = #line,
                         tag: Any? = nil,
                         asynchronous async: Bool = asyncLoggingEnabled,
                         ddlog: DDLog = .sharedInstance) {
        
        let string: String
        if sdk == .agora {
            string = "【声网系】" + message()
        } else {
            string = "【腾讯系】" + message()
        }
        
        DDLogInfo(string, file:file, function: function, line: line)
    }
    
}
