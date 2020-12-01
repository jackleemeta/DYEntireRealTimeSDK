//
//  DYRealTimeSDKCodes.swift
//  DYRealTimeSDK
//
//  Created by beck tian on 2019/12/12.
//  Copyright © 2019 beck tian. All rights reserved.
//

enum MediaWarningCode: Int {
    case InvalidView = 8
    case InitVideo = 16
    case Pending = 20
    case NoAvailableChannel = 103
    case LookupChannelTimeout = 104
    case LookupChannelRejected = 105
    case OpenChannelTimeout = 106
    case OpenChannelRejected = 107
    case SwitchLiveVideoTimeout = 111
    case SetClientRoleTimeout = 118
    case SetClientRoleNotAuthorized = 119
    case AudioMixingOpenError = 701
    case Adm_RuntimePlayoutWarning = 1014
    case Adm_RuntimeRecordingWarning = 1016
    case Adm_RecordAudioSilence = 1019
    case Adm_PlaybackMalfunction = 1020
    case Adm_RecordMalfunction = 1021
    case Adm_Interruption = 1025
    case Adm_RouteChange = 1026
    case Apm_Howling = 1051
    case Default = 0
}

enum MediaErrorCode: Int {
    case NoError = 0
    case Failed = 1
    case InvalidArgument = 2
    case NotReady = 3
    case NotSupported = 4
    case Refused = 5
    case BufferTooSmall = 6
    case NotInitialized = 7
    case NoPermission = 9
    case TimedOut = 10
    case Canceled = 11
    case TooOften = 12
    case BindSocket = 13
    case NetDown = 14
    case NoBufs = 15
    case JoinChannelRejected = 17
    case LeaveChannelRejected = 18
    case AlreadyInUse = 19
    
    case InvalidAppId = 101
    case InvalidChannelName = 102
    case ChannelKeyExpired = 109
    case InvalidChannelKey = 110
    case ConnectionInterrupted = 111 // only used in web sdk
    case ConnectionLost = 112 // only used in web sdk
    case NotInChannel = 113
    case SizeTooLarge = 114
    case BitrateLimit = 115
    case TooManyDataStreams = 116
    case DecryptionFailed = 120
    
    case LoadMediaEngine = 1001
    case StartCall = 1002
    case StartCamera = 1003
    case StartVideoRender = 1004
    case Adm_GeneralError = 1005
    case Adm_JavaResource = 1006
    case Adm_SampleRate = 1007
    case Adm_InitPlayout = 1008
    case Adm_StartPlayout = 1009
    case Adm_StopPlayout = 1010
    case Adm_InitRecording = 1011
    case Adm_StartRecording = 1012
    case Adm_StopRecording = 1013
    case Adm_RuntimePlayoutError = 1015
    case Adm_RuntimeRecordingError = 1017
    case Adm_RecordAudioFailed = 1018
    case Adm_Play_Abnormal_Frequency = 1020
    case Adm_Record_Abnormal_Frequency = 1021
    case Adm_Init_Loopback  = 1022
    case Adm_Start_Loopback = 1023
    // 1025 as warning for interruption of adm on ios
    // 1026 as warning for route change of adm on ios
    // VDM error code starts from 1500
    case Vdm_Camera_Not_Authorized = 1501
    
    // VCM error code starts from 1600
    case Vcm_Unknown_Error = 1600
    case Vcm_Encoder_Init_Error = 1601
    case Vcm_Encoder_Encode_Error = 1602
    case Vcm_Encoder_Set_Error = 1603
}

enum MediaChannelProfile: Int {
    case Communication = 0
    case LiveBroadcasting = 1
    case Game = 2
}

enum MediaClientRole: Int {
    case Broadcaster = 1
    case Audience = 2
}

enum MediaVideoProfile: Int {
    // res       fps  kbps
    case Invalid = -1
    case S120P = 0         // 160x120   15   65
    #if TARGET_OS_IPHONE
    case S120P_3 = 2        // 120x120   15   50
    case S180P = 10        // 320x180   15   140
    case S180P_3 = 12        // 180x180   15   100
    case S180P_4 = 13        // 240x180   15   120
    #endif
    case S240P = 20        // 320x240   15   200
    #if TARGET_OS_IPHONE
    case S240P_3 = 22        // 240x240   15   140
    case S240P_4 = 23        // 424x240   15   220
    #endif
    case S360P = 30        // 640x360   15   400
    #if TARGET_OS_IPHONE
    case S360P_3 = 32        // 360x360   15   260
    #endif
    case S360P_4 = 33        // 640x360   30   600
    case S360P_6 = 35        // 360x360   30   400
    case S360P_7 = 36        // 480x360   15   320
    case S360P_8 = 37        // 480x360   30   490
    case S360P_9 = 38      // 640x360   15   800
    case S360P_10 = 39     // 640x360   24   800
    case S360P_11 = 100    // 640x360   24   1000
    case S480P = 40        // 640x480   15   500
    #if TARGET_OS_IPHONE
    case S480P_3 = 42        // 480x480   15   400
    #endif
    case S480P_4 = 43        // 640x480   30   750
    case S480P_6 = 45        // 480x480   30   600
    case S480P_8 = 47        // 848x480   15   610
    case S480P_9 = 48        // 848x480   30   930
    case S720P = 50        // 1280x720  15   1130
    case S720P_3 = 52        // 1280x720  30   1710
    case S720P_5 = 54        // 960x720   15   910
    case S720P_6 = 55        // 960x720   30   1380
    case S1080P = 60        // 1920x1080 15   2080
    case S1080P_3 = 62        // 1920x1080 30   3150
    case S1080P_5 = 64        // 1920x1080 60   4780
    case S1440P = 66        // 2560x1440 30   4850
    case S1440P_2 = 67        // 2560x1440 60   7350
    case S4K = 70            // 3840x2160 30   8190
    case S4K_3 = 72        // 3840x2160 60   13500
}


enum MediaQuality: UInt {
    case Unknown = 0
    case Excellent = 1
    case Good = 2
    case Poor = 3
    case Bad = 4
    case VBad = 5
    case Down = 6
}

enum MediaUserOfflineReason: Int {
    case Quit = 0
    case Dropped = 1
    case BecomeAudience = 2
}

enum MediaVideoStreamType: Int {
    case Unknown = -1
    case High = 0
    case Low = 1
    case Medium = 2
}

enum MediaLogFilter: Int {
    case Console = 0x08000
    case Debug = 0x0800
    case Info = 0x0001
    case Warn = 0x0002
    case Error = 0x0004
    case Critical = 0x0008
}

enum MediaRenderMode: UInt {
    case Hidden = 1
    case Fit = 2
    case Adaptive = 3
}

enum MediaQualityReportFormat: Int {
    case Json = 0
    case Html = 1
}

enum MediaRawAudioFrameOpMode: Int {
    case ReadOnly = 0
    case WriteOnly = 1
    case ReadWrite = 2
}

enum MediaDeviceType: Int {
    case Audio_Unknown = -1
    case Audio_Recording = 0
    case Audio_Playout = 1
    case Video_Render = 2
    case Video_Capture = 3
}
