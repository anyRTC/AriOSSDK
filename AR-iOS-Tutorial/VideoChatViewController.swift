//
//  VideoChatViewController.swift
//  AR-iOS-Tutorial
//
//  Created by 余生丶 on 2020/4/27.
//  Copyright © 2020 AR. All rights reserved.
//

import UIKit
import ARtcKit

class VideoChatViewController: UIViewController {
    @IBOutlet weak var localVideo: UIView!
    @IBOutlet weak var remoteVideo: UIView!
    @IBOutlet weak var remoteVideoMutedIndicator: UIImageView!
    @IBOutlet weak var localVideoMutedIndicator: UIView!
    @IBOutlet weak var micButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    
    weak var logVC: LogViewController?
    var rtcKit: ARtcEngineKit!
    
    var isRemoteVideoRender: Bool = true {
        didSet {
            remoteVideoMutedIndicator.isHidden = isRemoteVideoRender
            remoteVideo.isHidden = !isRemoteVideoRender
        }
    }
    
    var isLocalVideoRender: Bool = false {
        didSet {
            localVideoMutedIndicator.isHidden = isLocalVideoRender
        }
    }
    
    var isStartCalling: Bool = true {
        didSet {
            if isStartCalling {
                micButton.isSelected = false
            }
            micButton.isHidden = !isStartCalling
            cameraButton.isHidden = !isStartCalling
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // This is our usual steps for joining
        // a channel and starting a call.
        initializeEngine()
        setupVideo()
        setupLocalVideo()
        joinChannel()
        localVideoMutedIndicator.isHidden = true;
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            return
        }
        
        if identifier == "EmbedLogViewController",
            let vc = segue.destination as? LogViewController {
            self.logVC = vc
        }
    }
    
    func initializeEngine() {
        // init ARtcEngineKit
        rtcKit = ARtcEngineKit.sharedEngine(withAppId: AppID, delegate: self)
    }

    func setupVideo() {
        // In simple use cases, we only need to enable video capturing
        // and rendering once at the initialization step.
        // Note: audio recording and playing is enabled by default.
        rtcKit.enableVideo()
        rtcKit.setVideoEncoderConfiguration(ARVideoEncoderConfiguration(size: CGSize.init(width: 480, height: 640), frameRate: .fps15, bitrate: 500, orientationMode: .adaptative))
    }
    
    func setupLocalVideo() {
        // This is used to set a local preview.
        // The steps setting local and remote view are very similar.
        // But note that if the local user do not have a uid or do
        // not care what the uid is, he can set his uid as ZERO.
        // Our server will assign one and return the uid via the block
        // callback (joinSuccessBlock) after
        // joining the channel successfully.
        let videoCanvas = ARtcVideoCanvas()
        
        videoCanvas.view = localVideo
        videoCanvas.renderMode = .hidden
        rtcKit.setupLocalVideo(videoCanvas);
        rtcKit.startPreview();
    }
        
        
    
    func joinChannel() {
        // Set audio route to speaker
        rtcKit.setDefaultAudioRouteToSpeakerphone(true)
        
        // 1. Users can only see each other after they join the
        // same channel successfully using the same app id.
        // 2. One token is only valid for the channel name that
        // you use to generate this token.
        rtcKit.joinChannel(byToken: "", channelId: "demoChannel1", uid: nil) { [unowned self] (channel, uid, elapsed) -> Void in
            // Did join channel "demoChannel1"
            self.isLocalVideoRender = true
            self.logVC?.log(type: .info, content: "did join channel")
        }
        
        isStartCalling = true
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    func leaveChannel() {
        // leave channel and end chat
        rtcKit.leaveChannel(nil)
        
        isRemoteVideoRender = false
        isLocalVideoRender = false
        isStartCalling = false
        UIApplication.shared.isIdleTimerDisabled = false
        self.logVC?.log(type: .info, content: "did leave channel")
    }
    
    @IBAction func didClickHangUpButton(_ sender: UIButton) {
        sender.isSelected.toggle()
        if sender.isSelected {
            leaveChannel()
        } else {
            joinChannel()
        }
    }
    
    @IBAction func didClickMuteButton(_ sender: UIButton) {
        sender.isSelected.toggle()
        // mute local audio
        rtcKit.muteLocalAudioStream(sender.isSelected)
    }
    
    @IBAction func didClickSwitchCameraButton(_ sender: UIButton) {
        sender.isSelected.toggle()
        rtcKit.switchCamera()
    }
}

extension VideoChatViewController: ARtcEngineDelegate {
    // first remote video frame
    func rtcEngine(_ engine: ARtcEngineKit, firstRemoteVideoFrameOfUid uid: String, size: CGSize, elapsed: Int) {
        isRemoteVideoRender = true
        
        // Only one remote video view is available for this
        // tutorial. Here we check if there exists a surface
        // view tagged as this uid.
        let videoCanvas = ARtcVideoCanvas()
        videoCanvas.uid = uid
        videoCanvas.view = remoteVideo
        videoCanvas.renderMode = .hidden
        rtcKit.setupRemoteVideo(videoCanvas)
    }

    func rtcEngine(_ engine: ARtcEngineKit, didOfflineOfUid uid: String, reason: ARUserOfflineReason) {
        isRemoteVideoRender = false
    }

    func rtcEngine(_ engine: ARtcEngineKit, didVideoMuted muted: Bool, byUid uid: String) {
        isRemoteVideoRender = !muted
    }
    
    func rtcEngine(_ engine: ARtcEngineKit, didOccurWarning warningCode: ARWarningCode) {
        logVC?.log(type: .warning, content: "did occur warning, code: \(warningCode.rawValue)")
    }
    
    func rtcEngine(_ engine: ARtcEngineKit, didOccurError errorCode: ARErrorCode) {
        logVC?.log(type: .error, content: "did occur error, code: \(errorCode.rawValue)")
    }
}
