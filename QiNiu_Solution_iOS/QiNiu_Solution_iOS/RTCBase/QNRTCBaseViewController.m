//
//  QNRTCBaseViewController.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/4/13.
//

#import "QNRTCBaseViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <QNRTCKit/QNRTCKit.h>
#import <Masonry.h>
#import "QNUserOperationView.h"
#import "UIView+Alert.h"
#import "QNRoomUserView.h"
#import <YYCategories/YYCategories.h>
#import "MBProgressHUD+QNShow.h"
#import "QNPageControl.h"

@interface QNRTCBaseViewController ()

@property (nonatomic, strong) NSMutableArray *logStringArray;
@property (nonatomic, strong) UIScrollView *contentBgView;//承载renderBackgroundView滑动
@property (nonatomic, strong) UIView *renderBackgroundView;//上面只添加 renderView
@property (nonatomic, strong) NSMutableArray *userViewArray;
@property (nonatomic, strong) NSMutableDictionary *trackInfoDics;
@property (nonatomic, strong) QNPageControl *pageControl;

@end

@implementation QNRTCBaseViewController

- (NSString *)userId {
    return [[NSUserDefaults standardUserDefaults] stringForKey:QN_ACCOUNT_ID_KEY];
}

- (NSString *)roomName {
    return [[NSUserDefaults standardUserDefaults] stringForKey:QN_ROOM_NAME_KEY];
}

- (NSString *)appId {
    NSString *appId = [[NSUserDefaults standardUserDefaults] stringForKey:QN_APP_ID_KEY];
    if (0 == appId.length) {
        appId = QN_RTC_DEMO_APPID;
        [[NSUserDefaults standardUserDefaults] setObject:appId forKey:QN_APP_ID_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return appId;
}

- (BOOL)isAdmin {
    return [self.userId.lowercaseString isEqualToString:@"admin"];
}

- (BOOL)isAdminUser:(NSString *)userId {
    return [userId.lowercaseString isEqualToString:@"admin"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.logStringArray = [[NSMutableArray alloc] init];
    self.userViewArray = [[NSMutableArray alloc] init];
    self.trackInfoDics = [[NSMutableDictionary alloc] init];
    self.renderBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    [self.view insertSubview:self.renderBackgroundView atIndex:0];
    
}

- (void)clearUserInfo:(NSString *)userId {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (NSInteger i = self.userViewArray.count - 1; i >= 0; i--) {
            QNUserOperationView *userView = self.userViewArray[i];
            if ([userView.userId isEqualToString:userId]) {
                [userView removeFromSuperview];
                [self.userViewArray removeObject:userView];
            }
        }

        [self resetRenderViews];
    });
}

- (void)clearAllRemoteUserInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (NSInteger i = self.userViewArray.count - 1; i >= 0; i--) {
            QNUserOperationView *userView = self.userViewArray[i];
            [userView removeFromSuperview];
            [self.userViewArray removeObject:userView];
        }

        [self resetRenderViews];
    });
}

#pragma mark - 预览画面设置

- (void)resetRenderViews {
    @synchronized (self) {
        
        NSArray<QNRoomUserView *> *allRenderView = self.renderBackgroundView.subviews;
        
        if (1 == allRenderView.count) {
            self.pageControl.hidden = YES;
            [self.engine.previewView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.view);
            }];
            
        } else if (2 == allRenderView.count) {
            self.pageControl.hidden = YES;
            QNRoomUserView *removeCameraView = [self userViewWithTrackId:self.remoteCameraTrack.trackId];
            removeCameraView.showNameLabel = NO;
            [removeCameraView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.view);
            }];
            
            [self.engine.previewView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.view).offset(-20);
                make.top.equalTo(self.view).offset(70);
                make.width.equalTo(120);
                make.height.equalTo(200);
            }];
            
            [self.renderBackgroundView bringSubviewToFront:self.engine.previewView];
        }else if (3 == allRenderView.count) {
            self.pageControl.hidden = NO;
            self.pageControl.currentPage = 0;
            //对方屏幕分享
            QNRoomUserView *removeScreenView = [self userViewWithTrackId:self.remoteScreenTrack.trackId];
            removeScreenView.showNameLabel = NO;
            //添加左滑手势
            UISwipeGestureRecognizer *leftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipe)];
            [leftRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
            removeScreenView.userInteractionEnabled = YES;
            [removeScreenView addGestureRecognizer:leftRecognizer];
            [removeScreenView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.view);
            }];
            
            //自己的视图
            [self.engine.previewView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.view).offset(-20);
                make.top.equalTo(self.view).offset(70);
                make.width.equalTo(120);
                make.height.equalTo(200);
            }];
            
            //对方视图
            QNRoomUserView *removeCameraView = [self userViewWithTrackId:self.remoteCameraTrack.trackId];
            removeCameraView.showNameLabel = NO;
            //添加右滑手势
            UISwipeGestureRecognizer *rightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipe)];
            [rightRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
            removeCameraView.userInteractionEnabled = YES;
            [removeCameraView addGestureRecognizer:rightRecognizer];
            [removeCameraView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.view);
            }];
            
            [self.renderBackgroundView bringSubviewToFront:removeScreenView];
            [self.renderBackgroundView bringSubviewToFront:self.engine.previewView];
            
        } else {
                    
            int col = ceil(sqrt(allRenderView.count));
            
            UIView *preView = nil;
            UIView *upView = nil;
            for (int i = 0; i < allRenderView.count; i ++) {
                UIView *view = allRenderView[i];
                [view mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(preView ? preView.mas_right : self.renderBackgroundView);
                    make.top.equalTo(upView ? upView.mas_bottom : self.renderBackgroundView);
                    make.width.equalTo(self.renderBackgroundView).multipliedBy(1.0/col);
                    //                make.size.equalTo(self.renderBackgroundView).multipliedBy(1.0/col);
                    make.height.equalTo(view.width);
                }];
                
                if ((i + 1) % col == 0) {
                    preView = nil;
                    upView = view;
                } else {
                    preView = view;
                }
            }
        }
        
        [UIView animateWithDuration:.3 animations:^{
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
        }];
    }
}

- (void)leftSwipe {
    QNRoomUserView *removeCameraView = [self userViewWithTrackId:self.remoteCameraTrack.trackId];
    QNRoomUserView *removeScreenView = [self userViewWithTrackId:self.remoteScreenTrack.trackId];

//    if (self.pageControl.currentPage == 0 && self.engine.previewView.frame.size.width == kScreenWidth) {
//        [self.renderBackgroundView bringSubviewToFront:removeCameraView];
//        [self.renderBackgroundView bringSubviewToFront:removeScreenView];
//        self.pageControl.currentPage = 1;
//        return;
//    }
//    if (self.pageControl.currentPage == 1 && self.engine.previewView.frame.size.width == kScreenWidth){
//        [self.renderBackgroundView bringSubviewToFront:removeScreenView];
//        [self.renderBackgroundView bringSubviewToFront:removeCameraView];
//        self.pageControl.currentPage = 0;
//        return;
//    }
    
    [self.renderBackgroundView bringSubviewToFront:removeCameraView];
    [self.renderBackgroundView bringSubviewToFront:self.engine.previewView];
    self.pageControl.currentPage = 1;
    
}

- (void)rightSwipe {
    QNRoomUserView *removeCameraView = [self userViewWithTrackId:self.remoteCameraTrack.trackId];
    QNRoomUserView *removeScreenView = [self userViewWithTrackId:self.remoteScreenTrack.trackId];
    
//    if (self.pageControl.currentPage == 0 && self.engine.previewView.frame.size.width == kScreenWidth) {
//        [self.renderBackgroundView bringSubviewToFront:removeScreenView];
//        [self.renderBackgroundView bringSubviewToFront:removeCameraView];
//        self.pageControl.currentPage = 1;
//        return;
//    }
//    if (self.pageControl.currentPage == 1 && self.engine.previewView.frame.size.width == kScreenWidth){
//        [self.renderBackgroundView bringSubviewToFront:removeCameraView];
//        [self.renderBackgroundView bringSubviewToFront:removeScreenView];
//        self.pageControl.currentPage = 0;
//        return;
//    }
    
    [self.renderBackgroundView bringSubviewToFront:removeScreenView];
    [self.renderBackgroundView bringSubviewToFront:self.engine.previewView];
    self.pageControl.currentPage = 0;
}

// 大小窗口切换
- (void)exchangeWindowSize {
    
    if (self.renderBackgroundView.subviews.count == 2) {
        
        QNRoomUserView *removeCameraView = [self userViewWithTrackId:self.remoteCameraTrack.trackId];
        
        if (CGRectContainsRect(removeCameraView.frame, self.engine.previewView.frame)) {
            
            [self.engine.previewView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.renderBackgroundView);
            }];
            
            removeCameraView.showNameLabel = YES;
            [removeCameraView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.renderBackgroundView).offset(-20);
                make.top.equalTo(self.renderBackgroundView).offset(70);
                make.width.equalTo(120);
                make.height.equalTo(200);
            }];
            [self.renderBackgroundView bringSubviewToFront:removeCameraView];
            
        } else {
            removeCameraView.showNameLabel = NO;
            [removeCameraView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.renderBackgroundView);
            }];
            
            [self.engine.previewView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.renderBackgroundView).offset(-20);
                make.top.equalTo(self.renderBackgroundView).offset(70);
                make.width.equalTo(120);
                make.height.equalTo(200);
            }];
            [self.renderBackgroundView bringSubviewToFront:self.engine.previewView];
        }
    } else if (self.renderBackgroundView.subviews.count == 3) {
        
        QNRoomUserView *removeCameraView = [self userViewWithTrackId:self.remoteCameraTrack.trackId];
        QNRoomUserView *removeScreenView = [self userViewWithTrackId:self.remoteScreenTrack.trackId];
        
        if (self.pageControl.currentPage == 0) {
            
            if (CGRectContainsRect(removeScreenView.frame, self.engine.previewView.frame)){
                [self.engine.previewView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.edges.equalTo(self.renderBackgroundView);
                }];
                
                removeScreenView.showNameLabel = YES;
                [removeScreenView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(self.renderBackgroundView).offset(-20);
                    make.top.equalTo(self.renderBackgroundView).offset(70);
                    make.width.equalTo(120);
                    make.height.equalTo(200);
                }];
                [self.renderBackgroundView bringSubviewToFront:removeScreenView];
            } else {
                removeScreenView.showNameLabel = NO;
                [removeScreenView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.edges.equalTo(self.renderBackgroundView);
                }];
                
                [self.engine.previewView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(self.renderBackgroundView).offset(-20);
                    make.top.equalTo(self.renderBackgroundView).offset(70);
                    make.width.equalTo(120);
                    make.height.equalTo(200);
                }];
                [self.renderBackgroundView bringSubviewToFront:self.engine.previewView];
            }
            
            
        } else {
            if (CGRectContainsRect(removeCameraView.frame, self.engine.previewView.frame)){
                [self.engine.previewView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.edges.equalTo(self.renderBackgroundView);
                }];
                
                removeCameraView.showNameLabel = YES;
                [removeCameraView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(self.renderBackgroundView).offset(-20);
                    make.top.equalTo(self.renderBackgroundView).offset(70);
                    make.width.equalTo(120);
                    make.height.equalTo(200);
                }];
                [self.renderBackgroundView bringSubviewToFront:removeCameraView];
            } else {
                removeCameraView.showNameLabel = NO;
                [removeCameraView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.edges.equalTo(self.renderBackgroundView);
                }];
                
                [self.engine.previewView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(self.renderBackgroundView).offset(-20);
                    make.top.equalTo(self.renderBackgroundView).offset(70);
                    make.width.equalTo(120);
                    make.height.equalTo(200);
                }];
                [self.renderBackgroundView bringSubviewToFront:self.engine.previewView];
            }
        }
        
    }
    
    [UIView animateWithDuration:.3 animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];
}

- (void)addRenderViewToSuperView:(QNRoomUserView *)renderView {
    @synchronized(self.renderBackgroundView) {
        if (![[self.renderBackgroundView subviews] containsObject:renderView]) {
            [self.renderBackgroundView addSubview:renderView];
            
            [self resetRenderViews];
        }
    }
}

- (void)removeRenderViewFromSuperView:(QNRoomUserView *)renderView {
    @synchronized(self.renderBackgroundView) {
        if ([[self.renderBackgroundView subviews] containsObject:renderView]) {
            [renderView removeFromSuperview];
            
            [self resetRenderViews];
        }
    }
}

- (QNRoomUserView *)createUserViewWithTrackId:(NSString *)trackId userId:(NSString *)userId {
    QNRoomUserView *userView = [[QNRoomUserView alloc] init];
    userView.userId = userId;
    userView.trackId = trackId;
    return userView;
}

- (QNRoomUserView *)userViewWithTrackId:(NSString *)trackId {
    @synchronized(self.userViewArray) {
        for (QNRoomUserView *userView in self.userViewArray) {
            if ([userView.trackId isEqualToString:trackId]) {
                return userView;
            }
        }
    }
    return nil;
}

- (QNPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[QNPageControl alloc] init];
        _pageControl.frame = CGRectMake(kScreenWidth/2 - 25, kScreenHeight - 150, 50, 15);
        _pageControl.numberOfPages = 2;
        _pageControl.currentPage = 0;
        _pageControl.otherColor = [UIColor darkGrayColor];
        _pageControl.currentColor = [UIColor lightGrayColor];
        _pageControl.PageControlContentMode = QNPageControlContentModeLeft; //设置对齐方式
        _pageControl.controlSpacing = 3.0;
        _pageControl.marginSpacing = 10;
        _pageControl.controlSize = CGSizeMake(8, 8);//如果设置PageControlStyle,则失效
        [self.view addSubview:_pageControl];
        [self.view bringSubviewToFront:_pageControl];
    }
    return _pageControl;
}

#pragma mark - QNUserOperationViewDelegate

- (BOOL)userViewWantEnterFullScreen:(QNUserOperationView *)userview {
    
    if (2 == self.renderBackgroundView.subviews.count) {
        [self exchangeWindowSize];
        return NO;
    }
    return YES;
}


- (void)userView:(QNUserOperationView *)userview longPressWithUserId:(NSString *)userId {
    if (![self isAdmin]) {
        [self.view showFailTip:@"只有管理员可以踢人"];
        return;
    }
    if ([userId isEqualToString:self.userId]) return;
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
    }];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"踢出" style:(UIAlertActionStyleDestructive) handler:^(UIAlertAction * _Nonnull action) {
        [self.engine kickoutUser:userId];
    }];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"确定要将 %@ 踢出房间?", userId] message:nil preferredStyle:(UIAlertControllerStyleAlert)];
    [alert addAction:cancelAction];
    [alert addAction:sureAction];
                                
    [self presentViewController:alert animated:YES completion:nil];
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

@end
