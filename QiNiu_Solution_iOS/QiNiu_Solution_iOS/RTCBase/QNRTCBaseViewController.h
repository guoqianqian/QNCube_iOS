//
//  QNRTCBaseViewController.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/4/13.
//

#import <UIKit/UIKit.h>
#import <QNRTCKit/QNRTCKit.h>
#import <Masonry.h>
#import "QNUserOperationView.h"

NS_ASSUME_NONNULL_BEGIN

@class QNRoomUserView;
@interface QNRTCBaseViewController : UIViewController
<
QNRTCClientDelegate,
QNUserOperationViewDelegate
>
@property (nonatomic, readonly) NSMutableArray *logStringArray;
@property (nonatomic, readonly) UIView *renderBackgroundView;//上面只能添加 renderView，不然会影响布局
@property (nonatomic, readonly) NSMutableArray *userViewArray;

@property (nonatomic, strong) QNRTCClient *rtcClient;
@property (nonatomic, readonly) NSString *userId;
@property (nonatomic, readonly) NSString *appId;
@property (nonatomic, readonly) NSString *roomName;
@property (nonatomic, readonly) BOOL isAdmin;
@property (nonatomic, strong) QNTrack *screenTrackInfo;
@property (nonatomic, strong) QNTrack *cameraTrackInfo;
@property (nonatomic, strong) QNTrack *audioTrackInfo;

@property (nonatomic, strong) QNTrack *remoteScreenTrack;
@property (nonatomic, strong) QNTrack *remoteCameraTrack;
@property (nonatomic, strong) QNTrack *remoteAudioTrack;

- (void)resetRenderViews;
- (QNRoomUserView *)createUserViewWithTrackId:(NSString *)trackId userId:(NSString *)userId;
- (QNRoomUserView *)userViewWithTrackId:(NSString *)trackId;
- (void)addRenderViewToSuperView:(QNRoomUserView *)renderView;
- (void)removeRenderViewFromSuperView:(QNRoomUserView *)renderView;

// 用户退出房间的时候，清除掉用户的所有信息
- (void)clearUserInfo:(NSString *)userId;

- (void)clearAllRemoteUserInfo;

- (BOOL)isAdminUser:(NSString *)userId;

// 大小窗口切换
- (void)exchangeWindowSize;

- (void)leftSwipe;

- (void)rightSwipe;

- (void)checkSelfPreviewGesture;
@end

NS_ASSUME_NONNULL_END
