//
//  TIMKit.swift
//  RealTimeDemo
//
//  Created by beck tian on 2019/12/4.
//  Copyright © 2019 beck tian. All rights reserved.
//

import ImSDK
import CocoaLumberjack

class TIMKit: NSObject {
    
    let instance = TIMManager.sharedInstance()
    
    weak var delegate: DYRealTimeSDKSignalKitProtocol?
    
    private var appId: UInt32
    private var roomId: String
    private var account: String
    
    private let sign: String
    
    private let param = TIMLoginParam()
    
    init(appId: UInt32,
         roomId: String,
         account: String,
         sign: String) {
        self.appId = appId
        self.roomId = roomId
        self.account = account
        self.sign = sign
        super.init()
        param.identifier = account
        param.userSig = sign
        
        initSDK()
    }
    
    deinit {
        DDLogDebug("TIMKit Deinit")
    }
    
    func getLogPath() -> String {
        return instance?.getLogPath() ?? ""
    }
    
    //初始化IM SDK
    func initSDK() {
        
        let sdkConfig = TIMSdkConfig()
        sdkConfig.sdkAppId = Int32(appId)
        sdkConfig.connListener = self
        
        //userStatusListener
        let userConfig = TIMUserConfig()
        userConfig.userStatusListener = self
        
        instance?.initSdk(sdkConfig)
        instance?.setUserConfig(userConfig)
        instance?.add(self)//TIMMessageListener
    }
    
    //登录
    func login() {
        instance?.login(param, succ: { [weak self] in
            guard let `self` = self else { return }
            self.delegate?.signalOnLoginSuccess(uid: self.account)
            }, fail: { [weak self] _, _ in
                guard let `self` = self else { return }
                self.delegate?.signalOnLoginFailed(uid: self.account, reason: .sign_failed)
        })
    }
    
    //发送消息
    func sendMessage(msgID: String, msg: String, receiverIds: Set<String>) {
       
        let message = TIMMessage()
        let elem = TIMTextElem()
        elem.text = msg
        message.add(elem)
        
        for receiverId in receiverIds {
            let con = instance?.getConversation(.C2C, receiver: receiverId)
            con?.sendOnlineMessage(message, succ: { [weak self] in
                guard let `self` = self else { return }
                self.delegate?.signalOnSendMessageSuccess(uid: receiverId, msgId: msgID, msg: msg)
            }, fail: { [weak self] _, _ in
                guard let `self` = self else { return }
                self.delegate?.signalOnSendMessageFailed(uid: receiverId, msgId: msgID, msg: msg)
            })
        }

    }
    
    //退出登录
    func logout() {
        let status = instance?.getLoginStatus()
        
        if status == .STATUS_LOGINED || status == .STATUS_LOGINING {
            instance?.logout({ [weak self] in
                guard let `self` = self else { return }
                self.delegate?.signalOnExit(uid: self.account, reason: .voluntary)
                }, fail: nil)
        }
        
    }
    
}

extension TIMKit: TIMMessageListener {
    //新消息回调通知
    func onNewMessage(_ msgs: [Any]) {
        guard let messages = msgs as? [TIMMessage] else { return }
        for item in messages {
            if item.isSelf() { continue }
            processMessage(message: item)
        }
    }
    
    private func processMessage(message: TIMMessage) {
        let sender = message.sender() ?? ""//消息的发送方
        let count = message.elemCount()
        for i in 0..<count {
            if let elem = message.getElem(i) as? TIMTextElem {
                parseMsgId(sender: sender, msg: elem.text)
            }
        }
    }
    
    private func parseMsgId(sender: String, msg: String?) {

        guard let msg = msg else { return }
        
        guard let parsedDataTuple = DYRealTimeSDKDataParser.instance.parseMSGID_UID_ROOMIDFor(message: msg) else { return }
        
        guard let msgId = parsedDataTuple.msgId else { return }
        guard let roomId = parsedDataTuple.roomId else { return }
        guard roomId == self.roomId else { return }
        
        delegate?.signalOnMessageReceived(uid: sender, msgId: msgId, msg: msg)
    }
}

//系统消息
extension TIMKit: TIMUserStatusListener {
    //踢下线通知
    func onForceOffline() {
        delegate?.signalOnExit(uid: account, reason: .extrusion)
    }
    
    //断线重连失败
    func onReConnFailed(_ code: Int32, err: String?) {
        delegate?.signalOnExit(uid: account, reason: .reconnect_failed)
        delegate?.signalOnError(err: err ?? "")
    }
    
    //用户登录的userSig过期（用户需要重新获取userSig后登录）
    func onUserSigExpired() {
        delegate?.signalOnExit(uid: account, reason: .sign_expired)
    }
}

extension TIMKit: TIMConnListener {
    
    func onConnecting() {
        let connecting = DYRealTimeSDKConnectStatus.connecting
        delegate?.signalOnConnectStatus(status: connecting, message: "TIM\(connecting.rawValue)")
    }
    
    func onConnSucc() {
        let succeed = DYRealTimeSDKConnectStatus.succeed
        delegate?.signalOnConnectStatus(status: succeed, message: "TIM\(succeed.rawValue)")
    }
    
    func onConnFailed(_ code: Int32, err: String?) {
        let failed = DYRealTimeSDKConnectStatus.failed
        delegate?.signalOnConnectStatus(status: failed, message: "TIM\(failed.rawValue)")
        delegate?.signalOnError(err: err ?? "")
    }
    
    func onDisconnect(_ code: Int32, err: String?) {
        let disconnected = DYRealTimeSDKConnectStatus.disconnected
        delegate?.signalOnConnectStatus(status: disconnected, message: "TIM\(disconnected.rawValue)")
        delegate?.signalOnError(err: err ?? "")
    }
    
}
