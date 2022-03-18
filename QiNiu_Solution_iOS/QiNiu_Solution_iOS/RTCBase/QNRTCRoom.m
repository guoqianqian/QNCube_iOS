//
//  QNRTCRoom.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/9/23.
//

#import "QNRTCRoom.h"
#import "QNVideoTrackParams.h"
#import "QNAudioTrackParams.h"
#import "MBProgressHUD+QNShow.h"
#import <Masonry/Masonry.h>
#import "QNRTCRoomEntity.h"
#import <YYCategories/YYCategories.h>
#import "QNRTCRoomEntity.h"
#import "QNUserOperationView.h"
#import "QNRoomUserView.h"
#import "QNPageControl.h"

@interface QNRTCRoom ()<QNRTCClientDelegate,QNCameraTrackVideoDataDelegate,QNMicrophoneAudioTrackDataDelegate,QNScreenVideoTrackDelegate>

@property (nonatomic, strong) QNPageControl *pageControl;

@property (nonatomic, strong) NSMutableArray *userViewArray;

@end

@implementation QNRTCRoom

- (void)viewDidLoad {
    [super viewDidLoad];
}

//本地视频轨道参数
- (void)setUpLocalVideoParams:(QNVideoTrackParams *)videoTrackParams{
    
    // 视频
    CGSize videoEncodeSize = CGSizeMake(videoTrackParams.width, videoTrackParams.height);
    QNCameraVideoTrackConfig * cameraConfig = [[QNCameraVideoTrackConfig alloc] initWithSourceTag:@"camera" bitrate:videoTrackParams.bitrate videoEncodeSize:videoEncodeSize];
    self.localVideoTrack = [QNRTC createCameraVideoTrackWithConfig:cameraConfig];
    // 设置本地预览视图
    [self.localVideoTrack play:self.preview];
    // 设置采集视频的帧率
    self.localVideoTrack.videoFrameRate = videoTrackParams.fps;
    self.localVideoTrack.previewMirrorFrontFacing = NO;
    self.localVideoTrack.videoDelegate = self;
    [self.localVideoTrack startCapture];
//    self.localVideoTrack.fillMode = QNVideoFillModePreserveAspectRatio;
//     设置本地预览视图
    [self.localVideoTrack play:self.preview];
    
}

//- (void)joinRoom:(QNRTCRoomEntity *)roomEntity {
//    [super joinRoom:roomEntity];
//}

//本地音频轨道参数
- (void)setUpLocalAudioTrackParams:(QNAudioTrackParams *)audioTrackParams{
    
    self.localAudioTrack = [QNRTC createMicrophoneAudioTrack];
//    self.localAudioTrack.audioDelegate = self;
    [self.localAudioTrack setVolume:audioTrackParams.volume];
    self.localAudioTrack.tag = audioTrackParams.tag.length == 0 ? @"audio" : audioTrackParams.tag;
}

//- (void)joinRoom:(QNRTCRoomEntity *)roomEntity {
//    self.roomEntity = roomEntity;
//    [self.rtcClient join:self.roomEntity.provideRoomToken];
//}

//- (void)closeRoom {
//    [self dismissViewControllerAnimated:YES completion:nil];
//}
//
//- (void)leaveRoom {
//    [self.rtcClient leave];
//}

//启用视频模块
- (void)enableVideo{
    [self.localVideoTrack startCapture];

}

//不启用视频模块
- (void)disableVideo{
    [self.localVideoTrack stopCapture];
}

//是否打开摄像头
- (void)switchCamera:(BOOL)mute{

}

//关闭本地摄像头
- (void)muteLocalVideo:(BOOL)mute{
    [self.localVideoTrack updateMute:mute];

}

//关闭本地音频
- (void)muteLocalAudio:(BOOL)mute{    
    [self.localAudioTrack updateMute:mute];
}

//屏蔽远端某用户的视频流
- (void)muteRemoteVideo:(NSString *)uid mute:(BOOL)mute{
    
}
//屏蔽远端某用户的音频流
- (void)muteRemoteAudio:(NSString *)uid mute:(BOOL)mute{
    
}

//屏蔽所有用户音频
- (void)muteAllRemoteAudio:(BOOL)mute{
    
}
//屏蔽所有用户视频
- (void)muteAllRemoteVideo:(BOOL)mute{
    
}
//设置屏幕共享参数
- (void)setScreenTrackParams:(QNVideoTrackParams *)params{
    
    if (![QNScreenVideoTrack isScreenRecorderAvailable]) {
        [MBProgressHUD showText:@"当前设备不支持屏幕录制"];
        return;;
    }
    // 视频
    CGSize videoEncodeSize = CGSizeMake(params.width, params.height);
    QNScreenVideoTrackConfig * screenConfig = [[QNScreenVideoTrackConfig alloc] initWithSourceTag:@"screen" bitrate:params.bitrate videoEncodeSize:videoEncodeSize];
    self.localScreenTrack = [QNRTC createScreenVideoTrackWithConfig:screenConfig];
    // 设置采集视频的帧率
    self.localScreenTrack.screenRecorderFrameRate = params.fps;
    self.localScreenTrack.screenDelegate = self;
}
//发布本地屏幕共享
- (void)pubLocalScreenTrack{
    [self.rtcClient publish:@[self.localScreenTrack]];
}

//取消发布本地视频共享
- (void)unPubLocalScreenTrack{
    [self.rtcClient unpublish:@[self.localScreenTrack]];
}

//添加rtc事件监听
- (void)addExtraQNRTCEngineEventListener:(id<QNRTCClientDelegate>)listener{
    
}
//移除rtc事件监听
- (void)removeExtraQNRTCEngineEventListener:(id<QNRTCClientDelegate>)listener{
    
}

//设置美颜参数
- (void)setDefaultBeauty:(NSDictionary *)beautySetting{
    
}

//设置预览窗口
- (void)setlocalCameraWindowView:(UIView *)faceView{
    
}

- (void)setUserCameraWindowView:(UIView *)faceView uid:(NSString *)uid{
    
}
- (void)setUserScreenWindowView:(UIView *)faceView uid:(NSString *)uid{
    
}
- (void)setUserExtraTrackWindowView:(UIView *)faceView uid:(NSString *)uid trackTag:(NSString *)trackTag{
    
}

//获取混流器
- (void)getMixStreamHelper{
    
}

//获取用户视频Track
- (QNTrackInfo *)getUserVideoTrackInfo:(NSString *)uid{
    return nil;
}
//获取用户音频Track
- (QNTrackInfo *)getUserAudioTrackInfo:(NSString *)uid{
    return nil;
}
//获取用户屏幕共享Track
- (QNTrackInfo *)getUserScreenTrackInfo:(NSString *)uid{
    return nil;
}
//获取自定义Track
- (QNTrackInfo *)getUserExtraTrackInfo:(NSString *)uid extraTrackTag:(NSString *)extraTrackTag{
    return nil;
}

- (void)clearUserInfo:(NSString *)userId {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (NSInteger i = self.userViewArray.count - 1; i >= 0; i--) {
            QNUserOperationView *userView = self.userViewArray[i];
            if ([userView.userId isEqualToString:userId]) {
                [userView removeFromSuperview];
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
            [self.preview mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.view);
            }];
            
        } else if (2 == allRenderView.count) {
            self.pageControl.hidden = YES;
            
            for (QNRoomUserView *view in allRenderView) {
                if ([view.class isEqual:[QNRoomUserView class]]) {
                    view.showNameLabel = NO;
                    [view mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.edges.equalTo(self.view);
                    }];
                }
            }
            
            [self.preview mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.view).offset(-20);
                make.top.equalTo(self.view).offset(70);
                make.width.mas_equalTo(120);
                make.height.mas_equalTo(200);
            }];
            
            [self.renderBackgroundView bringSubviewToFront:self.preview];
        }else if (3 == allRenderView.count) {
            self.pageControl.hidden = NO;
            self.pageControl.currentPage = 0;
            //对方屏幕分享
            QNRoomUserView *removeScreenView = [self userViewWithTrackId:self.remoteScreenTrack.trackID];
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
            [self.preview mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.view).offset(-20);
                make.top.equalTo(self.view).offset(70);
                make.width.mas_equalTo(120);
                make.height.mas_equalTo(200);
            }];
            
            //对方视图
            QNRoomUserView *removeCameraView = [self userViewWithTrackId:self.remoteCameraTrack.trackID];
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
            [self.renderBackgroundView bringSubviewToFront:self.preview];
            
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
                    make.height.mas_equalTo(view.width);
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
    QNRoomUserView *removeCameraView = [self userViewWithTrackId:self.remoteCameraTrack.trackID];
    QNRoomUserView *removeScreenView = [self userViewWithTrackId:self.remoteScreenTrack.trackID];

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
    [self.renderBackgroundView bringSubviewToFront:self.preview];
    self.pageControl.currentPage = 1;
    
}

- (void)rightSwipe {
    
    QNRoomUserView *removeCameraView = [self userViewWithTrackId:self.remoteCameraTrack.trackID];
    QNRoomUserView *removeScreenView = [self userViewWithTrackId:self.remoteScreenTrack.trackID];
    
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
    [self.renderBackgroundView bringSubviewToFront:self.preview];
    self.pageControl.currentPage = 0;
}

// 大小窗口切换
- (void)exchangeWindowSize {
    
    if (self.renderBackgroundView.subviews.count == 2) {
        
        QNRoomUserView *removeCameraView = [self userViewWithTrackId:self.remoteCameraTrack.trackID];
        
        if (CGRectContainsRect(removeCameraView.frame, self.preview.frame)) {
            
            [self.preview mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.renderBackgroundView);
            }];
            
            removeCameraView.showNameLabel = YES;
            [removeCameraView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.renderBackgroundView).offset(-20);
                make.top.equalTo(self.renderBackgroundView).offset(70);
                make.width.mas_equalTo(120);
                make.height.mas_equalTo(200);
            }];
            [self.renderBackgroundView bringSubviewToFront:removeCameraView];
            
        } else {
            removeCameraView.showNameLabel = NO;
            [removeCameraView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.renderBackgroundView);
            }];
            
            [self.preview mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.renderBackgroundView).offset(-20);
                make.top.equalTo(self.renderBackgroundView).offset(70);
                make.width.mas_equalTo(120);
                make.height.mas_equalTo(200);
            }];
            [self.renderBackgroundView bringSubviewToFront:self.preview];
        }
    } else if (self.renderBackgroundView.subviews.count == 3) {
        
        QNRoomUserView *removeCameraView = [self userViewWithTrackId:self.remoteCameraTrack.trackID];
        QNRoomUserView *removeScreenView = [self userViewWithTrackId:self.remoteScreenTrack.trackID];
        
        if (self.pageControl.currentPage == 0) {
            
            if (CGRectContainsRect(removeScreenView.frame, self.preview.frame)){
                [self.preview mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.edges.equalTo(self.renderBackgroundView);
                }];
                
                removeScreenView.showNameLabel = YES;
                [removeScreenView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(self.renderBackgroundView).offset(-20);
                    make.top.equalTo(self.renderBackgroundView).offset(70);
                    make.width.mas_equalTo(120);
                    make.height.mas_equalTo(200);
                }];
                [self.renderBackgroundView bringSubviewToFront:removeScreenView];
            } else {
                removeScreenView.showNameLabel = NO;
                [removeScreenView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.edges.equalTo(self.renderBackgroundView);
                }];
                
                [self.preview mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(self.renderBackgroundView).offset(-20);
                    make.top.equalTo(self.renderBackgroundView).offset(70);
                    make.width.mas_equalTo(120);
                    make.height.mas_equalTo(200);
                }];
                [self.renderBackgroundView bringSubviewToFront:self.preview];
            }
            
            
        } else {
            if (CGRectContainsRect(removeCameraView.frame, self.preview.frame)){
                [self.preview mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.edges.equalTo(self.renderBackgroundView);
                }];
                
                removeCameraView.showNameLabel = YES;
                [removeCameraView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(self.renderBackgroundView).offset(-20);
                    make.top.equalTo(self.renderBackgroundView).offset(70);
                    make.width.mas_equalTo(120);
                    make.height.mas_equalTo(200);
                }];
                [self.renderBackgroundView bringSubviewToFront:removeCameraView];
            } else {
                removeCameraView.showNameLabel = NO;
                [removeCameraView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.edges.equalTo(self.renderBackgroundView);
                }];
                
                [self.preview mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(self.renderBackgroundView).offset(-20);
                    make.top.equalTo(self.renderBackgroundView).offset(70);
                    make.width.mas_equalTo(120);
                    make.height.mas_equalTo(200);
                }];
                [self.renderBackgroundView bringSubviewToFront:self.preview];
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
        for (QNRoomUserView *userView in self.renderBackgroundView.subviews) {
            if ([userView.class isEqual:[QNGLKView class]]) {
                return nil;
            }
            if ([userView.trackId isEqualToString:trackId]) {
                return userView;
            }
        }
    }
    return nil;
}

- (NSMutableArray *)userViewArray {
    if (!_userViewArray) {
        _userViewArray = self.renderBackgroundView.subviews;
    }
    return _userViewArray;
}

@end
