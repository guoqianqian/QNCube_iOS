//
//  QNRTCBaseController.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/9/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

//房间逻辑&生命周期

@class QNRTCRoomEntity,
QNRTCClient,
QNGLKView,
QNMicrophoneAudioTrack,
QNCameraVideoTrack,
QNScreenVideoTrack,
QNRoomUserView,
QNRemoteTrack,
QNRemoteAudioTrack,
QNRemoteVideoTrack;


@interface QNRTCAbsRoom : UIViewController

@property (nonatomic, strong) QNRTCClient *rtcClient;
@property (nonatomic, strong) QNGLKView *preview;

@property (nonatomic, strong) QNMicrophoneAudioTrack *localAudioTrack;
@property (nonatomic, strong) QNCameraVideoTrack *localVideoTrack;
@property (nonatomic, strong) QNScreenVideoTrack *localScreenTrack;

@property (nonatomic, strong) QNRemoteVideoTrack *remoteScreenTrack;
@property (nonatomic, strong) QNRemoteVideoTrack *remoteCameraTrack;
@property (nonatomic, strong) QNRemoteAudioTrack *remoteAudioTrack;

@property (nonatomic, strong)QNRTCRoomEntity *roomEntity;
//上面只能添加视频流画面
@property (nonatomic, readonly) UIView *renderBackgroundView;
//加入房间
- (void)joinRoom:(QNRTCRoomEntity *)roomEntity;
//关闭房间
- (void)closeRoom;
//离开房间
- (void)leaveRoom;



@end

NS_ASSUME_NONNULL_END
