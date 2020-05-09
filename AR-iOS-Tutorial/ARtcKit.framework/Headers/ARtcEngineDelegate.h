//
//  ARtcEngineDelegate.h
//  ARtcKit
//
//  Created by 余生丶 on 2020/3/18.
//  Copyright © 2020 zjq. All rights reserved.
//

#ifndef ARtcEngineDelegate_h
#define ARtcEngineDelegate_h
#import "AREnumerates.h"
#import "ARObjects.h"

@class ARtcEngineKit;

@protocol ARtcEngineDelegate <NSObject>

@optional

//MARK: - Core Delegate Methods

/** 发生警告回调

@param engine   ARtcEngineKit对象
@param warningCode   ARWarningCode
*/
- (void)rtcEngine:(ARtcEngineKit * _Nonnull)engine didOccurWarning:(ARWarningCode)warningCode;

/** 发生错误回调

@param engine   ARtcEngineKit对象
@param errorCode   ARErrorCode
*/
- (void)rtcEngine:(ARtcEngineKit *_Nonnull)engine didOccurError:(ARErrorCode)errorCode;

/** 加入频道回调

@param engine   ARtcEngineKit对象
@param channel   频道名称
@param uid   用户ID
@param elapsed   从调用joinChannelByToken开始到发生此事件过去的时间（ms)。
*/
- (void)rtcEngine:(ARtcEngineKit * _Nonnull)engine didJoinChannel:(NSString * _Nonnull)channel withUid:(NSString * _Nonnull)uid elapsed:(NSInteger)elapsed;

/** 重新加入频道回调

有时候由于网络原因，客户端可能会和服务器失去连接，SDK 会进行自动重连，自动重连成功后触发此回调方法。

@param engine   ARtcEngineKit对象
@param channel   频道名称
@param uid   用户ID
@param elapsed   从开始重连到重连成功的时间（ms）。
*/
- (void)rtcEngine:(ARtcEngineKit *_Nonnull)engine didRejoinChannel:(NSString *_Nonnull)channel withUid:(NSString * _Nonnull)uid elapsed:(NSInteger)elapsed;

/** 用户角色已切换回调

直播场景下，当本地用户在加入频道后调用 setClientRole 切换角色时会触发此回调，即主播切换为观众时，或观众切换为主播时。

@param engine   ARtcEngineKit对象
@param oldRole   切换前的角色
@param newRole   切换后的角色
*/
- (void)rtcEngine:(ARtcEngineKit *_Nonnull)engine didClientRoleChanged:(ARClientRole)oldRole newRole:(ARClientRole)newRole;

/** 远端用户/主播加入回调

@param engine   ARtcEngineKit对象
@param uid   新加入频道的远端用户/主播 ID。如果 joinChannelByToken 中指定了 uid，则此处返回该 ID；否则使用anyRTC服务器自动分配的 ID。
@param elapsed   从本地用户加入频道 joinChannelByToken 或 joinChannelByUserAccount 开始到发生此事件过去的时间（ms）。
*/
- (void)rtcEngine:(ARtcEngineKit *_Nonnull)engine didJoinedOfUid:(NSString *_Nonnull)uid elapsed:(NSInteger)elapsed;

/** 远端用户（通信场景）/主播（直播场景）离开当前频道回调

@param engine   ARtcEngineKit对象
@param uid   离线的用户 ID。
@param reason   离线原因，详见 ARUserOfflineReason。
*/
- (void)rtcEngine:(ARtcEngineKit *_Nonnull)engine didOfflineOfUid:(NSString *_Nonnull)uid reason:(ARUserOfflineReason)reason;

/** 网络连接状态已改变回调

该回调在网络连接状态发生改变的时候触发，并告知用户当前的网络连接状态，和引起网络状态改变的原因。

@param engine ARtcEngineKit对象
@param state 当前的网络连接状态，详见 ARConnectionStateType。
@param reason 引起网络连接状态发生改变的原因，详见 ARConnectionChangedReason。
*/
- (void)rtcEngine:(ARtcEngineKit * _Nonnull)engine connectionChangedToState:(ARConnectionStateType)state reason:(ARConnectionChangedReason)reason;

/** 本地网络类型发生改变回调

@param engine   ARtcEngineKit对象
@param type   网络连接类型，详见 ARNetworkType。
*/
- (void)rtcEngine:(ARtcEngineKit *_Nonnull)engine networkTypeChangedToType:(ARNetworkType)type;

/** 网络连接中断，且 SDK 无法在 10 秒内连接服务器回调

@param engine   ARtcEngineKit对象
*/
- (void)rtcEngineConnectionDidLost:(ARtcEngineKit *_Nonnull)engine;

/** Token 服务即将过期回调

 在调用 joinChannelByToken 时如果指定了 Token，由于 Token 具有一定的时效，在通话过程中如果 Token 即将失效，SDK 会提前 30 秒触发该回调，提醒应用程序更新 Token。 当收到该回调时，用户需要重新在服务端生成新的 Token，然后调用 renewToken 将新生成的 Token 传给 SDK。

 @param engine ARtcEngineKit 对象
 @param token  即将服务失效的 Token
 */
- (void)rtcEngine:(ARtcEngineKit * _Nonnull)engine tokenPrivilegeWillExpire:(NSString *_Nonnull)token;

/** Token 过期回调

 在调用 joinChannelByToken 时如果指定了 Token，由于 Token 具有一定的时效，在通话过程中 SDK 可能由于网络原因和服务器失去连接，重连时可能需要新的 Token。 该回调通知 App 需要生成新的 Token，并需调用 renewToken 为 SDK 指定新的 Token。

 @param engine ARtcEngineKit 对象
 */
- (void)rtcEngineRequestToken:(ARtcEngineKit * _Nonnull)engine;


//MARK: - Media Delegate Methods

/** 提示频道内谁正在说话、说话者音量及本地用户是否在说话的回调

 与 audioVolumeIndicationBlock 相同。

 该回调报告频道内瞬时音量最高的几个用户（最多三个用户）的用户 ID、他们的音量及本地用户是否在说话。

 该回调默认禁用。可以通过 enableAudioVolumeIndication 方法开启；开启后，无论频道内是否有人说话，SDK 都会按 enableAudioVolumeIndication 方法中设置的时间间隔触发 reportAudioVolumeIndicationOfSpeakers 回调。每次触发，用户会收到两个独立的 reportAudioVolumeIndicationOfSpeakers 回调，其中一个包含本地用户的音量信息，另一个包含远端所有用户的音量信息，详见下方参数描述。

**Note:**

 - 若需使用该回调 speakers 数组中的 vad 参数（即本地人声检测功能），请在 enableAudioVolumeIndication 方法中设置 report_vad 为 YES 。
 - 如果有用户将自己静音（调用了 muteLocalAudioStream ），会对该回调的行为产生影响。
 - 本地用户静音后 SDK 即不再报告本地用户的音量提示回调。
 - 远端说话者静音后 20 秒，远端的音量提示回调中将不再包含该用户；如果远端所有用户都将自己静音，20 秒后 SDK 不再报告远端用户的音量提示回调。

 @param engine      ARtcEngineKit 对象
 @param speakers    ARtcAudioVolumeInfo 数组。

 - 在本地用户的回调中，此数组中包含以下成员：
  - `uid` = 0,
  - volume 等于 totalVolume，返回本地用户混音后的音量；
  - vad，返回本地用户人声状态。

 - 在远端用户的回调中，此数组中包含以下成员：
  - uid 为每位说话者各自的用户 ID；
  - volume 为说话者各自混音后的音量；
  - vad = 0，对远端用户无效。 如果报告的 speakers 数组为空，则表示此时远端没有人说话。

 @param totalVolume （混音后的）总音量，取值范围为 [0,255]。

 - 在本地用户的回调中，totalVolume 为本地用户混音后的音量。
 - 在远端用户的回调中，totalVolume 为所有说话者混音后的总音量。
 */
- (void)rtcEngine:(ARtcEngineKit * _Nonnull)engine reportAudioVolumeIndicationOfSpeakers:(NSArray<ARtcAudioVolumeInfo *> * _Nonnull)speakers totalVolume:(NSInteger)totalVolume;

/** 已发送本地音频首帧的回调

 @param engine  ARtcEngineKit 对象
 @param elapsed 从本地用户调用joinChannelByToken开始到发生此事件过去的时间（ms)。
 */
- (void)rtcEngine:(ARtcEngineKit * _Nonnull)engine firstLocalAudioFrame:(NSInteger)elapsed;

 /** 已显示本地视频首帧的回调

 第一帧本地视频显示时，触发此回调。
  
 @param engine  ARtcEngineKit 对象
 @param size    本地渲染的视频尺寸（宽度和高度）
 @param elapsed 从本地用户调用joinChannelByToken到发生此事件过去的时间（ms）。 如果在joinChannelByToken前调用了startPreview，是从startPreview到发生此事件过去的时间。
 */
- (void)rtcEngine:(ARtcEngineKit * _Nonnull)engine firstLocalVideoFrameWithSize:(CGSize)size elapsed:(NSInteger)elapsed;

/** 远端音频流状态发生改变回调。

 远端用户/主播音频状态发生改变时，SDK 会触发该回调向本地用户报告当前的远端音频流状态。
 
 @param engine ARtcEngineKit 对象
 @param uid 发生音频状态改变的远端用户 ID。
 @param state  远端音频流状态。详见 ARAudioRemoteState。
 @param reason 远端音频流状态改变的具体原因。详见 ARAudioRemoteStateReason。
 @param elapsed 从本地用户调用 joinChannel 方法到发生本事件经历的时间，单位为 ms。
 */
- (void)rtcEngine:(ARtcEngineKit * _Nonnull)engine remoteAudioStateChangedOfUid:(NSString *_Nonnull)uid state:(ARAudioRemoteState)state reason:(ARAudioRemoteStateReason)reason elapsed:(NSInteger)elapsed;

/** 本地音频状态发生改变回调。

 本地音频的状态发生改变时（包括本地麦克风录制状态和音频编码状态），SDK会触发该回调报告当前的本地音频状态。在本地音频出现故障时，该回调可以帮助你了解当前音频的状态以及出现故障的原因，方便你排查问题。
 
 **Note:**
    
 当状态为 ARAudioLocalStateFailed(3) 时，你可以在 error 参数中查看返回的错误信息。

 @param engine ARtcEngineKit 对象
 @param state 当前的本地音频状态。详见 ARAudioLocalState。
 @param error 本地音频出错原因。详见 ARAudioLocalError。
 */
- (void)rtcEngine:(ARtcEngineKit * _Nonnull)engine localAudioStateChange:(ARAudioLocalState)state error:(ARAudioLocalError)error;

/** 远端用户暂停/重新发送视频回调

 你也可以使用 remoteVideoStateChangedOfUid 回调的：
 
 - ARVideoRemoteStateStopped(0) and ARVideoRemoteStateReasonRemoteMuted(5).
 - ARVideoRemoteStateDecoding(2) 和 ARVideoRemoteStateReasonRemoteUnmuted(6)。

 **Note:**

 当频道内的用户或主播数超过 20 人，该回调会失效。

 @param engine ARtcEngineKit 对象
 @param muted  暂停或恢复发送视频流：

 * Yes: 该用户已暂停发送其视频流
 * No: 该用户已恢复发送其视频流

 @param uid    远端用户 UID
 */
- (void)rtcEngine:(ARtcEngineKit * _Nonnull)engine didVideoMuted:(BOOL)muted byUid:(NSString *_Nonnull)uid;

/** 本地或远端视频大小和旋转信息发生改变回调

 @param engine   ARtcEngineKit 对象
 @param uid      图像尺寸和旋转信息发生变化的用户的用户 ID（本地用户的 uid 为 0）
 @param size    新的视频尺寸
 @param rotation 旋转信息 (0 到 360)
 */
- (void)rtcEngine:(ARtcEngineKit * _Nonnull)engine videoSizeChangedOfUid:(NSString *_Nonnull)uid size:(CGSize)size rotation:(NSInteger)rotation;

/** 远端视频状态发生改变回调

@param engine ARtcEngineKit 对象
@param uid 发生视频状态改变的远端用户 ID。
@param state 远端视频流状态。详见 ARVideoRemoteState。
@param reason 远端视频流状态改变的具体原因。详见 ARVideoRemoteStateReason。
@param elapsed 从本地用户调用 joinChannel 方法到发生本事件经历的时间，单位为 ms。
*/
- (void)rtcEngine:(ARtcEngineKit *_Nonnull)engine remoteVideoStateChangedOfUid:(NSString *_Nonnull)uid state:(ARVideoRemoteState)state reason:(ARVideoRemoteStateReason)reason elapsed:(NSInteger)elapsed;

//MARK: - Methods

/** 已显示远端视频首帧回调

@param engine ARtcEngineKit 对象
@param uid 发生视频状态改变的远端用户 ID。
@param size 视频大小
@param elapsed 从本地用户调用 joinChannel 方法到发生本事件经历的时间，单位为 ms。
*/
- (void)rtcEngine:(ARtcEngineKit *_Nonnull)engine firstRemoteVideoFrameOfUid:(NSString *_Nonnull)uid size:(CGSize)size elapsed:(NSInteger)elapsed;

/** 已完成远端视频首帧解码回调

@param engine ARtcEngineKit 对象
@param uid 发生视频状态改变的远端用户 ID。
@param size 视频大小
@param elapsed 从本地用户调用 joinChannel 方法到发生本事件经历的时间，单位为 ms。
*/
- (void)rtcEngine:(ARtcEngineKit *_Nonnull)engine firstRemoteVideoDecodedOfUid:(NSString *_Nonnull)uid size:(CGSize)size elapsed:(NSInteger)elapsed;

/** 已接收远端音频首帧的回调

@param engine ARtcEngineKit 对象
@param uid 发生视频状态改变的远端用户 ID。
@param elapsed 从本地用户调用 joinChannel 方法到发生本事件经历的时间，单位为 ms。
*/
- (void)rtcEngine:(ARtcEngineKit *_Nonnull)engine firstRemoteAudioFrameOfUid:(NSString *_Nonnull)uid elapsed:(NSInteger)elapsed;

/** 已解码远端音频首帧的回调

@param engine ARtcEngineKit 对象
@param uid 发生视频状态改变的远端用户 ID。
@param elapsed 从本地用户调用 joinChannel 方法到发生本事件经历的时间，单位为 ms。
*/
- (void)rtcEngine:(ARtcEngineKit *_Nonnull)engine firstRemoteAudioFrameDecodedOfUid:(NSString *_Nonnull)uid elapsed:(NSInteger)elapsed;

//MARK: - Device Delegate Methods

/** 语音路由已发生变化回调

当语音路由发生变化时，SDK 会触发此回调。

 @param engine  ARtcEngineKit 对象
 @param routing 设置语音路由: ARAudioOutputRouting
 */
- (void)rtcEngine:(ARtcEngineKit * _Nonnull)engine didAudioRouteChanged:(ARAudioOutputRouting)routing;

@end


#endif /* ARtcEngineDelegate_h */
