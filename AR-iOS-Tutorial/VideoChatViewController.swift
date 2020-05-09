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
    @IBOutlet weak var micButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    
    weak var logVC: LogViewController?
    var rtcKit: ARtcEngineKit!
    var videoArr: NSMutableArray!
    var localVideo: ARVideoView!
    var placeholderView: ARVideoView!
    var video_width: CGFloat!
    var video_height: CGFloat!
    
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
        video_width = view.frame.size.width/3
        video_height = video_width * 4/3
        // This is our usual steps for joining
        // a channel and starting a call.
        initializeEngine()
        setupVideo()
        setupLocalVideo()
        joinChannel()
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
        localVideo = ARVideoView.loadVideoView(uid: nil)
        localVideo.frame = CGRect.init(x: view.frame.size.width - 25 - video_width/1.3, y: 36, width: video_width/1.3, height: video_height/1.3)
        localVideo.videoMutedIndicator.isHidden = true
        view.addSubview(localVideo)
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
        rtcKit.joinChannel(byToken: "", channelId: "demoChannel1", uid: nil) { [unowned self] (channel, uid, elapsed) -> Void in
            // Did join channel "demoChannel1"
            self.logVC?.log(type: .info, content: "did join channel")
            self.localVideo.uid = uid
            self.localVideo.videoMutedIndicator.isHidden = true
        }
        
        videoArr = NSMutableArray.init();
        isStartCalling = true
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    func leaveChannel() {
        // leave channel and end chat
        localVideo.videoMutedIndicator.isHidden = false
        placeholderView.isHidden = false
        for video in videoArr {
            let videoView = video as! ARVideoView
            videoView.removeFromSuperview()
        }
        videoArr.removeAllObjects()
        videoLayout()
        
        rtcKit.leaveChannel(nil)
        isStartCalling = false
        UIApplication.shared.isIdleTimerDisabled = false
        self.logVC?.log(type: .info, content: "did leave channel")
    }
    
    func videoLayout() {
        if videoArr.count <= 1 {
            if videoArr.count == 0 {
                placeholderView.isHidden = false
            } else {
                let remoteVideo:ARVideoView! = videoArr?[0] as? ARVideoView
                remoteVideo.frame = view.bounds
                view.insertSubview(remoteVideo, at: 1)
            }
            localVideo.frame = CGRect.init(x: view.frame.size.width - 25 - video_width/1.3, y: 36, width: video_width/1.3, height: video_height/1.3)
            
        } else {
            placeholderView.isHidden = true
            
            let video_width: CGFloat = view.frame.size.width/3;
            let video_height: CGFloat = video_width * 4/3;
            
            let allVideo = NSMutableArray.init(array: videoArr)
            allVideo.insert(localVideo as Any, at: 0)
            for (index,video) in allVideo.enumerated() {
                let row: NSInteger = index / 3
                let col: NSInteger = index % 3
                let margin: CGFloat = (self.view.bounds.size.width - (video_width * 3)) / (3 + 1)
                let picX: CGFloat = margin + (video_width + margin) * CGFloat(col);
                let picY: CGFloat = margin + (video_height + margin) * CGFloat(row);
                let videoView = video as! ARVideoView
                videoView.frame = CGRect.init(x: picX, y: picY, width: video_width, height: video_height)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        localVideo.frame = CGRect.init(x: 0, y: 0, width: 120, height: 160);
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
        let remoteView = ARVideoView.loadVideoView(uid: uid)
        view.addSubview(remoteView)
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
        for video in videoArr {
            let videoVideo = video as! ARVideoView
            if videoVideo.uid == uid {
                videoArr.remove(videoVideo)
                videoVideo.removeFromSuperview()
            }
        }
        videoLayout()
    }

    func rtcEngine(_ engine: ARtcEngineKit, didVideoMuted muted: Bool, byUid uid: String) {

    }
    
    func rtcEngine(_ engine: ARtcEngineKit, didOccurWarning warningCode: ARWarningCode) {
        logVC?.log(type: .warning, content: "did occur warning, code: \(warningCode.rawValue)")
    }
    
    func rtcEngine(_ engine: ARtcEngineKit, didOccurError errorCode: ARErrorCode) {
        logVC?.log(type: .error, content: "did occur error, code: \(errorCode.rawValue)")
    }
}
