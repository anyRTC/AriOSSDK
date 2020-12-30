//
//  ARStreamingKit.h
//  ARtcKit
//
//  Created by 余生丶 on 2020/12/24.
//  Copyright © 2020 zjq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ARtcEngineKit.h"

NS_ASSUME_NONNULL_BEGIN

@interface ARStreamingKit : NSObject

/**
设置RtcEngine对象。

@param rtcKit  一个 ARtcEngineKit 实例对象。

@return 0方法调用成功，<0方法调用失败
*/
- (int)setRtcEngine:(ARtcEngineKit *)rtcKit;

/**
开始推Rtmp的流

@param url  rtmp流地址
 
@param mode 推流模式，详见ARStreamPushMode。

@return 0方法调用成功，<0方法调用失败
*/
- (int)pushStream:(NSString *_Nonnull)url pushMode:(ARStreamPushMode)mode;

/**
停止推Rtmp的流

@return 0方法调用成功，<0方法调用失败
*/
- (int)unPushStream;

/**
设置推流模式。

@param mode  推流模式，详见ARStreamPushMode。

@return 0方法调用成功，<0方法调用失败
*/
- (int)setMode:(ARStreamPushMode)mode;

/**
设置合流参数

@param transcoding  合流参数，详见ARStreamliveTranscoding。
*/
- (void)setLiveTranscoding:(ARStreamliveTranscoding *_Nonnull)transcoding;

@end

NS_ASSUME_NONNULL_END
