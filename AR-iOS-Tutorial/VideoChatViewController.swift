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
    
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var micButton: UIButton!
    @IBOutlet weak var audioButton: UIButton!
    @IBOutlet weak var videoButton: UIButton!
    @IBOutlet weak var switchButton: UIButton!
    
    weak var logVC: LogViewController?
    var rtcKit: ARtcEngineKit!
    var videoArr: NSMutableArray!
    var localVideo: ARVideoView!
    var placeholderView: ARVideoView!
    var role: ARClientRole = .audience
    var column: NSInteger = 3
    var rate: CGFloat = 1.0
    var isJoin: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // This is our usual steps for joining
        // a channel and starting a call.
        initializeEngine()
        joinChannel()
        setupVideo()
        setupLocalVideo()
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
        rtcKit.setChannelProfile(.profileiveBroadcasting)
    }

    func setupVideo() {
        // In simple use cases, we only need to enable video capturing
        // and rendering once at the initialization step.
        // Note: audio recording and playing is enabled by default.
        rtcKit.enableVideo()
        rtcKit.setVideoEncoderConfiguration(ARVideoEncoderConfiguration(size: CGSize.init(width: 640, height: 480), frameRate: .fps15, bitrate: 500, orientationMode: .adaptative))
    }
    
    func setupLocalVideo() {
        localVideo = ARVideoView.loadVideoView(uid: nil)
        view.insertSubview(localVideo, at: 0)
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
        
        placeholderView = ARVideoView.loadVideoView(uid: "")
        placeholderView.frame = view.bounds
        placeholderView.videoMutedIndicator.isHidden = false
        placeholderView.videoMutedIndicator.backgroundColor = UIColor.init(red: 72/256, green: 65/256, blue: 88/256, alpha: 1)
        view.insertSubview(placeholderView, at: 0)
    }
    
    func joinChannel() {
        rtcKit.startPreview()
        // Set audio route to speaker
        rtcKit.setDefaultAudioRouteToSpeakerphone(true)
        
        // 1. Users can only see each other after they join the
        // same channel successfully using the same app id.
        // 2. One token is only valid for the channel name that
        // you use to generate this token.
        rtcKit.joinChannel(byToken: "", channelId: "909090", uid: nil) { [unowned self] (channel, uid, elapsed) -> Void in
            // Did join channel "demoChannel1"
            self.logVC?.log(type: .info, content: "did join channel")
            self.localVideo.uid = uid
            self.rtcKit.setEnableSpeakerphone(true)
            self.micButton.isHidden = false
            self.isJoin = true
            UIApplication.shared.isIdleTimerDisabled = true
        }
        rtcKit.enableDualStreamMode(true)
        
        videoArr = NSMutableArray.init();
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    func leaveChannel() {
        // leave channel and end chat
        micButton.isHidden = true
        stackView.isHidden = true
        localVideo.videoMutedIndicator.isHidden = true
        
        for video in videoArr {
            let videoView = video as! ARVideoView
            videoView.removeFromSuperview()
        }
        localVideo.isHidden = true
        micButton.isSelected = false
        videoButton.isSelected = false
        audioButton.isSelected = false
        rtcKit.muteLocalAudioStream(false)
        rtcKit.muteLocalVideoStream(false)
        
        videoArr.removeAllObjects()
        isJoin = false
        rtcKit.setClientRole(.audience)
        role = .audience
        
        rtcKit.leaveChannel(nil)
        UIApplication.shared.isIdleTimerDisabled = false
        self.logVC?.log(type: .info, content: "did leave channel")
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func videoLayout() {
        let allVideo = NSMutableArray.init(array: videoArr)
        if role == .broadcaster {
            allVideo.insert(localVideo as Any, at: 0)
        }
        
        if allVideo.count < 4 {
            for (_,video) in allVideo.enumerated() {
                let videoView = video as! ARVideoView
                if videoView != localVideo {
                    rtcKit.setRemoteVideoStream(videoView.uid!, type:.high)
                }
            }
            
            if allVideo.count == 1 {
                let videoView = allVideo[0] as! ARVideoView
                videoView.frame = view.frame
            } else if allVideo.count == 2 {
                let video_width = view.frame.size.width/2
                let video_height = video_width * 4/3
                for (index,video) in allVideo.enumerated() {
                    let videoView = video as! ARVideoView
                    videoView.frame = CGRect.init(x: CGFloat(index) * (video_width + 1), y: (view.frame.size.height - video_height)/2, width: video_width, height: video_height)
                }
            } else if allVideo.count == 3 {
                let video_width = view.frame.size.width/2
                let video_height = video_width * 4/3
                
                for (index,video) in allVideo.enumerated() {
                    let videoView = video as! ARVideoView
                    if index == 0 {
                        videoView.frame = CGRect.init(x: (view.frame.size.width - video_width)/2, y: 0, width: video_width, height: video_height)
                    } else {
                        videoView.frame = CGRect.init(x: (video_width + 1) * CGFloat(index - 1), y: (video_height + 1), width: video_width, height: video_height)
                    }
                }
            }
        } else {
            if allVideo.count == 4 {
                column = 2      // 2*2
                rate = 4/3
            } else {
                rate = 1
                if allVideo.count <= 9 {
                    column = 3   // 3*3
                } else if allVideo.count > 9 && allVideo.count <= 16 {
                    column = 4   // 4*4
                } else if (allVideo.count > 16) {
                    column = 6
                }
            }

            let video_width: CGFloat = view.frame.size.width/CGFloat(column)
            let video_height: CGFloat = video_width * rate;
            
            for (index,video) in allVideo.enumerated() {
                let row: NSInteger = index / column
                let col: NSInteger = index % column
                //let margin: CGFloat = (CGFloat(view.frame.size.width) - (video_width * CGFloat(column))) / CGFloat(column + 1)
                let margin: CGFloat = 1
                let picX: CGFloat = margin + (video_width + margin) * CGFloat(col)
                let picY: CGFloat = margin + (video_height + margin) * CGFloat(row)
                let videoView = video as! ARVideoView
                videoView.frame = CGRect.init(x: picX, y: picY, width: video_width, height: video_height)
                if videoView != localVideo {
                    var streamType: ARVideoStreamType!
                    (allVideo.count == 4) ? (streamType = .high) : (streamType = .low)
                    rtcKit.setRemoteVideoStream(videoView.uid!, type:streamType)
                }
            }
        }
    }
    
    @IBAction func didClickHangUpButton(_ sender: UIButton) {
        sender.isSelected.toggle()
        sender.isSelected ? (leaveChannel()) :(joinChannel())
    }
    
    @IBAction func didClickMicButton(_ sender: UIButton) {
        sender.isSelected.toggle()
        if sender.isSelected {
            role = .broadcaster
            rtcKit.setClientRole(.broadcaster)
        } else {
            role = .audience
            rtcKit.setClientRole(.audience)
            videoButton.isSelected = false
            audioButton.isSelected = false
            localVideo.videoMutedIndicator.isHidden = true
            rtcKit.muteLocalAudioStream(false)
            rtcKit.muteLocalVideoStream(false)
        }
        
        localVideo.isHidden = !sender.isSelected
        stackView.isHidden = !sender.isSelected
        videoLayout()
    }
    
    @IBAction func didClickVideoButton(_ sender: UIButton) {
        sender.isSelected.toggle()
        // mute local audio
        rtcKit.muteLocalVideoStream(sender.isSelected)
        localVideo.videoMutedIndicator.isHidden = !sender.isSelected
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
        let remoteView = ARVideoView.loadVideoView(uid: uid)
        view.insertSubview(remoteView, belowSubview:joinButton)
        videoArr.add(remoteView)
        
        // Only one remote video view is available for this
        // tutorial. Here we check if there exists a surface
        // view tagged as this uid.
        let videoCanvas = ARtcVideoCanvas()
        videoCanvas.uid = uid
        videoCanvas.view = remoteView
        videoCanvas.renderMode = .hidden
        rtcKit.setupRemoteVideo(videoCanvas)
        videoLayout()
    }

    func rtcEngine(_ engine: ARtcEngineKit, didOfflineOfUid uid: String, reason: ARUserOfflineReason) {
        videoArr.enumerateObjects({ (obj, idx, stop) in
            let videoVideo = obj as! ARVideoView
            if videoVideo.uid == uid {
                videoArr.remove(videoVideo)
                videoVideo.removeFromSuperview()
            }
        })
        videoLayout()
    }

    func rtcEngine(_ engine: ARtcEngineKit, didVideoMuted muted: Bool, byUid uid: String) {
        
    }
    
    func rtcEngine(_ engine: ARtcEngineKit, remoteVideoStateChangedOfUid uid: String, state: ARVideoRemoteState, reason: ARVideoRemoteStateReason, elapsed: Int) {
        if reason == .remoteMuted || reason == .remoteUnmuted {
            for video in videoArr {
                let videoVideo = video as! ARVideoView
                if videoVideo.uid == uid {
                    var mute: Bool
                    (reason == .remoteMuted) ? (mute = true) : (mute = false)
                    videoVideo.videoMutedIndicator.isHidden = !mute
                }
            }
        }
    }
    
    func rtcEngine(_ engine: ARtcEngineKit, didOccurWarning warningCode: ARWarningCode) {
        logVC?.log(type: .warning, content: "did occur warning, code: \(warningCode.rawValue)")
    }
    
    func rtcEngine(_ engine: ARtcEngineKit, didOccurError errorCode: ARErrorCode) {
        logVC?.log(type: .error, content: "did occur error, code: \(errorCode.rawValue)")
    }
}
