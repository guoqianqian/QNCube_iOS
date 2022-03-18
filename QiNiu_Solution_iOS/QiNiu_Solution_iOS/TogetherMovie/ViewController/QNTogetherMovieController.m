//
//  QNTogetherMovieController.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/12/3.
//

#import "QNTogetherMovieController.h"
#import <PLPlayerKit/PLPlayerKit.h>
#import "QNNetworkUtil.h"
#import <MJExtension/MJExtension.h>
#import "MBProgressHUD+QNShow.h"
#import <Masonry/Masonry.h>
#import <YYCategories/YYCategories.h>
#import "QNMovieListModel.h"
#import "QNMovieOnlineView.h"
#import "QNRoomDetailModel.h"
#import "QNChatController.h"
#import "QNRTCRoomEntity.h"
#import <QNIMSDK/QNIMSDK.h>
#import <AVKit/AVKit.h>
#import "QNPlayMovieListController.h"
#import "QNMovieMemberListController.h"
#import "QNInvitationModel.h"
#import "QNMicSeatMessageModel.h"
#import "QNUserMicSeatModel.h"
#import "QNAudioTrackParams.h"
#import "QNVideoTrackParams.h"
#import "QNMovieMicController.h"
#import "QNRoomMicInfoModel.h"
#import "CLPlayerView.h"
#import "QNMovieModel.h"
#import "QNIMMessageModel.h"
#import "QNMovieTogetherChannelModel.h"
#import <AVFoundation/AVFoundation.h>
#import "QNMovieTogetherViewModel.h"

@interface QNTogetherMovieController ()<QNRTCClientDelegate>

@property (nonatomic, strong) UIButton *inviteButton;
@property (nonatomic, weak) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) QNRoomTools *roomTool;
@property (nonatomic, strong) QNSendMsgTool *sendMsgTool;
@property (nonatomic, strong)CLPlayerView *playerView;
@property (nonatomic, strong)QNMovieOnlineView *onlineView;
@property (nonatomic, strong) NSMutableArray<QNUserInfo *> *allUserList;
@property (nonatomic, copy) NSString *imGroupId;
@property (nonatomic, strong)QNChatController *chatVc;
@property (nonatomic, strong)QNMovieMicController *micVc;
@property (nonatomic, strong)QNMovieListModel * movie;//当前正在播放的电影
@property (nonatomic, strong)QNRemoteVideoTrack *videoTrack;
@property (nonatomic, assign) BOOL muteAudio;
@property (nonatomic, assign) BOOL muteVideo;
@property (nonatomic, assign) NSInteger currentPoint;//当前播放的进度
@property (nonatomic, assign) BOOL isPlaying;//记录播放器的状态

@property (nonatomic, copy) NSString *taskID;//正在转推的任务

//@property (nonatomic, strong)PLSTArEffectManager *effectManager;
//@property (nonatomic, strong) PLSTDetector *detector;

@property (nonatomic, strong)QNRoomMicInfoModel *micInfoModel;

@property (nonatomic, strong) QNTranscodingLiveStreamingConfig *mergeConfig;//多路
@property (nonatomic, strong) NSMutableArray<QNTranscodingLiveStreamingTrack *> *layouts;
@property (nonatomic, strong) QNTranscodingLiveStreamingTrack *selfCameraLayout;
@property (nonatomic, strong) QNTranscodingLiveStreamingTrack *remoteCameraLayout;
@property (nonatomic, strong) QNTranscodingLiveStreamingTrack *remoteMovieLayout;//电影轨道
@end

@implementation QNTogetherMovieController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self joinMovieRoom];
    
    self.muteAudio = NO;
    self.muteVideo = NO;
}

- (void)joinMovieRoom {
    
    NSMutableArray *arr = [NSMutableArray array];
    
    QNAttrsModel *model1 = [QNAttrsModel new];
    model1.key = @"role";
    model1.value = self.model.userInfo.role ?:@"roomAudience";
    [arr addObject:model1];
    
    if (self.inviteCode.length > 0) {
        QNAttrsModel *model2 = [QNAttrsModel new];
        model2.key = @"invitationCode";
        model2.value = self.inviteCode;
        [arr addObject:model2];
    }
    
    [self.roomTool requestJoinRoomWithParams:[QNAttrsModel mj_keyValuesArrayWithObjectArray:arr] success:^(QNRoomDetailModel * _Nonnull roomDetailodel) {
        self.model = roomDetailodel;
        self.allUserList = self.model.allUserList;
        QNUserInfo *userInfo = [QNUserInfo new];
        userInfo.role = self.model.userInfo.role;
        self.model.userInfo = userInfo;
        
        self.imGroupId = self.model.imConfig.imGroupId;
        
        [[QNIMGroupService sharedOption] joinGroupWithGroupId:self.model.imConfig.imGroupId message:@"" completion:^(QNIMError * _Nonnull error) {
            [self.chatVc sendMessageWithAction:@"welcome" content:[NSString stringWithFormat:@"欢迎用户 %@ 进入房间",QN_User_nickname]];
        }];
        
        if ([QN_User_id isEqualToString:self.model.roomInfo.creator]) {
            [self joinRoomOption];
            [self updateRoomAttWithPlayStatus:0 currentPosition:10];
            [self createTrack];
        }
        
        [self playWithUrlStr:self.listModel.playUrl];
        
        } failure:^(NSError * _Nonnull error) {
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    
}

//更新房间属性
- (void)updateRoomAttWithPlayStatus:(NSInteger)status currentPosition:(NSInteger)currentPosition {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    params[@"type"] = @"movie";
    params[@"roomId"] = self.model.roomInfo.roomId;
    
    NSMutableArray *arr = [NSMutableArray array];
    
    QNAttrsModel *model1 = [QNAttrsModel new];
    model1.key = @"watch_movie_together";
    
    QNMovieTogetherChannelModel *model = [QNMovieTogetherChannelModel new];
    model.currentPosition = @(currentPosition).longLongValue;
    model.currentTimeMillis = [self getNowTimeTimestamp3].longLongValue;
    model.playStatus = status;
    model.startTimeMillis = @(0).longLongValue;
    model.videoId = self.movie.movieId;
    model.videoUid = [[NSUserDefaults standardUserDefaults] objectForKey:QN_ACCOUNT_ID_KEY];
    model.movieInfo = self.listModel;
    
    model1.value = model.mj_JSONString;
    [arr addObject:model1];
    
    params[@"attrs"] = [QNAttrsModel mj_keyValuesArrayWithObjectArray:arr];
    
    [QNNetworkUtil postRequestWithAction:@"base/updateRoomAttr" params:params success:^(NSDictionary *responseData) {
            
        } failure:^(NSError *error) {
            
        }];
}

//创建转推任务
- (void)createTrack {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"roomId"] = self.model.roomInfo.roomId;
    params[@"roomToken"] = self.model.rtcInfo.roomToken;
    params[@"sourceUrls"] = @[self.listModel.playUrl];
    [QNMovieTogetherViewModel requestCreateTrackWithParams:params success:^(NSDictionary * _Nonnull data) {
        self.taskID = data[@"taskID"];
        } failure:^(NSError * _Nonnull error) {
                    
                }];
}

//开始转推任务
- (void)startTrack {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"roomId"] = self.model.roomInfo.roomId;
    params[@"roomToken"] = self.model.rtcInfo.roomToken;
    params[@"taskID"] = self.taskID;
    [QNMovieTogetherViewModel requestStartTrackWithParams:params success:^(NSDictionary * _Nonnull data) {
                    
                } failure:^(NSError * _Nonnull error) {
                    
                }];
}

//停止转推任务
- (void)stopTrack {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"roomId"] = self.model.roomInfo.roomId;
    params[@"roomToken"] = self.model.rtcInfo.roomToken;
    params[@"taskID"] = self.taskID;
    [QNMovieTogetherViewModel requestStopTrackWithParams:params success:^(NSDictionary * _Nonnull data) {
                    
                } failure:^(NSError * _Nonnull error) {
                    
                }];
}

//删除转推任务
- (void)deleteTrack {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"roomId"] = self.model.roomInfo.roomId;
    params[@"roomToken"] = self.model.rtcInfo.roomToken;
    params[@"taskID"] = self.taskID;
    [QNMovieTogetherViewModel requestDeleteTrackWithParams:params success:^(NSDictionary * _Nonnull data) {
                    
                } failure:^(NSError * _Nonnull error) {
                    
                }];
}

//seek转推时间
- (void)seekTrack {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"roomId"] = self.model.roomInfo.roomId;
    params[@"roomToken"] = self.model.rtcInfo.roomToken;
    params[@"taskID"] = self.taskID;
    params[@"index"] = @(0);
    params[@"seek"] = @(self.currentPoint/1000);
    [QNMovieTogetherViewModel requestSeekWithParams:params success:^(NSDictionary * _Nonnull data) {
                    
                } failure:^(NSError * _Nonnull error) {
                    
                }];
}


//进房操作
- (void)joinRoomOption {
    
    QNRTCRoomEntity *room = [QNRTCRoomEntity new];
    room.providePushUrl = self.model.rtcInfo.publishUrl;
    room.provideRoomToken = self.model.rtcInfo.roomToken;
    room.provideHostUid = self.model.roomInfo.creator;
    
    room.provideMeId = self.model.userInfo.userId;
    
    QNUserExtension *userInfo = [QNUserExtension new];
    userInfo.userExtRoleType = self.model.userInfo.role;
    room.provideUserExtension = userInfo;
    
    [self joinRoom:room];
    self.rtcClient.delegate = self;
    
}

//发布自己的流
- (void)publishTrack {
    
    //发送上麦信令
    QNIMMessageObject *message = [self.sendMsgTool createOnMicMessage];
    [self.chatVc sendMessageWithMessage:message];
    
    [self.localVideoTrack startCapture];

    NSMutableArray *tracks = [NSMutableArray array];
    
    QNAudioTrackParams *param = [QNAudioTrackParams new];
    param.volume = 0.5;
    [self setUpLocalAudioTrackParams:param];
    self.localVideoTrack.fillMode = QNVideoFillModePreserveAspectRatioAndFill;
    [tracks addObject:self.localAudioTrack];
    
    QNVideoTrackParams *params = [QNVideoTrackParams new];
    params.width = 540;
    params.height = 960;
    [self setUpLocalVideoParams:params];
    [tracks addObject:self.localVideoTrack];
    
    __weak typeof(self)weakSelf = self;
    [self.rtcClient publish:tracks completeCallback:^(BOOL onPublished, NSError *error) {
        
        if (error) {
            NSLog(@"发布视频流失败，error = %@",error);
        }
            //请求上麦接口
        [weakSelf requestUpMicSeat];
        
        //自己的音频
        QNTranscodingLiveStreamingTrack *audioLayout = [[QNTranscodingLiveStreamingTrack alloc] init];
        audioLayout.trackId = weakSelf.localAudioTrack.trackID;
        [weakSelf.layouts addObject:audioLayout];
        
        [weakSelf.layouts removeObject:weakSelf.selfCameraLayout];
        weakSelf.selfCameraLayout = [[QNTranscodingLiveStreamingTrack alloc] init];
        weakSelf.selfCameraLayout.trackId = weakSelf.localVideoTrack.trackID;
        weakSelf.selfCameraLayout.frame = CGRectMake(920, 360, 360, 360);
        weakSelf.selfCameraLayout.zIndex = 2;
        [weakSelf.layouts addObject:weakSelf.selfCameraLayout];
        
        if ([QN_User_id isEqualToString:weakSelf.model.roomInfo.creator]) {
#pragma warning   加入自己的track进入合流画面
//            [weakSelf.rtcClient setTranscodingLiveStreamingID:weakSelf.model.roomInfo.roomId withTracks:weakSelf.layouts];
        }
    }];
}

- (void)playWithUrlStr:(NSString *)urlStr {
    self.movie = self.listModel;
    [_playerView destroyPlayer];
    CLPlayerView *playerView = [[CLPlayerView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 240)];
        
    [playerView updateWithConfigure:^(CLPlayerViewConfigure *configure) {
        configure.backPlay = NO;
        configure.topToolBarHiddenType = TopToolBarHiddenAlways;
        configure.progressPlayFinishColor = [UIColor colorWithHexString:@"58C1F4"];
        configure.strokeColor = [UIColor whiteColor];
        configure.autoRotate = NO;
        configure.isLandscape = NO;
        configure.repeatPlay = YES;
    }];
        _playerView = playerView;
        [self.view addSubview:_playerView];
        //视频地址
        _playerView.url = [NSURL URLWithString:urlStr];
        __weak typeof(self)weakSelf = self;
        _playerView.currentTimeBlock = ^(NSInteger currentTime) {
            NSString *time = [NSString stringWithFormat:@"%ld",currentTime];
            if ([QN_User_id isEqualToString:weakSelf.model.roomInfo.creator]) {
                [weakSelf sendMovieMessageWithCurrentPosition:time playStatus:@"1" startTimeMillis:@""];
                if (weakSelf.taskID.length > 0 && weakSelf.isPlaying == NO && currentTime > 10) {
                    [weakSelf updateRoomAttWithPlayStatus:1 currentPosition:currentTime];
                    [weakSelf startTrack];
                }
                
            }
            
            weakSelf.isPlaying = YES;
        };
    
    _playerView.continuePlayBlock = ^(NSInteger currentTime) {
        NSString *time = [NSString stringWithFormat:@"%ld",currentTime];
        if ([QN_User_id isEqualToString:weakSelf.model.roomInfo.creator]) {
            [weakSelf sendMovieMessageWithCurrentPosition:time playStatus:@"1" startTimeMillis:@""];
            if (weakSelf.taskID.length > 0 && weakSelf.isPlaying == NO && currentTime > 10) {
                [weakSelf updateRoomAttWithPlayStatus:1 currentPosition:currentTime];
                [weakSelf startTrack];
            }
            
        }
        
        weakSelf.isPlaying = YES;
    };
    
    _playerView.pausePlayBlock = ^(NSInteger currentTime) {
        NSString *time = [NSString stringWithFormat:@"%ld",currentTime];
        if ([QN_User_id isEqualToString:weakSelf.model.roomInfo.creator]) {
            [weakSelf sendMovieMessageWithCurrentPosition:time playStatus:@"0" startTimeMillis:@""];
            [weakSelf updateRoomAttWithPlayStatus:0 currentPosition:currentTime];
            weakSelf.isPlaying = NO;
            [weakSelf stopTrack];
        }
    };
        //播放
        [_playerView playVideo];
    
    
        //返回按钮点击事件回调
        [_playerView backButton:^(UIButton *button) {
            
        }];

        //播放完成回调
        [_playerView endPlay:^{

        }];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(20, 35 , 20, 20)];
    [button setImage:[UIImage imageNamed:@"icon_return"] forState:(UIControlStateNormal)];
    [button addTarget:self action:@selector(conference) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:button];
    

    [self onlineView];
    
    [self chatVc];
        
    if ([QN_User_id isEqualToString:self.model.roomInfo.creator]) {
        
        _inviteButton = [[UIButton alloc]init];
        [_inviteButton setImage:[UIImage imageNamed:@"invite_long"] forState:UIControlStateNormal];
        [_inviteButton addTarget:self action:@selector(inviteMember) forControlEvents:UIControlEventTouchUpInside];
        [self.chatVc.view addSubview:_inviteButton];
        [_inviteButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.chatVc.view).offset(20);
            make.top.equalTo(self.chatVc.view).offset(26);
        }];
        [self.view bringSubviewToFront:_inviteButton];
    }
    
//    [[QNIMGroupService sharedOption] joinGroupWithGroupId:self.model.imConfig.imGroupId message:@"" completion:^(QNIMError * _Nonnull error) {
//        [weakSelf.chatVc sendMessageWithAction:@"welcome" content:[NSString stringWithFormat:@"欢迎用户 %@ 进入房间",QN_User_nickname]];
//    }];
            
}

//数组去重
- (NSMutableArray *)removeSameObject:(NSArray *)originalArr {
        NSMutableArray *resultArrM = [NSMutableArray array];

        for (NSString *item in originalArr) {
            if (![resultArrM containsObject:item]) {
              [resultArrM addObject:item];
            }
        }
    return resultArrM;
}

//发送电影同步信令
- (void)sendMovieMessageWithCurrentPosition:(NSString *)currentPosition playStatus:(NSString *)playStatus startTimeMillis:(NSString *)startTimeMillis {
    
    QNIMMessageModel *messageModel = [QNIMMessageModel new];
    
    messageModel.action = @"channelAttributes_change";
    
    QNIMMessageStrModel *data = [QNIMMessageStrModel new];
    
    data.key = @"watch_movie_together";
    data.roomId = self.model.roomInfo.roomId;
    
    QNMovieTogetherChannelModel *model = [QNMovieTogetherChannelModel new];
    model.currentPosition = currentPosition.longLongValue;
    model.currentTimeMillis = [self getNowTimeTimestamp3].longLongValue;
    model.playStatus = playStatus.integerValue;
    model.startTimeMillis = startTimeMillis.longLongValue;
    model.videoId = self.movie.movieId;
    model.videoUid = QN_User_id;
    model.movieInfo = self.movie;
    
    data.value = model.mj_JSONString;
    
    messageModel.data = data;
    
    NSString *senderId = [[NSUserDefaults standardUserDefaults] objectForKey:QN_IM_USER_ID_KEY];
    
    QNIMMessageObject *message = [[QNIMMessageObject alloc]initWithQNIMMessageText:messageModel.mj_JSONString fromId:senderId.longLongValue toId:self.imGroupId.longLongValue type:QNIMMessageTypeGroup conversationId:self.imGroupId.longLongValue];
    [self.chatVc sendMessageWithMessage:message];
    
    if ((currentPosition.integerValue - self.currentPoint) > 3000) {
        [self seekTrack];
    }
    self.currentPoint = currentPosition.integerValue;
    
        
}

//邀请好友连麦
- (void)inviteMember {
    
    if (self.rtcClient.publishedTracks.count > 0 && [self.rtcClient getSubscribedTracks:self.micVc.userView.userId].count > 0) {
        [self addChildViewController:self.micVc];
        [self.view addSubview:self.micVc.view];
        [self.micVc.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.top.equalTo(self.view).offset(240);
            make.bottom.equalTo(self.view);
        }];
        return;
    }
    
    QNMovieMemberListController *vc = [QNMovieMemberListController new];
    vc.allUserList = self.allUserList;
    __weak typeof(self)weakSelf = self;
    vc.invitationClickedBlock = ^(QNUserInfo * _Nonnull itemModel) {
        
        QNIMMessageObject *message = [weakSelf.sendMsgTool createInviteMessageWithInvitationName:@"watchMoviesTogether" receiverId:itemModel.userId];
        [weakSelf.chatVc sendMessageWithMessage:message];
    };
    [self addChildViewController:vc];
    [self.view addSubview:vc.view];
    
    [vc.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view).offset(240);
        make.bottom.equalTo(self.view);
    }];
}

- (NSString *)getNowTimeTimestamp3{

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;

    [formatter setDateStyle:NSDateFormatterMediumStyle];

    [formatter setTimeStyle:NSDateFormatterShortStyle];

    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss SSS"]; // 设置想要的格式，hh与HH的区别:分别表示12小时制,24小时制

   NSTimeZone*timeZone=[NSTimeZone timeZoneWithName:@"Asia/Shanghai"];

    [formatter setTimeZone:timeZone];

    NSDate *datenow = [NSDate date];

    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]*1000];

    return timeSp;

}

// 退出房间
- (void)conference {
    
    
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:QN_ACCOUNT_ID_KEY] isEqualToString:self.model.roomInfo.creator]) {
        __weak typeof(self)weakSelf = self;
        [self showAlertWithTitle:@"确定离开房间吗？" content:@"房主离开后，房间将自动解散，确定离开吗？" success:^{
            
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
            [weakSelf requestLeave];
            [weakSelf requestDownMicSeat];
            [weakSelf.playerView destroyPlayer];
            [weakSelf deleteTrack];
            [weakSelf.rtcClient stopLiveStreamingWithTranscoding:weakSelf.mergeConfig];
        }];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
        [self requestLeave];
        [self requestDownMicSeat];
        [_playerView destroyPlayer];
    }
    [[QNIMGroupService sharedOption] leaveGroupWithGroupId:self.model.imConfig.imGroupId completion:^(QNIMError * _Nonnull error) {
            
    }];
}

- (void)requestLeave {

    [self.roomTool requestLeaveRoom];
    [self.navigationController popViewControllerAnimated:YES];
    [self leaveRoom];
        
}

- (void)receiveInvitationAlertWithModel:(QNInvitationModel *)model {
    
    __weak typeof(self)weakSelf = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"邀请提示" message:model.data.invitation.msg preferredStyle:UIAlertControllerStyleAlert];
    UIView *subView = alertController.view.subviews.lastObject;
    UIView *alertContentView = subView.subviews.lastObject;
    
    for (UIView *subSubView in alertContentView.subviews) {
        subSubView.backgroundColor = [UIColor colorWithHexString:@"1B2C30"];
    }
    
    UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        //发送拒绝连麦信令
        QNIMMessageObject *message = [weakSelf.sendMsgTool createRejectInviteMessageWithInvitationName:model.data.invitationName receiverId:model.data.invitation.initiatorUid];
        [weakSelf.chatVc sendMessageWithMessage:message];
        
    }];
    [alertController addAction:cancelBtn];
    
    UIAlertAction *changeBtn = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //发送接收连麦信令
        QNIMMessageObject *message = [weakSelf.sendMsgTool createAcceptInviteMessageWithInvitationName:model.data.invitationName receiverId:model.data.invitation.initiatorUid];
        [weakSelf.chatVc sendMessageWithMessage:message];
        //显示连麦画面
        [weakSelf showRTCView];
        //请求房间麦位信息
        [weakSelf requestAllMicSeat];
            
    }];
    [alertController addAction:changeBtn];
    
    //修改title
    NSMutableAttributedString *alertControllerStr = [[NSMutableAttributedString alloc] initWithString:@"邀请提示\n"];
    [alertControllerStr addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, 4)];
    [alertController setValue:alertControllerStr forKey:@"attributedTitle"];

    //修改message
    NSMutableAttributedString *alertControllerMessageStr = [[NSMutableAttributedString alloc] initWithString:model.data.invitation.msg];
    [alertControllerMessageStr addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, model.data.invitation.msg.length)];
    [alertController setValue:alertControllerMessageStr forKey:@"attributedMessage"];
    
    alertController.view.tintColor = [UIColor whiteColor];
    [self presentViewController:alertController animated:YES completion:nil];
}

// 打开/关闭音频
- (void)microphoneAction {
    self.muteAudio = !self.muteAudio;
    [self muteLocalAudio:self.muteAudio];
}

// 打开/关闭视频画面
- (void)videoAction {
    self.muteVideo = !self.muteVideo;
    NSMutableArray *videoTracks = [[NSMutableArray alloc] init];
    if (self.localVideoTrack) {
        [videoTracks addObject:self.localVideoTrack];
        [self muteLocalVideo:self.muteVideo];
    }
    [self muteLocalVideo:self.muteVideo];
    // 对应实际关闭连麦视频画面的场景 可根据需求显示或隐藏摄像头采集的预览视图
    self.preview.hidden = self.muteVideo;
}
    
- (void)turnAroundCamera {
    [self.localVideoTrack switchCamera];

}

//显示连麦画面
- (void)showRTCView {
    
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:QN_ACCOUNT_ID_KEY] isEqualToString:self.model.roomInfo.creator]) {
        [self joinRoomOption];
    }
    
    if (self.rtcClient.publishedTracks.count == 0) {
        [self publishTrack];
    }
    
    self.micVc = [QNMovieMicController new];
    [self addChildViewController:self.micVc];
    [self.view addSubview:self.micVc.view];
    
    [self.micVc.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view).offset(240);
        make.bottom.equalTo(self.view);
    }];
    
    __weak typeof(self)weakSelf = self;
    
    self.micVc.dismissBlock = ^{
        
        if (![[[NSUserDefaults standardUserDefaults]objectForKey:QN_ACCOUNT_ID_KEY] isEqualToString:weakSelf.model.roomInfo.creator]) {
            [weakSelf.rtcClient leave];
//            [weakSelf.rtcClient unpublish:@[weakSelf.localVideoTrack,weakSelf.localAudioTrack]];
                //发送下麦信令
            QNIMMessageObject *message = [weakSelf.sendMsgTool createDownMicMessage];
            [weakSelf.chatVc sendMessageWithMessage:message];
        }
    };
    
    self.micVc.actionBlock = ^(QNMovieAction action) {
        switch (action) {
            case QNMovieActionLeave:
                [weakSelf conference];
                break;
            
            case QNMovieActionBeauty: {
                
            }
                break;
                
            case QNMovieActionMic: {
                [weakSelf microphoneAction];
            }
                break;
                
            case QNMovieActionVideo: {
                [weakSelf videoAction];
            }
                break;
                
            case QNMovieActionTurnAround: {
                [weakSelf turnAroundCamera];
            }
                break;
            default:
                break;
        }
    };
    [self.micVc.preView addSubview:self.preview];
    [self.preview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(self.micVc.preView);
    }];
            
}


//请求房间麦位
- (void)requestAllMicSeat {
    
    [self.roomTool requestRoomMicInfoSuccess:^(QNRoomDetailModel * _Nonnull roomDetailodel) {
        self.micInfoModel = [QNRoomMicInfoModel mj_objectWithKeyValues:roomDetailodel.mj_keyValues];
        } failure:^(NSError * _Nonnull error) {
            
        }];

}

//请求上麦接口
- (void)requestUpMicSeat {
    
    [self.roomTool requestUpMicSeatWithUserExtRoleType:@"" clientRoleType:0 success:^{} failure:^(NSError * _Nonnull error) {}];
}

//请求下麦接口
- (void)requestDownMicSeat {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"roomId"] = self.model.roomInfo.roomId;
    params[@"type"] = @"movie";
    
    [QNNetworkUtil postRequestWithAction:@"base/downMic" params:params success:^(NSDictionary *responseData) {
            
        } failure:^(NSError *error) {
            
        }];
}

- (void)RTCClient:(QNRTCClient *)client didLeaveOfUserID:(NSString *)userID {
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:QN_ACCOUNT_ID_KEY] isEqualToString:userID]) {
        return;
    }
    
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([userID isEqualToString:self.model.roomInfo.creator]) {
            [weakSelf showAlertWithTitle:@"房间已经解散了～" content:@"" success:^{
                [weakSelf conference];
            }];
            
        } else {
            
            for (QNUserInfo *userInfo in weakSelf.allUserList) {
                if ([userInfo.userId isEqualToString:userID]) {
                    [weakSelf.allUserList removeObject:userInfo];
                }
            }
            weakSelf.model.allUserList = weakSelf.allUserList;
            weakSelf.onlineView.model = weakSelf.model;
            
            if ([[[NSUserDefaults standardUserDefaults]objectForKey:QN_ACCOUNT_ID_KEY] isEqualToString:weakSelf.model.roomInfo.creator]) {
                
                if (![userID containsString:@"admin-publisher"]) {
                    if (weakSelf.remoteCameraLayout) {
                        [weakSelf.layouts removeObject:weakSelf.remoteCameraLayout];
//                        [weakSelf.rtcClient removeTranscodingLiveStreamingID:self.model.roomInfo.roomId withTracks:@[weakSelf.remoteCameraLayout]];
                    }
                } else {
                    if (weakSelf.remoteMovieLayout) {
                        [weakSelf.layouts removeObject:weakSelf.remoteMovieLayout];
//                        [weakSelf.rtcClient removeTranscodingLiveStreamingID:self.model.roomInfo.roomId withTracks:@[weakSelf.remoteMovieLayout]];
                    }
                }
            }
            
            
        }
                    
    });
    
}

- (void)RTCClient:(QNRTCClient *)client didConnectionStateChanged:(QNConnectionState)state disconnectedInfo:(QNConnectionDisconnectedInfo *)info {
    
    if (state == QNConnectionStateConnected) {
        [self.roomTool requestRoomHeartBeatWithInterval:@"3"];
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:QN_ACCOUNT_ID_KEY] isEqualToString:self.model.roomInfo.creator]) {
            [self.rtcClient startLiveStreamingWithTranscoding:self.mergeConfig];
        } else {
            [self publishTrack];
        }
    }
    
}


//远端用户首帧解码回调
- (void)RTCClient:(QNRTCClient *)client firstVideoDidDecodeOfTrack:(QNRemoteVideoTrack *)videoTrack remoteUserID:(NSString *)userID {
    
    if (![userID containsString:@"admin-publisher"]) {
        QNRoomUserView *roomView = [self createUserViewWithTrackId:videoTrack.trackID userId:videoTrack.trackID];
        roomView.trackId = videoTrack.trackID;
        roomView.userId = userID;
        [videoTrack play:roomView.cameraView];
        [self.micVc.userView addSubview:roomView];
        self.micVc.userView.userId = userID;
        [roomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.bottom.equalTo(self.micVc.userView);
        }];
        
        [self.layouts removeObject:self.remoteCameraLayout];
        self.remoteCameraLayout = [[QNTranscodingLiveStreamingTrack alloc] init];
        self.remoteCameraLayout.trackId = videoTrack.trackID;
        self.remoteCameraLayout.frame = CGRectMake(0, 360, 360, 360);
        self.remoteCameraLayout.zIndex = 1;
        [self.layouts addObject:self.remoteCameraLayout];
        
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:QN_ACCOUNT_ID_KEY] isEqualToString:self.model.roomInfo.creator]) {
//            [self.rtcClient setTranscodingLiveStreamingID:self.model.roomInfo.roomId withTracks:self.layouts];
        }
                
    } else {
        //服务端推过来的流，取消订阅
        if (!self.remoteMovieLayout) {
            [self.layouts removeObject:self.remoteMovieLayout];
            self.remoteMovieLayout = [[QNTranscodingLiveStreamingTrack alloc] init];
            self.remoteMovieLayout.trackId = videoTrack.trackID;
            self.remoteMovieLayout.frame = CGRectMake(0, 0, 1280, 720);
            self.remoteMovieLayout.zIndex = 0;
            [self.layouts addObject:self.remoteMovieLayout];
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:QN_ACCOUNT_ID_KEY] isEqualToString:self.model.roomInfo.creator] && self.remoteMovieLayout) {
//                [self.rtcClient setTranscodingLiveStreamingID:self.model.roomInfo.roomId withTracks:self.layouts];
            }
        }
                
        NSArray <QNTrack *> *tracks = [self.rtcClient getSubscribedTracks:userID];
        [self.rtcClient unsubscribe:tracks];
        
        
    }
       
}




- (void)showAlertWithTitle:(NSString *)title content:(NSString *)content success:(void (^)(void))success{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:content preferredStyle:UIAlertControllerStyleAlert];
    UIView *subView = alertController.view.subviews.lastObject;
    UIView *alertContentView = subView.subviews.lastObject;
    
    for (UIView *subSubView in alertContentView.subviews) {
        subSubView.backgroundColor = [UIColor colorWithHexString:@"1B2C30"];
    }
    
    UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        
    }];
    [alertController addAction:cancelBtn];
    
    UIAlertAction *changeBtn = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        success();
    }];
    [alertController addAction:changeBtn];
    
    //修改title
    NSMutableAttributedString *alertControllerStr = [[NSMutableAttributedString alloc] initWithString:[title stringByAppendingString:@"\n"]];
    [alertControllerStr addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, alertControllerStr.length)];
    [alertController setValue:alertControllerStr forKey:@"attributedTitle"];

    //修改message
    NSMutableAttributedString *alertControllerMessageStr = [[NSMutableAttributedString alloc] initWithString:content];
    [alertControllerMessageStr addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, alertControllerMessageStr.length)];
    [alertController setValue:alertControllerMessageStr forKey:@"attributedMessage"];
    
    alertController.view.tintColor = [UIColor whiteColor];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (QNTranscodingLiveStreamingConfig *)mergeConfig {
    if (!_mergeConfig) {
        _mergeConfig = [QNTranscodingLiveStreamingConfig defaultConfiguration];
        QNTranscodingLiveStreamingImage *bgInfo = [[QNTranscodingLiveStreamingImage alloc] init];
        bgInfo.frame = CGRectMake(0, 0, 720, 1280);
        bgInfo.imageUrl = @"";
        _mergeConfig.background = bgInfo;
        _mergeConfig.minBitrateBps = 3420 * 1000;
        _mergeConfig.maxBitrateBps = 3420 * 1000;
        _mergeConfig.width = 1280;
        _mergeConfig.height = 720;
        _mergeConfig.fillMode = QNVideoFillModePreserveAspectRatioAndFill;
        _mergeConfig.publishUrl = self.model.rtcInfo.publishUrl;
        _mergeConfig.streamID = self.model.roomInfo.roomId;;
    }
    return _mergeConfig;
}

- (NSMutableArray<QNTranscodingLiveStreamingTrack *> *)layouts {
    if (!_layouts) {
        _layouts = [NSMutableArray array];
    }
    return _layouts;
}

- (QNChatController *)chatVc {
    if (!_chatVc) {
        _chatVc = [QNChatController new];
        _chatVc.groupId = self.imGroupId;
        [self addChildViewController:_chatVc];
        [self.view addSubview:_chatVc.view];
        __weak typeof(self)weakSelf = self;
        //收到电影同步信令
        _chatVc.movieSynchronousBlock = ^(QNMovieTogetherChannelModel * _Nonnull model) {
            //视频地址
            
            if (![weakSelf.playerView.url isEqual:[NSURL URLWithString:model.movieInfo.playUrl]]) {
                weakSelf.playerView.url = [NSURL URLWithString:model.movieInfo.playUrl];
                //播放
                [weakSelf.playerView playVideo];
                
            } else {
                
                //seek播放器到指定时间
                
                if (model.playStatus == 0) {
                    [weakSelf.playerView pausePlay];
                } else if (model.playStatus == 1) {
                    [weakSelf.playerView playVideo];
                    if (weakSelf.currentPoint == 0) {
                        [weakSelf.playerView seekToTime:[NSString stringWithFormat:@"%lld",model.currentPosition].floatValue];
                    } else if ((model.currentPosition - weakSelf.currentPoint) > 1000 || (weakSelf.currentPoint - model.currentPosition) >1000 ) {
                        [weakSelf.playerView seekToTime:[NSString stringWithFormat:@"%lld",model.currentPosition].floatValue];
                    }
                } else if (model.playStatus==2) {
                    [weakSelf.playerView endPlay:^{
                        [MBProgressHUD showText:@"播放出错"];
                    }];
                }
               
            }
            
            weakSelf.currentPoint = model.currentPosition;
                    
        };
        //收到邀请信令
        _chatVc.invitationBlock = ^(QNInvitationModel * _Nonnull model) {
            [weakSelf receiveInvitationAlertWithModel:model];
        };
        //收到接受连麦信令
        _chatVc.invitationAcceptBlock = ^(QNInvitationModel * _Nonnull model) {
            //显示连麦画面
            [weakSelf showRTCView];
            //请求房间麦位信息
            [weakSelf requestAllMicSeat];
        };
        //收到用户进房信令
        _chatVc.joinRoomBlock = ^(QNIMMessageModel * _Nonnull model) {
            
            QNUserInfo *userInfo = [QNUserInfo new];
            userInfo.nickname = model.data.senderName;
            userInfo.userId = model.data.senderId;
            
            [weakSelf.allUserList addObject:userInfo];
            weakSelf.onlineView.model = weakSelf.model;
            //去重
    //        weakSelf.allUserList = [weakSelf removeSameObject:weakSelf.allUserList];
                    
        };

        //收到用户上麦信令
        _chatVc.sitDownMicBlock = ^(QNMicSeatMessageModel * _Nonnull model) {
            
        };
        
        //收到用户下麦信令
        _chatVc.sitUpMicBlock = ^(QNMicSeatMessageModel * _Nonnull model) {
            
            if ([weakSelf.model.roomInfo.creator isEqualToString:model.data.uid]) {
                [weakSelf showAlertWithTitle:@"房间已经解散了～" content:@"" success:^{
                    [weakSelf conference];
                }];
            } else {
                [weakSelf.layouts removeObject:weakSelf.remoteCameraLayout];
//                [weakSelf.rtcClient removeTranscodingLiveStreamingID:weakSelf.model.roomInfo.roomId withTracks:@[weakSelf.remoteCameraLayout]];
                
            }
        };
        
        _chatVc.leaveRoomBlock = ^(QNIMMessageModel * _Nonnull model) {
            
        };
        [_chatVc.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.top.equalTo(self.view).offset(340);
            make.bottom.equalTo(self.view);
        }];
    }
    return _chatVc;
}

- (QNMovieOnlineView *)onlineView {
    if (!_onlineView) {
        _onlineView = [[QNMovieOnlineView alloc]initWithFrame:CGRectZero];
        _onlineView.model = self.model;
        [self.view addSubview:_onlineView];
        __weak typeof(self)weakSelf = self;
        _onlineView.playListBlock = ^{
            QNPlayMovieListController *vc = [QNPlayMovieListController new];
            vc.roomId = weakSelf.model.roomInfo.roomId;
            vc.listClickedBlock = ^(QNMovieListModel * _Nonnull movie) {
                //切换播放源
                //视频地址
                weakSelf.playerView.url = [NSURL URLWithString:movie.playUrl];
                weakSelf.movie = movie;
                //播放
                [weakSelf.playerView playVideo];
                
            };
            [weakSelf addChildViewController:vc];
            [weakSelf.view addSubview:vc.view];
            
            [vc.view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(weakSelf.view);
                make.top.equalTo(weakSelf.view).offset(240);
                make.bottom.equalTo(weakSelf.view);
            }];
        };
        
        [_onlineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.top.equalTo(self.playerView.mas_bottom);
            make.height.mas_equalTo(100);
        }];
    }
    return _onlineView;
}

- (QNRoomTools *)roomTool {
    if (!_roomTool) {
        _roomTool = [[QNRoomTools alloc]initWithType:@"movie" roomId:self.model.roomInfo.roomId];
    }
    return _roomTool;
}

-(QNSendMsgTool *)sendMsgTool {
    if (!_sendMsgTool) {
        _sendMsgTool = [[QNSendMsgTool alloc]initWithToId:self.imGroupId];
    }
    return _sendMsgTool;
}
@end
