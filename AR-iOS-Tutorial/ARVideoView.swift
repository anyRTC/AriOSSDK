//
//  ARVideoView.swift
//  AR-iOS-Tutorial
//
//  Created by 余生丶 on 2020/5/7.
//  Copyright © 2020 AR. All rights reserved.
//

import UIKit

class ARVideoView: UIView {
    @IBOutlet weak var renderView: UIView!
    // 占位图
    @IBOutlet weak var videoMutedIndicator: UIView!
    @IBOutlet weak var audioMutedIndicator: UIImageView!
    
    var uid: String?
    
    class func loadVideoView(uid: String?)-> ARVideoView{
        let video = Bundle.main.loadNibNamed("ARVideoView", owner: self, options: nil)?.first as! ARVideoView
        video.uid = uid
        video.videoMutedIndicator.isHidden = true
        video.audioMutedIndicator.isHidden = true
        video.frame = CGRect.zero
        return video
    }
}
