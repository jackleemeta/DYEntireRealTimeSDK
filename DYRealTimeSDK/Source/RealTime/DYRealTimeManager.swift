//
//  DYRealTimeManager.swift
//  RealTimeDemo
//
//  Created by beck tian on 2019/12/2.
//  Copyright © 2019 beck tian. All rights reserved.
//


import CocoaLumberjack

enum JoinStatus {
    case joining //正在加入
    case joinSucceed //加入成功
    case joinFailed //加入失败
    case none
}

typealias DidLeaveCallBack = ((_ isSuccess: Bool)->())?

class DYRealTimeManager: NSObject {
    
    var didRtcLeaveCallBack: DidLeaveCallBack = nil
    
    var didMQTTLeaveCallBack: DidLeaveCallBack = nil
    
    var messgeTypeOfJoinRoom: NSObject?
    
    var messgeTypeOfLeftRoom: NSObject?
    
    var isHaveExtruded = false
        
    var sdkSwitchedBlock: ((Bool)->())?
    
    var extrusionCallBack: (()->())?
    
    var audioMixingFinishedCallBack: (()->())?
    
    var baseInformation: DYRealTimeSDKBaseInformation {
        return DYRealTimeSDKBaseInformation()
    }
    
    init(sdk: DYRealTimeSDKType, authenticationConfig: DYRealTimeSDKAuthenticationConfig, userConfig: DYRealTimeSDKUserConfig, delegate: DYRealTimeSDKProtocol) {
        super.init()
        self.userConfig = userConfig
        self.authenticationConfig = authenticationConfig
        self.delegate = delegate
        DYRealTimeSDKDataParser.instance.delegage = delegate
    }
    
    func engine() {
        connectSDK()
    }
    
    func reengine() {
        engine()
    }
    
    func sendMessage(msgId: String, msg: String, receiverIds: Set<String>? = nil) {
        log_sendRtcMessage(msgId: msgId, msg: msg, receiverIds: receiverIds)
    }
    
    func sendSignalMessage(msgId: String, msg: String, receiverIds: Set<String>? = nil) {
        log_sendSignalMessage(msgId: msgId, msg: msg, receiverIds: receiverIds)
    }
    
    func resetConfig(authConfig: DYRealTimeSDKAuthenticationConfig, userConfig: DYRealTimeSDKUserConfig) {
        self.authenticationConfig = authConfig
        self.userConfig = userConfig
        inRoomStatus = [String: Bool]()
        currentReceivedMsgs = Set<String>()
        currentDealedSentMsgs = Set<String>()
        currentSentMsgPipes = [String: DYRealTimeSDKPipe]()
        selfInitalJoinCondition = []
        isInitialing = true
        isHaveExtruded = false
    }
    
    func joinRoomDelayJudge() {
        let time: TimeInterval = 12
        DispatchQueue.main.asyncAfter(deadline: .now() + time) { [weak self] in
            guard let `self` = self else { return }
            let restSet = self.allPipesOfWillJoin.subtracting(self.selfInitalJoinCondition)
            restSet.enumerate { pipe in
                self.joinRoom_duplicateRemoval(isSuccess: false, uid: self.userConfig.account, pipe: pipe)
            }
        }
    }
    
    func leaveRoomDelayJudge() {
        let time: TimeInterval = 10
        DispatchQueue.main.asyncAfter(deadline: .now() + time) { [weak self] in
            guard let `self` = self else { return }
            self.didRtcLeaveCallBack?(false)
            self.didRtcLeaveCallBack = nil
        }
    }
    
    func sentMsgDelayJudge(msgId: String, msg: String) {
        let time: TimeInterval = 10
        DispatchQueue.main.asyncAfter(deadline: .now() + time) { [weak self] in
            guard let `self` = self else { return }
            if !self.currentDealedSentMsgs.contains(msgId) { // 还未处理过
                self.delegate?.sentMessage(isSuccess: false, uid: "", msgId: msgId, msg: msg)
                self.currentDealedSentMsgs.insert(msgId)
            }
        }
    }
    
    func switchSDK(_ isSuccess: Bool) {
        sdkSwitchedBlock?(isSuccess)
        sdkSwitchedBlock = nil
    }
    
    deinit {
        DDLogDebug("\(#file), \(#function)")
    }
    
    //MARK: - Private Method
    lazy var authenticationConfig = DYRealTimeSDKAuthenticationConfig()
    private(set) lazy var userConfig = DYRealTimeSDKUserConfig()
    private(set) weak var delegate: DYRealTimeSDKProtocol?
    
    private lazy var inRoomStatus = [String : Bool]()//[uid : isIn]
    
    private lazy var currentReceivedMsgs = Set<String>()//[msgId]
    
    private lazy var currentDealedSentMsgs = Set<String>()
    
    // 当前消息的可用通道
    lazy var allPipesBelongToCurrentMessage = [String: DYRealTimeSDKPipe]()
    
    // 消息已经发送成功的通道
    private lazy var currentSentMsgPipes = [String: DYRealTimeSDKPipe]()
    
    private lazy var selfInitalJoinCondition: DYRealTimeSDKPipe = []
        
    private var isInitialing: Bool = true
    
    //MARK: - Need Override
    func connectSDK() {}
    
    func joinRoom() {
        selfInitalJoinCondition = []
        isInitialing = true
        isHaveExtruded = false
        joinRoomDelayJudge()//加入Rtc房间延时判定
    }
    
    func joinRtcRoom() {
         log_tryToJoinRtcRoom()
    }
    
    func joinSignalRoom() {
        log_tryToJoinSignalRoom()
    }
    
    func leaveRoom(_ callBack: ((Bool)->())? = nil) {
       
    }
    
    func leaveRtcRoom() {
        log_tryToLeaveRtcRoom()
        leaveRoomDelayJudge()//离开Rtc房间延时判定
    }
    
    func leaveSignalRoom() {}
    
    func destroy(_ callBack: ((Bool)->())? = nil) {}
    
    func startAudioMixing(_ filePath: String!, loopback: Bool, replace: Bool, cycle: Int, finishedCallBack: (()->())?) {
        audioMixingFinishedCallBack = finishedCallBack
        log_startAudioMixing(filePath, loopback: loopback, replace: replace, cycle: cycle, finishedCallBack: finishedCallBack)
    }
    
    func stopAudioMixing() {
        log_stopAudioMixing()
    }
    
    func pauseAudioMixing() {
        log_pauseAudioMixing()
    }
    
    func resumeAudioMixing() {
        log_resumeAudioMixing()
    }
    
    func adjustAudioMixingVolume(_ volume: Int) {
        log_adjustAudioMixingVolume(volume)
    }
    
    func muteLocalVideoStream(_ mute: Bool) {
        log_muteLocalVideoStream(mute)
    }
    
    func muteLocalAudioStream(_ status: Bool) {
        log_muteLocalAudioStream(status)
    }
    
    func muteRemoteAudioStream(_ mute: Bool, userId:String) {
        log_muteRemoteAudioStream(mute: mute, userId: userId)
    }
    
    var allPipesOfWillJoin: DYRealTimeSDKPipe {
        return []
    }
    
    func processFurtherMessage(msgId: String, msg: String, receiverIds: Set<String>? = nil, pipe: DYRealTimeSDKPipe = .all) {
        // 消息加入去重队列
        var innerMsgId = ""
        if msgId.count > 0 {
            innerMsgId = msgId
        } else if let aTuple = DYRealTimeSDKDataParser.instance.delegage?.parseMSGID_UID_ROOMIDFor(message: msg), let msgId = aTuple.msgId {
            innerMsgId = msgId
        } else {
            return
        }
        currentReceivedMsgs.insert(innerMsgId)
        sentMsgDelayJudge(msgId: innerMsgId, msg: msg)
        
        allPipesBelongToCurrentMessage[innerMsgId] = pipe
    }
    
}

///中转处理
extension DYRealTimeManager {
    
    func sentMessage(isSuccess: Bool, uid: String, msgId: String, msg: String, pipe: DYRealTimeSDKPipe) {
        
        var innerMsgId = ""
        if msgId.count > 0 {
            innerMsgId = msgId
        } else if let aTuple = DYRealTimeSDKDataParser.instance.parseMSGID_UID_ROOMIDFor(message: msg), let msgId = aTuple.msgId {
            innerMsgId = msgId
        } else {
            return
        }
        
        if currentSentMsgPipes[innerMsgId] == nil {
            log_sentMessage(isSuccess: isSuccess, uid: uid, msgId: innerMsgId, msg: msg, pipe: pipe, isFirstSent: true)
            currentSentMsgPipes[innerMsgId] = [pipe]
        } else {
            log_sentMessage(isSuccess: isSuccess, uid: uid, msgId: innerMsgId, msg: msg, pipe: pipe, isFirstSent: false)
            currentSentMsgPipes[innerMsgId]?.formUnion(pipe)
        }
        
        if !currentDealedSentMsgs.contains(innerMsgId) {
            if isSuccess {
                delegate?.sentMessage(isSuccess: true, uid: uid, msgId: innerMsgId, msg: msg)
                currentDealedSentMsgs.insert(innerMsgId)
            } else if currentSentMsgPipes[innerMsgId] == allPipesBelongToCurrentMessage[innerMsgId] {
                delegate?.sentMessage(isSuccess: false, uid: uid, msgId: innerMsgId, msg: msg)
                currentDealedSentMsgs.insert(innerMsgId)
            }
        }
    }
    
    func viewForLocalVideo() -> UIView? {
        log_viewForLocalVideo()
        return delegate?.viewForLocalVideo()
    }
    
    func videoSizeParsed(uid: String) {
        delegate?.videoSizeParsed(uid: uid)
        log_firstVideoSizeParsedOfUid(uid: uid)
    }
    
    func viewForRemoteVideo(uid: String) -> UIView? {
        log_firstRemoteVideoDecodedOfUid(uid: uid)
        return delegate?.viewForRemoteVideo(uid: uid)
    }
    
    func userDidCloseVideo(uid: String, isMuted: Bool) {
        delegate?.userDidCloseVideo(uid: uid, isMuted: isMuted)
        log_userDidCloseVideo(uid: uid, isMuted: isMuted)
    }
    
    func onNetworkQuality(uid: String, quality: DYRealTimeSDKNetworkQuality) {
        delegate?.onNetworkQuality(uid: uid, quality: quality)
        log_onNetworkQuality(uid: uid, quality: quality)
    }
    
    func onConnectStatus(status: DYRealTimeSDKConnectStatus, message: String, pipe: DYRealTimeSDKPipe) {
        delegate?.onConnectStatus(status: status, message: message)
        log_onConnectStatus(status: status, message: message, pipe: pipe)
    }
    
    func audioRestarted() {
        delegate?.audioRestarted()
        log_audioRestarted()
    }
    
    func onError(code: String, message: String, pipe: DYRealTimeSDKPipe) {
        delegate?.onError(code: code, message: message)
        log_occur_error(code: code, pipe: pipe)
    }
    
}

//去重消息
extension DYRealTimeManager {
    
    /**
     加入房间成功或者失败去重
     */
    func joinRoom_duplicateRemoval(isSuccess: Bool, uid: String, pipe: DYRealTimeSDKPipe) {
        var isActuallyJoined = false
        if pipe == .rtc { //只记录rtc
            if inRoomStatus[uid] != isSuccess {
                inRoomStatus[uid] = isSuccess
                isActuallyJoined = true
            }
        }
        
        if uid == userConfig.account { // 本人
            if isInitialing {
                selfInitalJoinCondition.insert(pipe)
                if selfInitalJoinCondition == allPipesOfWillJoin { // 通道都已返回
                    isInitialing = false
                    let rtcSuccess = inRoomStatus[uid] ?? false
                    delegate?.joinRoom(isSuccess: rtcSuccess, uid: uid)
                    switchSDK(rtcSuccess)
                }
            } else {
                if isActuallyJoined {
                    delegate?.joinRoom(isSuccess: isSuccess, uid: uid)
                    switchSDK(isSuccess)
                }
            }
            
        } else if pipe == .rtc, isActuallyJoined {
            delegate?.joinRoom(isSuccess: isSuccess, uid: uid)
        }
        
        log_joinRoom(isSuccess: isSuccess, uid: uid, pipe: pipe)
    }
    
    /**
     离开房间成功去重
     */
    func leftRoom_duplicateRemoval(uid: String, reason: DYRealTimeSDKLeaveReason, pipe: DYRealTimeSDKPipe) {
        if uid == userConfig.account { // 本人
            if !isHaveExtruded { // 未被挤出
                if reason == .extrusion, (pipe == .signal || pipe == .tim) {
                    isHaveExtruded = true
                    inRoomStatus[uid] = false
                    extrusionCallBack?()
                    delegate?.leftRoom(uid: uid, reason: reason)
                }  else if pipe == .rtc, inRoomStatus[uid] == true {
                    delegate?.leftRoom(uid: uid, reason: reason)
                    inRoomStatus[uid] = false
                }
            }
        } else if pipe == .rtc, inRoomStatus[uid] == true {
            delegate?.leftRoom(uid: uid, reason: reason)
            inRoomStatus[uid] = false
        }
        
        log_leftRoom(uid: uid, reason: reason, pipe: pipe)
        
        if uid == userConfig.account { // 自身离开rtc房间
            if pipe == .rtc {
                didRtcLeaveCallBack?(true)
                didRtcLeaveCallBack = nil
            } else if pipe == .mqtt { // 自身离开MQTT房间
                didMQTTLeaveCallBack?(true)
                didMQTTLeaveCallBack = nil
            }
        }
        
    }
    
    /**
     接收消息去重
     */
    func receivedMessage_duplicateRemoval(uid: String, msgId: String, msg: String, pipe: DYRealTimeSDKPipe) {
        
        let aTuple = DYRealTimeSDKDataParser.instance.parseMSGID_UID_ROOMIDFor(message: msg)
        
        let innerMsgId: String
        if msgId.count > 0 {
            innerMsgId = msgId
        } else if let aTuple = aTuple, let msgId = aTuple.msgId { //解析msgId
            innerMsgId = msgId
        } else {
            innerMsgId = msgId
        }
        
        //已收消息去重
        if currentReceivedMsgs.contains(innerMsgId) {
            log_receivedMessage_duplicateRemoval(uid: uid, msgId: innerMsgId, msg: msg, pipe: pipe, isFirstReceive: false)
            return
        } else {
            log_receivedMessage_duplicateRemoval(uid: uid, msgId: innerMsgId, msg: msg, pipe: pipe, isFirstReceive: true)
            currentReceivedMsgs.insert(innerMsgId)
        }
        
        //解析uid
        var uid = uid
        if uid.count == 0,
            let aTuple = aTuple,
            let sender = aTuple.uid {
            uid = sender
        }
        
        if uid == userConfig.account { return }//收到自己发送的消息，不处理
        
        if let type = DYRealTimeSDKDataParser.instance.parseType(forMessage: msg) {
            if type == messgeTypeOfJoinRoom { // 加入房间
                joinRoom_duplicateRemoval(isSuccess: true, uid: uid, pipe: pipe)
            } else if type == messgeTypeOfLeftRoom { // 退出房间
                leftRoom_duplicateRemoval(uid: uid, reason: .voluntary, pipe: pipe)
            }
        }
        
        delegate?.receivedMessage(uid: uid, msgId: innerMsgId, msg: msg)
        
    }
    
}

