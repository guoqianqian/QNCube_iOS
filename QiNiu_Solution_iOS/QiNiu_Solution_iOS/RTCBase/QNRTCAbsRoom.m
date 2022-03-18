//
//  QNRTCBaseController.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/9/23.
//

#import "QNRTCAbsRoom.h"
#import "QNRTCRoomEntity.h"
#import <QNRTCKit/QNRTCKit.h>
#import <Masonry/Masonry.h>
#import "MBProgressHUD+QNShow.h"
#import <YYCategories/YYCategories.h>
#import "QNUserOperationView.h"
#import "QNRoomUserView.h"
#import <MJExtension/MJExtension.h>

@interface QNRTCAbsRoom ()<QNRTCClientDelegate,QNCameraTrackVideoDataDelegate,QNMicrophoneAudioTrackDataDelegate>

@property (nonatomic, strong) UIView *renderBackgroundView;//上面只添加 renderView

@property (nonatomic, strong) NSDictionary *settingsDic;

@property (nonatomic, assign) CGSize videoEncodeSize;
@property (nonatomic, assign) NSInteger kBitrate;


@end

@implementation QNRTCAbsRoom

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self configureRTCEngine];
}

- (void)configureRTCEngine {
    
    // 获取 QNRTCKit 的分辨率、帧率、码率的配置
    self.settingsDic = [self settingsArrayAtIndex:1];
    
    // QNRTCKit 的分辨率
    self.videoEncodeSize = CGSizeFromString(_settingsDic[@"VideoSize"]);
    // QNRTCKit 的码率
    self.kBitrate = [_settingsDic[@"kBitrate"] integerValue];
    
    [QNRTC configRTC:[QNRTCConfiguration defaultConfiguration]];
    // QNRTCClient 初始化
    self.rtcClient = [QNRTC createRTCClient];
    self.rtcClient.delegate = self;
    
    self.renderBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    [self.view insertSubview:self.renderBackgroundView atIndex:0];
    
    self.preview = [[QNGLKView alloc] init];
    self.preview.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    [self.renderBackgroundView addSubview:self.preview];
    
}

- (NSDictionary *)settingsArrayAtIndex:(NSInteger)index {
    NSArray *settingsArray = @[@{@"VideoSize":NSStringFromCGSize(CGSizeMake(288, 352)), @"FrameRate":@15, @"kBitrate":@(300)},
                        @{@"VideoSize":NSStringFromCGSize(CGSizeMake(480, 640)), @"FrameRate":@15, @"kBitrate":@(400) },
                        @{@"VideoSize":NSStringFromCGSize(CGSizeMake(544, 960)), @"FrameRate":@15, @"kBitrate":@(700)},
                        @{@"VideoSize":NSStringFromCGSize(CGSizeMake(720, 1280)), @"FrameRate":@20, @"kBitrate":@(1000)}];
    return settingsArray[index];
}

- (void)joinRoom:(QNRTCRoomEntity *)roomEntity {
    self.roomEntity = roomEntity;
    if (self.roomEntity.provideUserExtension) {
        [self.rtcClient join:self.roomEntity.provideRoomToken userData:self.roomEntity.provideUserExtension.mj_JSONString];
    } else {
        [self.rtcClient join:self.roomEntity.provideRoomToken];
    }
    
}

- (void)closeRoom {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.rtcClient leave];
}

- (void)leaveRoom {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.rtcClient leave];
}




#pragma mark    ----------------QNRTCClientDelegate
/*!
 * @abstract 房间状态变更的回调。
 *
 * @discussion 当状态变为 QNConnectionStateReconnecting 时，SDK 会为您自动重连，如果希望退出，直接调用 leave 即可。
 * 重连成功后的状态为 QNConnectionStateReconnected。
 *
 * @since v4.0.0
 */
- (void)RTCClient:(QNRTCClient *)client didConnectionStateChanged:(QNConnectionState)state disconnectedInfo:(QNConnectionDisconnectedInfo *)info {
    NSDictionary *roomStateDictionary =  @{
                                           @(QNConnectionStateIdle) : @"Idle",
                                           @(QNConnectionStateConnecting) : @"Connecting",
                                           @(QNConnectionStateConnected): @"Connected",
                                           @(QNConnectionStateReconnecting) : @"Reconnecting",
                                           @(QNConnectionStateReconnected) : @"Reconnected"
                                           };
    NSString *str = [NSString stringWithFormat:@"房间状态变更的回调。当状态变为 QNRoomStateReconnecting 时，SDK 会为您自动重连，如果希望退出，直接调用 leaveRoom 即可:\nroomState: %@",  roomStateDictionary[@(state)]];
    NSLog(@"%@",str);
}

/*!
 * @abstract 远端用户加入房间的回调。
 *
 * @since v4.0.0
 */
- (void)RTCClient:(QNRTCClient *)client didJoinOfUserID:(NSString *)userID userData:(NSString *)userData {
    NSString *str = [NSString stringWithFormat:@"远端用户加入房间的回调:\nuserId: %@, userData: %@",  userID, userData];
    NSLog(@"%@",str);
}

/*!
 * @abstract 远端用户离开房间的回调。
 *
 * @since v4.0.0
 */
- (void)RTCClient:(QNRTCClient *)client didLeaveOfUserID:(NSString *)userID {
    NSString *str = [NSString stringWithFormat:@"远端用户: %@ 离开房间的回调", userID];
    NSLog(@"%@",str);
}

/*!
 * @abstract 订阅远端用户成功的回调。
 *
 * @since v4.0.0
 */
- (void)RTCClient:(QNRTCClient *)client didSubscribedRemoteVideoTracks:(NSArray<QNRemoteVideoTrack *> *)videoTracks audioTracks:(NSArray<QNRemoteAudioTrack *> *)audioTracks ofUserID:(NSString *)userID {
    NSString *str = [NSString stringWithFormat:@"订阅远端用户: %@ 成功的回调", userID];
    NSLog(@"%@",str);
}

/*!
 * @abstract 远端用户发布音/视频的回调。
 *
 * @since v4.0.0
 */
- (void)RTCClient:(QNRTCClient *)client didUserPublishTracks:(NSArray<QNRemoteTrack *> *)tracks ofUserID:(NSString *)userID{
    NSString *str = [NSString stringWithFormat:@"远端用户: %@ 发布成功的回调:\nTracks: %@",  userID, tracks];
    NSLog(@"%@",str);
}

/*!
 * @abstract 远端用户取消发布音/视频的回调。
 *
 * @since v4.0.0
 */
- (void)RTCClient:(QNRTCClient *)client didUserUnpublishTracks:(NSArray<QNRemoteTrack *> *)tracks ofUserID:(NSString *)userID {
    NSString *str = [NSString stringWithFormat:@"远端用户: %@ 取消发布的回调:\nTracks: %@",  userID, tracks];
    NSLog(@"%@",str);
}

/*!
 * @abstract 远端用户发生重连的回调。
 *
 * @since v4.0.0
 */
- (void)RTCClient:(QNRTCClient *)client didReconnectingOfUserID:(NSString *)userID {
    NSString *logStr = [NSString stringWithFormat:@"userId 为 %@ 的远端用户发生了重连！", userID];
    NSLog(@"%@",logStr);
}

/*!
 * @abstract 远端用户重连成功的回调。
 *
 * @since v4.0.0
 */
- (void)RTCClient:(QNRTCClient *)client didReconnectedOfUserID:(NSString *)userID {
    NSString *logStr = [NSString stringWithFormat:@"userId 为 %@ 的远端用户重连成功了！", userID];
    NSLog(@"%@",logStr);
}

/*!
 * @abstract 成功创建转推/合流转推任务的回调。
 *
 * @since v4.0.0
 */
- (void)RTCClient:(QNRTCClient *)client didStartLiveStreamingWith:(NSString *)streamID {
    NSString *logStr = [NSString stringWithFormat:@"成功创建转推/合流转推任务的回调"];
    NSLog(@"%@",logStr);
}

/*!
 * @abstract 停止转推/合流转推任务的回调。
 *
 * @since v4.0.0
 */
- (void)RTCClient:(QNRTCClient *)client didStopLiveStreamingWith:(NSString *)streamID {
    NSString *logStr = [NSString stringWithFormat:@"停止转推/合流转推任务的回调"];
    NSLog(@"%@",logStr);
}

/*!
 * @abstract 更新合流布局的回调。
 *
 * @since v4.0.0
 */
- (void)RTCClient:(QNRTCClient *)client didTranscodingTracksUpdated:(BOOL)success withStreamID:(NSString *)streamID {
    NSString *logStr = [NSString stringWithFormat:@"更新合流布局的回调"];
    NSLog(@"%@",logStr);
}

/*!
 * @abstract 合流转推出错的回调。
 *
 * @since v4.0.0
 */
- (void)RTCClient:(QNRTCClient *)client didErrorLiveStreamingWith:(NSString *)streamID errorInfo:(QNLiveStreamingErrorInfo *)errorInfo {
    NSString *logStr = [NSString stringWithFormat:@"合流转推出错的回调"];
    NSLog(@"%@",logStr);
}

/*!
 * @abstract 收到远端用户发送给自己的消息时回调。
 *
 * @since v4.0.0
 */
- (void)RTCClient:(QNRTCClient *)client didReceiveMessage:(QNMessageInfo *)message {
    
}

/*!
 * @abstract 远端用户视频首帧解码后的回调。
 *
 * @discussion 如果需要渲染，则需要返回一个带 renderView 的 QNVideoRender 对象。
 *
 * @since v4.0.0
 */
- (void)RTCClient:(QNRTCClient *)client firstVideoDidDecodeOfTrack:(QNRemoteVideoTrack *)videoTrack remoteUserID:(NSString *)userID {
    NSString *str = [NSString stringWithFormat:@"远端用户: %@ trackId: %@ 视频首帧解码后的回调",  userID, videoTrack];
    NSLog(@"%@",str);

}

/*!
 * @abstract 远端用户视频取消渲染到 renderView 上的回调。
 *
 * @since v4.0.0
 */
- (void)RTCClient:(QNRTCClient *)client didDetachRenderTrack:(QNRemoteVideoTrack *)videoTrack remoteUserID:(NSString *)userID {
    
}

//麦克风帧回调
- (void)microphoneAudioTrack:(QNMicrophoneAudioTrack *)microphoneAudioTrack didGetAudioBuffer:(AudioBuffer *)audioBuffer bitsPerSample:(NSUInteger)bitsPerSample sampleRate:(NSUInteger)sampleRate {
    
}

//视频帧回调
- (void)cameraVideoTrack:(QNCameraVideoTrack *)cameraVideoTrack didGetSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    
}



@end
