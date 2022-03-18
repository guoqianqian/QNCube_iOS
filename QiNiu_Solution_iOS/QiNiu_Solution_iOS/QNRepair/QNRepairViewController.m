//
//  QNRepairViewController.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/9/26.
//

#import "QNRepairViewController.h"
#import "QNRTCRoomEntity.h"
#import "QNNetworkUtil.h"
#import "QNJoinRepairModel.h"
#import <MJExtension/MJExtension.h>
#import "RCChatRoomView.h"
#import "QNRoomUserView.h"
#import "QNIMMessageModel.h"
#import <YYCategories/YYCategories.h>
#import <Masonry/Masonry.h>
#import <QNWhiteBoardSDK/QNWhiteBoardSDK.h>
#import "MBProgressHUD+QNShow.h"
#import <QNAISDK/QNAISDK.h>
#import "QNRepairWhiteBoardController.h"
#import "QNWhiteBoardExpandableToolbar.h"
#import "QNVideoTrackParams.h"
#import "QNAudioTrackParams.h"
#import "QNRoomUserView.h"

@interface QNRepairViewController ()<QNIMChatServiceProtocol,UIGestureRecognizerDelegate,QNWhiteboardDelegate,QNRTCClientDelegate,QNMicrophoneAudioTrackDataDelegate>

@property (nonatomic, strong) QNJoinRepairModel *repairModel;

@property (nonatomic, strong) QNRoomTools *roomTool;

@property (nonatomic, strong) QNSendMsgTool *sendMsgTool;

@property (nonatomic, strong) RCChatRoomView * chatRoomView;

@property (nonatomic, strong) QNRepairWhiteBoardController *whiteBoard;
@property (nonatomic, strong) UIView *wbBgView;

@property (nonatomic, strong) QNTranscodingLiveStreamingConfig *config;

@property (nonatomic, copy) NSString *staffUserId;

@property (nonatomic, strong) UIButton *microphoneButton;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *videoButton;
@end

@implementation QNRepairViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[QNIMChatService sharedOption] addDelegate:self delegateQueue:dispatch_get_main_queue()];

    [self joinRepairRoom];

}

- (void)joinRepairRoom {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"roomId"] = self.model.roomId;
    NSString *role;
    switch (self.model.roleType) {
        case QNRepairRoleTypeProfessor:
            role = @"professor";
            break;
        case QNRepairRoleTypeStudents:
            role = @"student";
            break;
        case QNRepairRoleTypeStaff:
            role = @"staff";
            break;
        default:
            break;
    }
    params[@"role"] = role;
    
    [QNNetworkUtil postRequestWithAction:@"repair/joinRoom" params:params success:^(NSDictionary *responseData) {
        
        self.repairModel = [QNJoinRepairModel mj_objectWithKeyValues:responseData];
        self.repairModel.allUserList = [QNJoinRepairUserInfoModel mj_objectArrayWithKeyValuesArray:responseData[@"allUserList"]];
        
        [self joinRoomOption];
        
    } failure:^(NSError *error) {
        [MBProgressHUD showText:@"加入房间失败!"];
    }];
    
}

- (void)leaveRoom {
    [super leaveRoom];
    if (self.model.roleType ==QNRepairRoleTypeStaff) {
        [self.rtcClient stopLiveStreamingWithTranscoding:self.config];
    }
    
    QNIMMessageObject *message = [self.sendMsgTool createJoinRoomMessage];
    [[QNIMChatService sharedOption] sendMessage:message];
    
    NSString *str = [NSString stringWithFormat:@"repair/leaveRoom/%@",self.model.roomId];
    [QNNetworkUtil getRequestWithAction:str params:nil success:^(NSDictionary *responseData) {
                 
    } failure:^(NSError *error) {
            
    }];
}

//进房操作
- (void)joinRoomOption {
    
    QNRTCRoomEntity *room = [QNRTCRoomEntity new];
    room.provideHostUid = self.repairModel.userInfo.accountId;
    room.providePushUrl = self.repairModel.publishUrl;
    room.provideRoomToken = self.repairModel.roomToken;
    room.provideMeId = self.repairModel.userInfo.accountId;
    QNUserExtension *userInfo = [QNUserExtension new];
    switch (self.model.roleType) {
        case QNRepairRoleTypeStaff:
            userInfo.userExtRoleType = @"staff";
            userInfo.clientRoleType = QNClientRoleTypeMaster;
            break;
        case QNRepairRoleTypeStudents:
            userInfo.userExtRoleType = @"student";
            userInfo.clientRoleType = QNClientRoleTypePuller;
            break;
        case QNRepairRoleTypeProfessor:
            userInfo.userExtRoleType = @"professor";
            userInfo.clientRoleType = QNClientRoleTypeAudience;
            break;
        
        default:
            break;
    }
    
    room.provideUserExtension = userInfo;
    [self joinRoom:room];
    self.rtcClient.delegate = self;
    
    [self setupWhiteBoard];//白板
    
    if (self.model.roleType == QNRepairRoleTypeStaff) {
        [self.localVideoTrack startCapture];
        [self.localVideoTrack play:self.preview];
        
        
    } else if (self.model.roleType == QNRepairRoleTypeProfessor) {
        [self setWhiteBoardButton];

    } else if (self.model.roleType == QNRepairRoleTypeStudents) {

    } else {
        
    }
    
    [[QNIMGroupService sharedOption] joinGroupWithGroupId:self.repairModel.imConfig.imGroupId message:@"" completion:^(QNIMError * _Nonnull error) {
        QNIMMessageObject *message = [self.sendMsgTool createJoinRoomMessage];
        [[QNIMChatService sharedOption] sendMessage:message];
        [self.chatRoomView sendMessage:message];
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self leaveRoom];
    [self endSpeak];
    [self.whiteBoard setDirty];
    [self.whiteBoard closeWhiteboard];
    [[QNWhiteboardControl instance] leaveRoom];
    [self.rtcClient stopLiveStreamingWithTranscoding:self.config];
}

- (void)receivedMessages:(NSArray<QNIMMessageObject *> *)messages {
    [self.chatRoomView showMessage:messages.firstObject];
}

//语音转文字
- (void)audioToText {
    
    QNSpeakToTextParams *params = [[QNSpeakToTextParams alloc]init];
    params.force_final = YES;
    
    __weak typeof(self)wealSelf = self;
    [[QNSpeakToTextDetect shareManager] startDetectWithTrack:self.localAudioTrack params:params complete:^(QNSpeakToTextResult * _Nonnull result) {
        //语音识别成功，发送识别消息
        NSString *content = [wealSelf audioWithTranscript:result.transcript];
        if (result.isFinal == 1 && content.length > 0) {
            QNIMMessageObject *message = [self.sendMsgTool createChatMessage:content];
            [[QNIMChatService sharedOption] sendMessage:message];
            [self.chatRoomView sendMessage:message];
                        
        }
    } failure:^(NSError *error) {

    }];
  
}


//指令识别
- (NSString *)audioWithTranscript:(NSString *)transcript {
    
    //只会识别有效的指令 进行RTC房间操作，不会识别普通聊天语音。
    NSString *content;
    transcript = [transcript stringByReplacingOccurrencesOfString:@"，" withString:@""];
    transcript = [transcript stringByReplacingOccurrencesOfString:@"。" withString:@""];
    if ([transcript isEqualToString:@"关闭麦克风"]) {
        content = [transcript stringByAppendingString:@"->语音指令发送成功"];
        [self.localAudioTrack updateMute:YES] ;
        self.microphoneButton.selected = NO;
    } else if ([transcript isEqualToString:@"打开麦克风"]) {
        content = [transcript stringByAppendingString:@"->语音指令发送成功"];
        [self.localAudioTrack updateMute:NO] ;
        self.microphoneButton.selected = YES;
    } else  if ([transcript isEqualToString:@"关闭摄像头"]) {
        content = [transcript stringByAppendingString:@"->语音指令发送成功"];
        [self.localVideoTrack updateMute:YES];
        self.videoButton.selected = NO;
        self.preview.hidden = YES;
    }else  if ([transcript isEqualToString:@"打开摄像头"]) {
        content = [transcript stringByAppendingString:@"->语音指令发送成功"];
        self.videoButton.selected = YES;
        [self.localVideoTrack updateMute:NO];
        self.preview.hidden = NO;
    } else {

    }
    return content;
}

//停止语音识别
- (void)endSpeak {
    [[QNSpeakToTextDetect shareManager] stopDetect];
    self.localAudioTrack.audioDelegate = self;
}

- (void)setupWhiteBoard {
    
    self.whiteBoard = [[QNRepairWhiteBoardController alloc]init];
    self.whiteBoard.roomToken = self.repairModel.roomToken;
    self.whiteBoard.roleType = self.model.roleType;
    self.whiteBoard.view.frame = self.wbBgView.frame;
    CGFloat aspectRatio = 9/16;
    
    self.whiteBoard.aspectRatio = [NSString stringWithFormat:@"%.1f",aspectRatio].floatValue ;
    self.whiteBoard.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self.wbBgView addSubview:self.whiteBoard.view];
    [self setupIMUI];
    [self setupBottomButtons];
    
}

- (UIView *)wbBgView {
    
    if (!_wbBgView) {
        
        CGFloat wRatio = kScreenWidth/540;
        CGFloat hRatio = kScreenHeight/960;
                    
        CGFloat aspectRatio = wRatio>hRatio ? wRatio : hRatio;
                
        CGFloat whiteBoardW = 540*aspectRatio;
        CGFloat whiteBoardH = 960*aspectRatio;
        
        _wbBgView = [[UIView alloc]initWithFrame:self.view.frame];
        [self.view addSubview:_wbBgView];
        
        [_wbBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.view);
            make.width.mas_equalTo(whiteBoardW);
            make.height.mas_equalTo(whiteBoardH);
        }];
    }
    return _wbBgView;
}

- (void)setWhiteBoardButton {
    //添加工具栏
    QNWhiteBoardExpandableToolbar *toolbar = [[QNWhiteBoardExpandableToolbar alloc] init];
    [self.whiteBoard.view addSubview:toolbar];
    [toolbar addConstraintToParent:self.whiteBoard.view];
}

- (void)resetBottomGesture:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self.chatRoomView setDefaultBottomViewStatus];
        [self.view removeGestureRecognizer:gestureRecognizer];
    }
}

- (void)setupBottomButtons {
    
    UIView *bottomButtonView = [[UIView alloc] init];
    [self.whiteBoard.view addSubview:bottomButtonView];
    [bottomButtonView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.mas_bottomLayoutGuide).offset(-15);
        make.height.mas_equalTo(100);
    }];
        
    NSString *selectedImage[] = {@"microphone", @"close-phone",@"video-open"};
    NSString *normalImage[] = {@"microphone-disable",@"close-phone",@"video-close"};
    SEL selectors[] = {@selector(microphoneAction:),@selector(conferenceAction:),@selector(videoAction:)};
//    UIButton *buttons[] = {self.microphoneButton,self.closeButton,self.videoButton};
    CGFloat buttonWidth = 54;
    NSInteger space = (kScreenWidth - buttonWidth * 3)/4;
    
    for (int i = 0; i < ARRAY_SIZE(normalImage); i ++) {
        UIButton *button = [[UIButton alloc] init];
        [button setImage:[UIImage imageNamed:selectedImage[i]] forState:(UIControlStateSelected)];
        [button setImage:[UIImage imageNamed:normalImage[i]] forState:(UIControlStateNormal)];
        [button addTarget:self action:selectors[i] forControlEvents:(UIControlEventTouchUpInside)];
        button.selected = YES;
        [bottomButtonView addSubview:button];
        if (i == 0) {
            self.microphoneButton = button;
        } else if (i == 1) {
            self.closeButton = button;
        } else {
            self.videoButton = button;
        }
    }
    
    [bottomButtonView.subviews mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:space leadSpacing:space tailSpacing:space];
    [bottomButtonView.subviews mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(bottomButtonView);
        make.width.height.mas_equalTo(buttonWidth);
    }];
    
}

// 退出房间
- (void)conferenceAction:(UIButton *)conferenceButton {
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
  
}

// 打开/关闭音频
- (void)microphoneAction:(UIButton *)microphoneButton {
    microphoneButton.selected = !microphoneButton.isSelected;
    self.microphoneButton = microphoneButton;
    [self muteLocalAudio:!microphoneButton.isSelected];
}

// 打开/关闭视频画面
- (void)videoAction:(UIButton *)videoButton {
    videoButton.selected = !videoButton.isSelected;
    self.videoButton = videoButton;
    [self muteLocalVideo:!videoButton.isSelected];
    self.preview.hidden = !videoButton.isSelected;
}
# pragma mark - IM

- (void)setupIMUI {
    CGFloat bottomExtraDistance  = 0;
    if (@available(iOS 11.0, *)) {
        bottomExtraDistance = [self getIPhonexExtraBottomHeight];
    }
    
    self.chatRoomView = [[RCChatRoomView alloc] initWithFrame:CGRectMake(30, kScreenHeight - (237 +50)  - bottomExtraDistance, kScreenWidth, 237+50)];
    [self.whiteBoard.view addSubview:self.chatRoomView];

}

- (float)getIPhonexExtraBottomHeight {
    float height = 0;
    if (@available(iOS 11.0, *)) {
        height = [[[UIApplication sharedApplication] keyWindow] safeAreaInsets].bottom;
    }
    return height;
}



- (void)RTCClient:(QNRTCClient *)client didStartLiveStreamingWith:(NSString *)streamID {
    
    QNVideoTrackParams *params = [QNVideoTrackParams new];
    params.width = 540;
    params.height = 960;
    [self setScreenTrackParams:params];
    
    QNTranscodingLiveStreamingTrack *pushVideoTrack = [QNTranscodingLiveStreamingTrack new];
    pushVideoTrack.trackId = self.localVideoTrack.trackID;
    pushVideoTrack.frame = CGRectMake(0, 0, params.width, params.height);
    
    QNTranscodingLiveStreamingTrack *pushAudioTrack = [QNTranscodingLiveStreamingTrack new];
    pushAudioTrack.trackId = self.localAudioTrack.trackID;
    
    [self.rtcClient setTranscodingLiveStreamingID:self.model.roomId withTracks:@[pushVideoTrack,pushAudioTrack]];
}

- (QNTranscodingLiveStreamingConfig *)config {
    if (!_config) {
        _config = [QNTranscodingLiveStreamingConfig defaultConfiguration];
        _config.streamID = self.model.roomId;
        _config.width = 540;
        _config.height = 960;
        _config.publishUrl = self.repairModel.publishUrl;
    }
    return _config;
}

- (void)RTCClient:(QNRTCClient *)client firstVideoDidDecodeOfTrack:(QNRemoteVideoTrack *)videoTrack remoteUserID:(NSString *)userID {
    [self.rtcClient subscribe:@[videoTrack]];
    
    QNRoomUserView *roomView = [[QNRoomUserView alloc]initWithFrame:self.view.frame];
    
    self.staffUserId = userID;
    [self addRenderViewToSuperView:roomView];
    [self.view bringSubviewToFront:self.wbBgView];
    [videoTrack play:roomView.cameraView];
}

- (void)RTCClient:(QNRTCClient *)client didUserUnpublishTracks:(nonnull NSArray<QNRemoteTrack *> *)tracks ofUserID:(nonnull NSString *)userID {
        
    if ([userID isEqualToString:self.staffUserId]) {
        for (QNRemoteTrack *track in tracks) {
            QNRoomUserView *view = [self  userViewWithTrackId:track.trackID];
            [self removeRenderViewFromSuperView:view];
        }
    }
}

- (void)RTCClient:(QNRTCClient *)client didConnectionStateChanged:(QNConnectionState)state disconnectedInfo:(QNConnectionDisconnectedInfo *)info {
    
    if (state == QNConnectionStateConnected) {
        
        NSMutableArray *tracks = [NSMutableArray array];
        
        QNAudioTrackParams *param = [QNAudioTrackParams new];
        param.volume = 0.5;
        [self setUpLocalAudioTrackParams:param];
        self.localVideoTrack.fillMode = QNVideoFillModePreserveAspectRatio;
        
        [tracks addObject:self.localAudioTrack];
        
        if (self.model.roleType == QNRepairRoleTypeStaff) {
            QNVideoTrackParams *params = [QNVideoTrackParams new];
            params.width = 540;
            params.height = 960;
            
            [self setUpLocalVideoParams:params];
//            self.localVideoTrack.fillMode = QNVideoFillModePreserveAspectRatio;
            [tracks addObject:self.localVideoTrack];
        }
        
        [self.rtcClient publish:tracks completeCallback:^(BOOL onPublished, NSError *error) {
            
            [self audioToText];
            
            if (self.model.roleType == QNRepairRoleTypeStaff) {
                [self.rtcClient startLiveStreamingWithTranscoding:self.config];
            }
            
            
            
        }];
    }
    
}

- (QNRoomTools *)roomTool {
    if (!_roomTool) {
        _roomTool = [[QNRoomTools alloc]initWithType:@"repair" roomId:self.model.roomId];
    }
    return _roomTool;
}

-(QNSendMsgTool *)sendMsgTool {
    if (!_sendMsgTool) {
        _sendMsgTool = [[QNSendMsgTool alloc]initWithToId:self.repairModel.imConfig.imGroupId];
    }
    return _sendMsgTool;
}

@end
