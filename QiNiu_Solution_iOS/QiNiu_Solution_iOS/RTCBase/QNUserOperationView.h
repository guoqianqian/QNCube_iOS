//
//  QNUserOperationView.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/4/13.
//

#import <QNRTCKit/QNRTCKit.h>


@class QNUserOperationView;
@protocol QNUserOperationViewDelegate <NSObject>
- (BOOL)userViewWantEnterFullScreen:(QNUserOperationView *)userview;
- (void)userView:(QNUserOperationView *)userview longPressWithUserId:(NSString *)userId;
@end

@interface QNUserOperationView : UIView

@property (nonatomic, weak) id<QNUserOperationViewDelegate> delegate;

@property (nonatomic, strong) NSString *trackId;
@property (nonatomic, strong) NSString *userId;

@property (nonatomic, strong) NSMutableArray *traks;

@property (nonatomic, readonly) QNVideoView *cameraView;
@property (nonatomic, readonly) QNVideoView *screenView;

@property (nonatomic, weak) UIView *fullScreenSuperView;

- (QNTrack *)trackInfoWithTrackId:(NSString *)trackId;

- (void)showCameraView;

- (void)hideCameraView;

- (void)showScreenView;

- (void)hideScreenView;

- (void)setAudioMute:(BOOL)isMute;

//- (void)setVideoHidden:(BOOL)isHidden trackId:(NSString *)trackId;

- (void)setMuteViewHidden:(BOOL)isHidden;

- (void)updateBuffer:(short *)buffer withBufferSize:(UInt32)bufferSize;

@end
