Pod::Spec.new do |s|

    s.name = "DYEntireRealTimeSDK"
    s.version = "0.0.4"
    s.summary = "本SDK封装了多厂商的音视频SDK和相应的即时通讯SDK"
    s.description = "1. 简化和统一了各厂商服务注册和接口调用方式 2. 支持在各厂商SDK之间安全、高效地调度(目前支持声网、腾讯) 3. 多条通道并行发送自定义消息和消息去重 4. 封装了日志模块（厂商log，自定义log，DDLog），用于数据跟踪和后续分析 5. 解决多SDK引入和编译问题"
    s.homepage = "https://github.com/jackleemeta/DYEntireRealTimeSDK.git"
    s.license = "MIT"
    s.platform = :ios
    s.author = { "jack lee" => "jackleemeta@outlook.com" }
    s.requires_arc = true
    s.ios.deployment_target = "8.0"
    s.source = { :git => "https://github.com/jackleemeta/DYEntireRealTimeSDK.git", :tag => s.version }
    s.libraries = 'c++', 'resolv', 'crypto'
    
    s.default_subspecs = 'Framework'

    s.subspec 'Framework' do |ss|
        ss.vendored_frameworks = 'DYRealTimeSDK/Framewoks/*.framework', 'Carthage/Build/**/*.framework'
        ss.vendored_libraries =  'DYRealTimeSDK/Libraries/*.a'
    end

    s.subspec 'Source' do |ss|
        ss.vendored_frameworks = 'DYRealTimeSDK/Framewoks/*.framework'
        ss.source_files  = 'DYRealTimeSDK/Source/**/*.swift'
        ss.vendored_libraries =  'DYRealTimeSDK/Libraries/*.a'
    end

    s.dependency 'CocoaLumberjack/Swift', '3.6.1'
    s.dependency 'Device'
    s.dependency 'CocoaMQTT', '1.1.3'
    s.dependency 'TXLiteAVSDK_TRTC', '7.9.21032'
    s.dependency 'TXIMSDK_iOS', '4.7.2'
    s.dependency 'AgoraRtcEngine_iOS', '2.9.0.105'
    s.dependency 'AgoraRtm_iOS', '1.3.0'
    
    s.static_framework = true

    valid_archs = ['armv7', 'arm64e', 'armv7s', 'arm64', 'x86_64']
    s.xcconfig = {
        'VALID_ARCHS' =>  valid_archs.join(' '),
        'ENABLE_BITCODE' => 'NO'
    }
    s.pod_target_xcconfig = {
       'ARCHS[sdk=iphonesimulator*]' => '$(ARCHS_STANDARD_64_BIT)'
    }

end
