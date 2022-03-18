//
//  QNInterviewViewController.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/4/13.
//

#import "QNInterviewViewController.h"
#import "QNInterViewListModel.h"
#import "QNJoinInterviewModel.h"
#import <MJExtension/MJExtension.h>
#import <ReplayKit/ReplayKit.h>
#import "NSArray+Sudoku.h"
#import <QNRTCKit/QNRTCKit.h>
#import "QNNetworkUtil.h"
#import <YYCategories/YYCategories.h>
#import "QNRoomUserView.h"
#import "RCChatRoomView.h"
#import "QNIMMessageModel.h"
#import "MBProgressHUD+QNShow.h"
#import <SDWebImage/SDWebImage.h>
#import "QNInterviewListViewModel.h"
#import "QNRTCRoomEntity.h"
#import "QNAudioTrackParams.h"
#import "QNVideoTrackParams.h"

#define QN_DELAY_MS 5000

@interface QNInterviewViewController ()<QNIMChatServiceProtocol,UIGestureRecognizerDelegate,QNRTCClientDelegate,RCCRInputBarControlDelegate>

@property (nonatomic, strong) NSString *mergeJobId;
@property (nonatomic, strong) UIView *buttonView;
@property (nonatomic, strong) QNJoinInterviewModel *interviewModel;
@property (nonatomic, strong) NSMutableArray *viewsArray;

@property (nonatomic, strong) QNSendMsgTool *sendMsgTool;
@property (nonatomic, strong) RCChatRoomView * chatRoomView;
@property (nonatomic, strong) UIButton *commentButton;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *screenShareButton;//屏幕共享
@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UIImageView *titleImageView;//自己关闭摄像头时显示头像

@property (nonatomic, strong) QNTranscodingLiveStreamingConfig *mergeConfig;//多路
@property (nonatomic, strong) NSMutableArray<QNTranscodingLiveStreamingTrack *> *layouts;
@property (nonatomic, strong) QNTranscodingLiveStreamingTrack *selfCameraLayout;
@property (nonatomic, strong) QNTranscodingLiveStreamingTrack *selfScreenLayout;
@property (nonatomic, strong) QNTranscodingLiveStreamingTrack *remoteCameraLayout;
@property (nonatomic, strong) QNTranscodingLiveStreamingTrack *remoteScreenLayout;

@end

@implementation QNInterviewViewController

- (void)viewDidDisappear:(BOOL)animated {
    // 离开房间
    [self leaveRoom];
    [self.rtcClient stopLiveStreamingWithTranscoding:self.mergeConfig];
    
    [super viewDidDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[QNIMChatService sharedOption] addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    [self requestToken];
    [self requestRoomHeartBeatWithInterval:1];
    [self setupTopButtons];
    [self setupBottomButtons];
    [self setupLeftButtons];
    [self setupIMUI];

}

//请求进入面试房间token
- (void)requestToken {
    
    __weak typeof(self) weakSelf = self;
    
    NSString *action = [NSString stringWithFormat:@"joinInterview/%@",self.interviewInfoModel.ID];
    [QNNetworkUtil postRequestWithAction:action params:nil success:^(NSDictionary *responseData) {
          
        if (responseData[@"code"]) {
            [MBProgressHUD showText:responseData[@"message"]];
            
        } else {
            self.interviewModel = [QNJoinInterviewModel mj_objectWithKeyValues:responseData];
            self.interviewModel.userInfo = [QNJoinInterViewUserInfoModel mj_objectArrayWithKeyValuesArray:weakSelf.interviewModel.userInfo.mj_keyValues];
            self.interviewModel.onlineUserList = [QNJoinInterViewUserInfoModel mj_objectArrayWithKeyValuesArray:weakSelf.interviewModel.onlineUserList.mj_keyValues];
            self.interviewModel.allUserList = [QNJoinInterViewUserInfoModel mj_objectArrayWithKeyValuesArray:weakSelf.interviewModel.allUserList.mj_keyValues];
            
            [self joinInterViewRoom];
            
        }
                
    } failure:^(NSError *error) {
        [MBProgressHUD showText:@"请求roomToken出错"];
    }];
}

//进房
- (void)joinInterViewRoom {
        
    QNAudioTrackParams *param = [QNAudioTrackParams new];
    param.volume = 0.5;
    [self setUpLocalAudioTrackParams:param];
        
    QNVideoTrackParams *params = [QNVideoTrackParams new];
    params.width = 540;
    params.height = 960;
    [self setUpLocalVideoParams:params];
    [self.localVideoTrack startCapture];
    [self.localVideoTrack play:self.preview];
    
    QNRTCRoomEntity *room = [[QNRTCRoomEntity alloc]init];
    room.providePushUrl = [NSString stringWithFormat:@"rtmp://pili-publish.qnsdk.com/sdk-live/%@", self.interviewInfoModel.ID];
    room.provideRoomToken = self.interviewModel.roomToken;
    room.provideMeId = [[NSUserDefaults standardUserDefaults] objectForKey:QN_ACCOUNT_ID_KEY];
    self.roomEntity = room;
    [self joinRoom:self.roomEntity];
        
    self.rtcClient.delegate = self;
    
    self.nameLabel.hidden = YES;
    
    self.preview.userInteractionEnabled = YES;

    //双击切换大小窗
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(exchangeWindowSize)];
    tap.numberOfTapsRequired = 2;
    [self.preview addGestureRecognizer:tap];
    
    [[QNIMGroupService sharedOption] joinGroupWithGroupId:self.interviewModel.imConfig.imGroupId message:@"" completion:^(QNIMError * _Nonnull error) {
        QNIMMessageObject *message = [self.sendMsgTool createJoinRoomMessage];
        [[QNIMChatService sharedOption] sendMessage:message];
        [self.chatRoomView sendMessage:message];
    }];
}

- (void)receivedMessages:(NSArray<QNIMMessageObject *> *)messages {    
    [self.chatRoomView showMessage:messages.firstObject];
}

// 离开房间
- (void)requestLeaveInterviewRoom {
    __weak typeof(self) weakSelf = self;
    
    NSString *action = [NSString stringWithFormat:@"leaveInterview/%@",self.interviewInfoModel.ID];
    [QNNetworkUtil postRequestWithAction:action params:nil success:^(NSDictionary *responseData) {
        
        if (weakSelf.popBlock) {
            weakSelf.popBlock();
        }
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
        
    } failure:^(NSError *error) {
        [MBProgressHUD showText:error.description];
    }];
}

//面试房间心跳
- (void)requestRoomHeartBeatWithInterval:(NSInteger)interval {
    __weak typeof(self) weakSelf = self;
    
    NSString *action = [NSString stringWithFormat:@"heartBeat/%@",self.interviewInfoModel.ID];
    [QNNetworkUtil getRequestWithAction:action params:nil success:^(NSDictionary *responseData) {
        
        QNJoinInterviewModel *heartBeatModel = [QNJoinInterviewModel mj_objectWithKeyValues:responseData];
        if (heartBeatModel.options.showLeaveInterview) {
            weakSelf.closeButton.hidden = NO;
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(heartBeatModel.interval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf requestRoomHeartBeatWithInterval:heartBeatModel.interval];
        });
    } failure:^(NSError *error) {
        [MBProgressHUD showText:error.description];
    }];
    
}



//开始屏幕共享
- (void)beginScreenShare {
    _screenShareButton.selected = !_screenShareButton.isSelected;

    QNScreenVideoTrackConfig * screenConfig = [[QNScreenVideoTrackConfig alloc] initWithSourceTag:@"screen" bitrate:self.bitrate videoEncodeSize:self.videoEncodeSize];
    self.localScreenTrack = [QNRTC createScreenVideoTrackWithConfig:screenConfig];
                             
    if (self.localScreenTrack) {
        if (_screenShareButton.selected) {
            [self.rtcClient publish:@[self.localScreenTrack] completeCallback:^(BOOL onPublished, NSError *error) {
                
                self.selfScreenLayout = [[QNTranscodingLiveStreamingTrack alloc] init];
                self.selfScreenLayout.trackId = self.localScreenTrack.trackID;
                self.selfScreenLayout.frame = CGRectMake(480, 0, 240, 430);
                self.selfScreenLayout.zIndex = 0;
                [self.layouts addObject:self.selfScreenLayout];
                
                [self removeSameLayoutsAndMergeStreamLayouts];
            }];
        } else {
            [self.rtcClient unpublish:@[self.localScreenTrack]];
            self.selfScreenLayout = nil;
            [self.layouts removeObject:self.selfScreenLayout];
            [self removeSameLayoutsAndMergeStreamLayouts];
        }
    }
}

// 退出房间
- (void)conferenceAction:(UIButton *)conferenceButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// 打开/关闭音频
- (void)microphoneAction:(UIButton *)microphoneButton {
    microphoneButton.selected = !microphoneButton.isSelected;
    [self muteLocalAudio:!microphoneButton.isSelected];
}

// 打开/关闭视频画面
- (void)videoAction:(UIButton *)videoButton {
    videoButton.selected = !videoButton.isSelected;
    NSMutableArray *videoTracks = [[NSMutableArray alloc] init];
    if (self.localVideoTrack) {
        [videoTracks addObject:self.localVideoTrack];
        [self muteLocalVideo:!videoButton.isSelected];
    }
    [self muteLocalVideo:!videoButton.isSelected];
    // 对应实际关闭连麦视频画面的场景 可根据需求显示或隐藏摄像头采集的预览视图
    self.preview.hidden = !videoButton.isSelected;
    self.titleImageView.hidden = videoButton.isSelected;
}



//分享面试
- (void)shareInterviewRoom {
    NSURL *imageUrl = [NSURL URLWithString:self.interviewInfoModel.shareInfo.icon];
    NSData *dateImg = [NSData dataWithContentsOfURL:imageUrl];
    UIImage *imageToShare = [UIImage sd_imageWithData:dateImg];
    NSURL *urlToShare = [NSURL URLWithString:self.interviewInfoModel.shareInfo.url];
    NSArray *activityItems = @[self.interviewInfoModel.shareInfo.content, imageToShare, urlToShare];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];
    [self presentViewController:activityVC animated:YES completion:nil];
}

//点击评论
- (void)comment {
    UITapGestureRecognizer *resetBottomTapGesture =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(resetBottomGesture:)];
    resetBottomTapGesture.delegate = self;
    [self.view addGestureRecognizer:resetBottomTapGesture];
    [self.chatRoomView.inputBar setHidden:NO];
    [self.chatRoomView.inputBar  setInputBarStatus:RCCRBottomBarStatusKeyboard];
    self.chatRoomView.inputBar.delegate = self;
}

- (void)onTouchSendButton:(NSString *)text {
    
    QNIMMessageObject *message = [self.sendMsgTool createChatMessage:text];
    [[QNIMChatService sharedOption] sendMessage:message];
    [self.chatRoomView sendMessage:message];
}

- (void)resetBottomGesture:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self.chatRoomView setDefaultBottomViewStatus];
        [self.view removeGestureRecognizer:gestureRecognizer];
    }
}

//离开房间
- (void)closeRoom {
    
    QNIMMessageObject *message = [self.sendMsgTool createLeaveRoomMessage];
    [[QNIMChatService sharedOption] sendMessage:message];
    [self.chatRoomView sendMessage:message];
    
    [self requestLeaveInterviewRoom];
}

//结束面试
- (void)endInterview {
    __weak typeof(self) weakSelf = self;
    [QNInterviewListViewModel requestEndInterviewWithInterviewId:self.interviewInfoModel.ID endBlock:^{
        if (weakSelf.popBlock) {
            weakSelf.popBlock();
        }
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    }];
}

# pragma mark - IM

- (void)setupIMUI {
    CGFloat bottomExtraDistance  = 0;
    if (@available(iOS 11.0, *)) {
        bottomExtraDistance = [self getIPhonexExtraBottomHeight];
    }
    self.chatRoomView = [[RCChatRoomView alloc] initWithFrame:CGRectMake(0, kScreenHeight - (237 +50)  - bottomExtraDistance, kScreenWidth, 237+50)];
    
    self.chatRoomView.commentBtn = self.commentButton;
    [self.view insertSubview:self.chatRoomView atIndex:2];

}

- (float)getIPhonexExtraBottomHeight {
    float height = 0;
    if (@available(iOS 11.0, *)) {
        height = [[[UIApplication sharedApplication] keyWindow] safeAreaInsets].bottom;
    }
    return height;
}


//layout去重
- (void)removeSameLayoutsAndMergeStreamLayouts {

    if (self.interviewInfoModel.roleCode == 1) {
        NSMutableArray<QNTranscodingLiveStreamingTrack *> *array = [NSMutableArray array];
        for (QNTranscodingLiveStreamingTrack *layout in self.layouts) {
            if (![array containsObject:layout]) {
                [array addObject:layout];
            }
        }
        self.layouts = array;
        [self resetLayout];
    }
    
}

//layout布局
- (void)resetLayout {
        
    //只有自己的视频流推送的情况下，调整视频frame
    if (self.remoteCameraLayout.trackId.length == 0 && !self.remoteScreenLayout && self.selfCameraLayout) {
        QNTranscodingLiveStreamingTrack *selfLayout = self.selfCameraLayout;
        selfLayout.frame = CGRectMake(0, 0, 720, 1280);
        selfLayout.zIndex = 2;
        [self.layouts removeObject:self.selfCameraLayout];
        [self.layouts addObject:selfLayout];
        self.selfCameraLayout = selfLayout;
    }
    
    if (self.remoteCameraLayout && !self.remoteScreenLayout) {
        
        QNTranscodingLiveStreamingTrack *selfCameraLayout = self.selfCameraLayout;
        selfCameraLayout.frame = CGRectMake(480, 0, 240, 430);
        selfCameraLayout.zIndex = 2;
        [self.layouts removeObject:self.selfCameraLayout];
        
        if (self.selfCameraLayout) {
            [self.layouts addObject:selfCameraLayout];
        }        
        
        self.selfCameraLayout = selfCameraLayout;
        
        QNTranscodingLiveStreamingTrack *remoteCameraLayout = self.remoteCameraLayout;
        remoteCameraLayout.frame = CGRectMake(0, 0, 720, 1280);
        self.remoteCameraLayout.zIndex = 1;
        [self.layouts removeObject:self.remoteCameraLayout];
        [self.layouts addObject:remoteCameraLayout];
        
        self.remoteCameraLayout = remoteCameraLayout;
        
    }
    
    NSMutableArray *mergeArray = [NSMutableArray arrayWithArray:self.layouts];
    
    //远端用户有屏幕共享的情况下，不推远端用户的视频画面
    if (self.remoteScreenLayout) {
        [mergeArray removeObject:self.remoteCameraLayout];
    }
    
    if (self.selfScreenLayout) {
        [mergeArray removeObject:self.selfCameraLayout];
    }
    [self.rtcClient setTranscodingLiveStreamingID:self.interviewInfoModel.ID withTracks:mergeArray];
}

#pragma mark - 代理回调

- (void)RTCClient:(QNRTCClient *)client didStartLiveStreamingWith:(NSString *)streamID {
    
    
}

/*房间内状态变化的回调*/
- (void)RTCClient:(QNRTCClient *)client didConnectionStateChanged:(QNConnectionState)state disconnectedInfo:(QNConnectionDisconnectedInfo *)info {
        
        if (QNConnectionStateConnected == state) {

            if (self.interviewInfoModel.roleCode == 1) {
                [self.rtcClient startLiveStreamingWithTranscoding:self.mergeConfig];
            }
            
            // 发布音视频
            [self.rtcClient publish:@[self.localAudioTrack, self.localVideoTrack] completeCallback:^(BOOL onPublished, NSError *error) {
                
                //自己的音频
                QNTranscodingLiveStreamingTrack *audioLayout = [[QNTranscodingLiveStreamingTrack alloc] init];
                audioLayout.trackId = self.localAudioTrack.trackID;
                [self.layouts addObject:audioLayout];
//                自己的摄像头
                self.selfCameraLayout = [[QNTranscodingLiveStreamingTrack alloc]init];
                self.selfCameraLayout.trackId = self.localVideoTrack.trackID;
                self.selfCameraLayout.frame = CGRectMake(480, 0, 240, 430);
                self.selfCameraLayout.zIndex = 2;
                
                [self removeSameLayoutsAndMergeStreamLayouts];
                
            }];
            
            
                        
        } else if (QNConnectionStateReconnecting == state) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD showText:@"正在重新连接..."];
            });
        }  else if (QNConnectionStateReconnected == state) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD showText:@"重新连接成功"];
            });
        }

}

- (void)RTCClient:(QNRTCClient *)client didUserPublishTracks:(NSArray<QNRemoteTrack *> *)tracks ofUserID:(NSString *)userID {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
            for (QNRemoteTrack *trackInfo in tracks) {
                
                QNRoomUserView *userView = [self userViewWithTrackId:trackInfo.trackID] ;
                QNTrack *tempInfo = [userView trackInfoWithTrackId:trackInfo.trackID];
                                            
                if (trackInfo.kind == QNTrackKindAudio) {
                    self.remoteAudioTrack = (QNRemoteAudioTrack *)trackInfo;
                    QNTranscodingLiveStreamingTrack *audioLayout = [[QNTranscodingLiveStreamingTrack alloc] init];
                    audioLayout.trackId = trackInfo.trackID;
                    [self.layouts addObject:audioLayout];
                }
                
                if (trackInfo.kind == QNTrackKindVideo) {
                                    
                    if ([trackInfo.tag isEqualToString:screenTag]) {
                        self.remoteScreenTrack = (QNRemoteVideoTrack *)trackInfo;
                        [self.layouts removeObject:self.remoteScreenLayout];
                        self.remoteScreenLayout = [[QNTranscodingLiveStreamingTrack alloc] init];
                        self.remoteScreenLayout.trackId = trackInfo.trackID;
                        self.remoteScreenLayout.frame = CGRectMake(0, 0, 720, 1280);
                        self.remoteScreenLayout.zIndex = 0;
                        [self.layouts addObject:self.remoteScreenLayout];
                        
                        self.screenShareButton.selected = YES;
                        self.screenShareButton.userInteractionEnabled = NO;
                        
                    } else {
                        
                        self.remoteCameraTrack = (QNRemoteVideoTrack *)trackInfo;
                        [self.layouts removeObject:self.remoteCameraLayout];
                        self.remoteCameraLayout = [[QNTranscodingLiveStreamingTrack alloc] init];
                        self.remoteCameraLayout.trackId = trackInfo.trackID;
                        self.remoteCameraLayout.frame = CGRectMake(0, 0, 720, 1280);
                        self.remoteCameraLayout.zIndex = 1;
                        [self.layouts addObject:self.remoteCameraLayout];
                        
                    }
                    
                                    
                    if (!userView) {
                        userView = [self createUserViewWithTrackId:trackInfo.trackID userId:userID];
                        userView.trackId = trackInfo.trackID;
                        userView.userId = userID;
                        if ([trackInfo.tag isEqualToString:screenTag]) {
                            [self.remoteScreenTrack play:userView.cameraView];
                        } else {
                            [self.remoteCameraTrack play:userView.cameraView];
                        }
                        for (QNJoinInterViewUserInfoModel *user in self.interviewModel.allUserList) {
                            if ([user.accountId isEqualToString:userID]) {
                                userView.avatar = user.avatar;
                                userView.userName = user.nickname;
                            }
                        }
                        userView.showImageView = NO;
                        __weak typeof(self) weakSelf = self;
                        userView.changeSizeBlock = ^{
                            [weakSelf exchangeWindowSize];
                        };
                        [self addRenderViewToSuperView:userView];
                    }
                }
                [userView showCameraView];
                if (nil == userView.superview) {
                    [self addRenderViewToSuperView:userView];
                }
                
                if (tempInfo) {
                    [userView.traks removeObject:tempInfo];
                }
                [userView.traks addObject:trackInfo];
                
            }
            [self removeSameLayoutsAndMergeStreamLayouts];
            self.nameLabel.hidden = NO;
        
        
        
    });
    
}



///* 远端用户视频状态变更的回调 */
//- (void)RTCEngine:(QNRTCEngine *)engine didVideoMuted:(BOOL)muted ofTrackId:(nonnull NSString *)trackId byRemoteUserId:(nonnull NSString *)userId {
//    dispatch_async(dispatch_get_main_queue(), ^{
//        QNRoomUserView *userView = [self userViewWithTrackId:trackId];
//        userView.showImageView = muted;
//    });
//}
//
///* 被踢出房间的回调 */
//- (void)RTCEngine:(QNRTCEngine *)engine didKickoutByUserId:(NSString *)userId {
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self dismissViewControllerAnimated:YES completion:nil];
//    });
//}

/*!
 * @abstract 远端用户取消发布音/视频的回调。
 *
 * @since v4.0.0
 */
- (void)RTCClient:(QNRTCClient *)client didUserUnpublishTracks:(NSArray<QNRemoteTrack *> *)tracks ofUserID:(NSString *)userID {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (QNRemoteTrack *trackInfo in tracks) {
            QNRoomUserView *userView = [self userViewWithTrackId:trackInfo.trackID];
            QNTrack *tempInfo = [userView trackInfoWithTrackId:trackInfo.trackID];
            
            if (trackInfo.kind == QNTrackKindVideo) {
                
                if ([trackInfo.tag isEqualToString:screenTag]) {
                    [self.layouts removeObject:self.remoteScreenLayout];
                    self.remoteScreenLayout = nil;
                    
                    self.screenShareButton.selected = NO;
                    self.screenShareButton.userInteractionEnabled = YES;
                    
                } else {
                    [self.layouts removeObject:self.remoteCameraLayout];
                    self.remoteCameraLayout = nil;
                }
            }
            
            [self removeSameLayoutsAndMergeStreamLayouts];
            
            if (tempInfo) {
                [userView.traks removeObject:tempInfo];
                
                if (0 == userView.traks.count) {
                    [self removeRenderViewFromSuperView:userView];
                }
            }
        }
    });
}

/* 远端用户离开房间的回调 */
- (void)RTCClient:(QNRTCClient *)client didLeaveOfUserID:(NSString *)userID
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.nameLabel.hidden = YES;
        
        [self.layouts removeObject:self.remoteCameraLayout];
        self.remoteCameraLayout = nil;
        [self.layouts removeObject:self.remoteScreenLayout];
        self.remoteScreenLayout = nil;
        [self removeSameLayoutsAndMergeStreamLayouts];
    });
    
}

/* @abstract 远端用户发生重连的回调。*/
- (void)RTCClient:(QNRTCClient *)client didReconnectingOfUserID:(NSString *)userID {
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD showText:@"对方正在重新连接..."];
    });
    
}

/* @abstract 远端用户重连成功的回调。*/
- (void)RTCClient:(QNRTCClient *)client didReconnectedOfUserID:(nonnull NSString *)userID {
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD showText:@"对方已经重新连接"];
    });
}

/* 远端用户首帧解码后的回调（仅在远端用户发布视频时会回调） */

- (void)RTCClient:(QNRTCClient *)client firstVideoDidDecodeOfTrack:(QNRemoteVideoTrack *)videoTrack remoteUserID:(NSString *)userID {
    
    if ([videoTrack.tag isEqualToString:@"camera"]) {
        self.remoteCameraTrack = videoTrack;
    } else if ([videoTrack.tag isEqualToString:@"screen"]) {
        self.remoteScreenTrack = videoTrack;
    }

    QNRoomUserView *roomView = [self createUserViewWithTrackId:videoTrack.trackID userId:userID];
    roomView.trackId = videoTrack.trackID;
    roomView.userId = userID;
//    [videoTrack play:roomView.cameraView];
//    QNRoomUserView *roomView = [[QNRoomUserView alloc]initWithFrame:self.view.frame];
    roomView.trackId = videoTrack.trackID;
    roomView.userId = userID;
    [videoTrack play:roomView.cameraView];
    [super addRenderViewToSuperView:roomView];
//    [roomView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.top.right.bottom.equalTo(self.renderBackgroundView);
//    }];
    
}


/*远端用户视频取消渲染到 renderView 上的回调 */

- (void)RTCClient:(QNRTCClient *)client didDetachRenderTrack:(QNRemoteVideoTrack *)videoTrack remoteUserID:(NSString *)userID {
    dispatch_async(dispatch_get_main_queue(), ^{
        QNRoomUserView *userView = [self userViewWithTrackId:videoTrack.trackID];
        if (userView) {
            [self removeRenderViewFromSuperView:userView];
        }
    });
}

#pragma mark - buttons action

- (void)setupBottomButtons {
    
    UIView *bottomButtonView = [[UIView alloc] init];
    [self.view addSubview:bottomButtonView];
    [bottomButtonView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.mas_bottomLayoutGuide).offset(-15);
        make.height.mas_equalTo(100);
    }];
        
    NSString *selectedImage[] = {@"microphone", @"close-phone",@"video-open"};
    NSString *normalImage[] = {@"microphone-disable",@"close-phone",@"video-close"};
    SEL selectors[] = {@selector(microphoneAction:),@selector(conferenceAction:),@selector(videoAction:)};
    
    CGFloat buttonWidth = 54;
    NSInteger space = (kScreenWidth - buttonWidth * 3)/4;
    
    for (int i = 0; i < ARRAY_SIZE(normalImage); i ++) {
        UIButton *button = [[UIButton alloc] init];
        [button setImage:[UIImage imageNamed:selectedImage[i]] forState:(UIControlStateSelected)];
        [button setImage:[UIImage imageNamed:normalImage[i]] forState:(UIControlStateNormal)];
        [button addTarget:self action:selectors[i] forControlEvents:(UIControlEventTouchUpInside)];
        button.selected = YES;
        [bottomButtonView addSubview:button];
    }
    
    [bottomButtonView.subviews mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:space leadSpacing:space tailSpacing:space];
    [bottomButtonView.subviews mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(bottomButtonView);
        make.width.height.mas_equalTo(buttonWidth);
    }];
}

- (void)setupLeftButtons {
    
    _screenShareButton =  [[UIButton alloc]init];
    [_screenShareButton setImage:[UIImage imageNamed:@"icon_share_open"] forState:UIControlStateNormal];
    [_screenShareButton setImage:[UIImage imageNamed:@"icon_share_close"] forState:UIControlStateSelected];
    [_screenShareButton addTarget:self action:@selector(beginScreenShare) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_screenShareButton];
    
    [_screenShareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(40);
        make.top.equalTo(self.view).offset(150);
    }];

}

- (void)setupTopButtons {
        
    UILabel *titleLabel = [[UILabel alloc]init];
    titleLabel.text = self.interviewInfoModel.title;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(40);
        make.height.mas_equalTo(20);
    }];
    
    NSMutableArray *imageNames = [NSMutableArray arrayWithObject:@"icon_chat"];
    NSMutableArray *selectors = [NSMutableArray arrayWithObject:@"comment"];
    
    if ([self.interviewInfoModel.role isEqualToString:@"面试官"]) {
        [imageNames insertObject:@"icon_share" atIndex:0];
        [selectors insertObject:@"shareInterviewRoom" atIndex:0];
    }
    
    for (int i = 0; i < imageNames.count; i ++) {
        UIButton *button = [[UIButton alloc] init];
        [button setImage:[UIImage imageNamed:imageNames[i]] forState:(UIControlStateNormal)];
        [button addTarget:self action:NSSelectorFromString(selectors[i]) forControlEvents:(UIControlEventTouchUpInside)];
        [self.view addSubview:button];
        
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(titleLabel);
            make.right.equalTo(self.view).offset(- 25 - 30 * i);
        }];
    }
    
    [self closeButton];

}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [[UIButton alloc]init];
        [_closeButton setImage:[UIImage imageNamed:@"icon_quit"] forState:(UIControlStateNormal)];
        [_closeButton addTarget:self action:@selector(endInterview) forControlEvents:UIControlEventTouchUpInside];
        _closeButton.hidden = YES;
        [self.view addSubview:_closeButton];
        [_closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).offset(40);
            make.left.equalTo(self.view).offset(20);
            make.height.mas_equalTo(30);
        }];
    }
    return _closeButton;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.numberOfLines = 0;
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.adjustsFontSizeToFitWidth = YES;
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.font = [UIFont systemFontOfSize:11];
        _nameLabel.backgroundColor = [[UIColor colorWithHexString:@"000000"]colorWithAlphaComponent:0.5];
        self.nameLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:QN_NICKNAME_KEY];
        _nameLabel.hidden = YES;
        [self.preview addSubview:_nameLabel];

        [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.left.right.mas_equalTo(self.preview);
            make.height.mas_equalTo(20);
        }];
    }
    return _nameLabel;
}

- (UIImageView *)titleImageView {
    if (!_titleImageView) {
        _titleImageView = [[UIImageView alloc]init];
        [self.view addSubview:_titleImageView];
        for (QNJoinInterViewUserInfoModel *user in self.interviewModel.allUserList) {
            if ([user.accountId isEqualToString:QN_ACCOUNT_ID_KEY]) {
                [_titleImageView sd_setImageWithURL:[NSURL URLWithString:user.avatar]];
            }
        }
        [_titleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    return _titleImageView;
}

- (QNTranscodingLiveStreamingConfig *)mergeConfig {
    if (!_mergeConfig) {
        _mergeConfig = [QNTranscodingLiveStreamingConfig defaultConfiguration];
        QNTranscodingLiveStreamingImage *bgInfo = [[QNTranscodingLiveStreamingImage alloc] init];
        bgInfo.frame = CGRectMake(0, 0, 720, 1280);
        bgInfo.imageUrl = @"";
        _mergeConfig.background = bgInfo;
        _mergeConfig.minBitrateBps = 1000*1000;
        _mergeConfig.maxBitrateBps = 1000*1000;
        _mergeConfig.width = 720;
        _mergeConfig.height = 1280;
        _mergeConfig.fillMode = QNVideoFillModePreserveAspectRatioAndFill;
        _mergeConfig.publishUrl = [NSString stringWithFormat:@"rtmp://pili-publish.qnsdk.com/sdk-live/%@", self.interviewInfoModel.ID];
        _mergeConfig.streamID = self.interviewInfoModel.ID;;
    }
    return _mergeConfig;
}

- (NSMutableArray<QNTranscodingLiveStreamingTrack *> *)layouts {
    if (!_layouts) {
        _layouts = [NSMutableArray array];
    }
    return _layouts;
}

-(QNSendMsgTool *)sendMsgTool {
    if (!_sendMsgTool) {
        _sendMsgTool = [[QNSendMsgTool alloc]initWithToId:self.interviewModel.imConfig.imGroupId];
    }
    return _sendMsgTool;
}

@end
