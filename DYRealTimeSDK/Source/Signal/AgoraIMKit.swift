//
//  AgoraIMKit.swift
//  DYRealTimeSDKDemo
//
//  Created by beck tian on 2019/12/7.
//  Copyright © 2019 beck tian. All rights reserved.
//

import AgoraRtmKit
import CocoaLumberjack

class AgoraIMKit: NSObject {
    
    weak var delegate: DYRealTimeSDKSignalKitProtocol?
    
    private let id = DYRealTimeAppKeys.Agora.id
    
    var account = ""
    
    var roomId = ""
    
    private lazy var instance = AgoraRtmKit(appId: id, delegate: self)
    
    private lazy var room = instance?.createChannel(withId: roomId, delegate: self)

    deinit {
        instance?.destroyChannel(withId: roomId)
        DDLogDebug("AgoraSignalKit Deinit")
    }
    
    ///登录
    func login(token: String?) {
        instance?.login(byToken: token, user: account) { [weak self] code in
            guard let `self` = self else { return }
            if code == .ok {//去加入房间
                self.channelJoin()
            } else {//加入失败
                self.delegate?.signalOnLoginFailed(uid: self.account, reason: .ignore)
            }
        }
    }
    
    //登出
    func logout() {
        instance?.logout { [weak self] code in
            guard let `self` = self else { return }
            if code != .ok { return }
            self.delegate?.signalOnExit(uid: self.account, reason: .voluntary)
        }
    }
    
    //加入room
    func channelJoin() {
        room?.join { [weak self] code in
            guard let `self` = self else { return }
            if code == .channelErrorOk {
                self.delegate?.signalOnLoginSuccess(uid: self.account)
            } else {
                self.delegate?.signalOnLoginFailed(uid: self.account, reason: .ignore)
            }
        }
    }
    
    //离开room
    func channelLeave() {
        room?.leave { [weak self] code in
            guard let `self` = self else { return }
            if code != .ok { return }
            self.delegate?.signalOnExit(uid: self.account, reason: .ignore)
        }
    }
    
    //广播房间消息
    func messageChannelSend(channelID: String, msgId: String, msg: String) {
        let message = AgoraRtmMessage(text: msg)
        room?.send(message) { [weak self] code in
            guard let `self` = self else { return }
            if code == .errorOk {//消息发送成功
                self.delegate?.signalOnSendMessageSuccess(uid: "", msgId: msgId, msg: msg)
            } else {//消息发送失败
                self.delegate?.signalOnSendMessageFailed(uid: "", msgId: msgId, msg: msg)
            }
        }
    }
  
}

//MARK: - AgoraRtmDelegate
extension AgoraIMKit: AgoraRtmDelegate {
    
    func rtmKit(_ kit: AgoraRtmKit, connectionStateChanged state: AgoraRtmConnectionState, reason: AgoraRtmConnectionChangeReason) {
        let r: DYRealTimeSDKConnectStatus
        switch state {
        case .connecting:
            r = .connecting
        case .connected:
            r = .succeed
        case .disconnected:
            r = .disconnected
        case .reconnecting:
            r = .recovery
        case .aborted:
            r = .failed
        @unknown default: r = .failed
        }
        delegate?.signalOnConnectStatus(status: r, message: "信令\(r.rawValue)")
        
        switch reason {
        case .remoteLogin:
            delegate?.signalOnExit(uid: account, reason: .extrusion)
        default: break
        }
    }
    
    func rtmKitTokenDidExpire(_ kit: AgoraRtmKit) {
        delegate?.signalOnExit(uid: account, reason: .sign_expired)
    }
    
}

//MARK: - AgoraRtmChannelDelegate
extension AgoraIMKit: AgoraRtmChannelDelegate {
    
    ///用户加入
    func channel(_ channel: AgoraRtmChannel, memberJoined member: AgoraRtmMember) {
        delegate?.signalOnLoginSuccess(uid: member.userId)
    }
    
    ///用户离开
    func channel(_ channel: AgoraRtmChannel, memberLeft member: AgoraRtmMember) {
        delegate?.signalOnExit(uid: member.userId, reason: .ignore)
    }
    
    //收到消息
    func channel(_ channel: AgoraRtmChannel, messageReceived message: AgoraRtmMessage, from member: AgoraRtmMember) {
        delegate?.signalOnMessageReceived(uid: member.userId, msgId: "", msg: message.text)
    }
    
}
