//
//  QNShowRoomController.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/11/8.
//

#import "QNShowRoomController.h"
#import "QNRoomDetailModel.h"
#import "QNNetworkUtil.h"
#import <MJExtension/MJExtension.h>
#import "MBProgressHUD+QNShow.h"
#import "QNRTCRoomEntity.h"
#import <Masonry/Masonry.h>
#import "QNAudioTrackParams.h"
#import "QNVideoTrackParams.h"
#import "QNApplyOnSeatView.h"
#import <UIKit/UIKit.h>
#import "RCChatRoomView.h"
#import "QNIMMessageModel.h"
#import <YYCategories/YYCategories.h>
#import "QNSeatNumModel.h"

@interface QNShowRoomController ()<QNRTCClientDelegate,UITextFieldDelegate,QNIMChatServiceProtocol>

@property (nonatomic, strong) RCChatRoomView * chatRoomView;

@property (nonatomic, strong) QNRoomTools *roomTool;

@property (nonatomic, strong) QNSendMsgTool *sendMsgTool;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UITextField *commentTf;

@property (nonatomic, strong) NSMutableArray <QNApplyOnSeatView *> *seatViews;

@property (nonatomic, assign) BOOL onseat;

@end

@implementation QNShowRoomController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *bg = [[UIImageView alloc]initWithFrame:self.view.frame];
    bg.image = [UIImage imageNamed:@"showBgView"];
    [self.view addSubview:bg];
    [self.view bringSubviewToFront:self.renderBackgroundView];
    
    [self titleLabel];
    [self joinShowRoom];
    [self setupIMUI];
    [self createRemoteSeat];
    [[QNIMChatService sharedOption] addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

- (void)quitRoom {
        
    if ([self.model.userInfo.role isEqualToString:@"roomHost"]) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"确定要关闭房间？" message:@"关闭房间后，其他成员也将被踢出房间" preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alertController addAction:cancelBtn];
        
        UIAlertAction *changeBtn = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [self leave];
        }];
        [alertController addAction:changeBtn];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
    } else {
        [self leave];
    }
        
}

- (void)leave {

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"roomId"] = self.model.roomInfo.roomId;
    params[@"type"] = @"show";
    
    [QNNetworkUtil postRequestWithAction:@"base/leaveRoom" params:params success:^(NSDictionary *responseData) {
        [self.navigationController popViewControllerAnimated:YES];
        [self leaveRoom];
    } failure:^(NSError *error) {
        [self.navigationController popViewControllerAnimated:YES];
        [self leaveRoom];
    }];
        
}

- (void)joinShowRoom {
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"role"] = self.model.userInfo.role;
    [self.roomTool requestJoinRoomWithParams:dic success:^(QNRoomDetailModel * _Nonnull roomDetailodel) {
        
        self.model = roomDetailodel;
        
        QNUserInfo *userInfo = [QNUserInfo new];
        userInfo.role = dic[@"role"];
        self.model.userInfo = userInfo;
        
        [self joinRoomOption];
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
    
    [self.preview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(100);
        make.width.height.mas_equalTo(120);
    }];
    
    [[QNIMGroupService sharedOption] joinGroupWithGroupId:self.model.imConfig.imGroupId message:@"" completion:^(QNIMError * _Nonnull error) {
        QNIMMessageObject *message = [self.sendMsgTool createJoinRoomMessage];
        [[QNIMChatService sharedOption] sendMessage:message];
        [self.chatRoomView sendMessage:message];
    }];

}

- (void)receivedMessages:(NSArray<QNIMMessageObject *> *)messages {
    [self.chatRoomView showMessage:messages.firstObject];
}

- (void)createRemoteSeat {
    self.seatViews = [NSMutableArray array];
    CGFloat magin = (kScreenWidth - 360)/4;
    NSInteger tagIndex = 100;
    __weak typeof(self)weakSelf = self;
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 2; j++) {
            QNApplyOnSeatView *seatView = [[QNApplyOnSeatView alloc]initWithFrame:CGRectMake(magin + (magin + 120) * i , 240 + j * (120 + 20), 120, 120)];
            seatView.backgroundColor = [UIColor blackColor];
            seatView.tagIndex = ++tagIndex;
            
            seatView.onSeatBlock = ^(NSInteger tag) {
                if ([weakSelf.model.userInfo.role isEqualToString:@"roomHost"] || weakSelf.onseat) {
                    return;
                }
                [weakSelf onSeatWithTag:tag];
            };
            
            seatView.alpha = 0.5;
            [weakSelf.renderBackgroundView addSubview:seatView];
            [weakSelf.seatViews addObject:seatView];
        }
    }    
}

- (void)onSeatWithTag:(NSInteger)tag {
    
    [self publishOwnTrack];
    
    self.onseat = YES;
    
    [self.seatViews enumerateObjectsUsingBlock:^(QNApplyOnSeatView * _Nonnull seatView, NSUInteger idx, BOOL * _Nonnull stop) {
            
        if (seatView.tagIndex == tag) {
            seatView.isSeat = YES;
            seatView.userId = [[NSUserDefaults standardUserDefaults]objectForKey:QN_ACCOUNT_ID_KEY];
            [self.localVideoTrack play:seatView];
            
            QNIMMessageObject *message = [self.sendMsgTool createChatMessage:@"参与了连麦"];
            [[QNIMChatService sharedOption] sendMessage:message];
            [self.chatRoomView sendMessage:message];
            
            [self.rtcClient sendMessage:[NSString stringWithFormat:@"%ld",seatView.tagIndex] toUsers:nil messageId:nil];
        }
        
    }];
    
}


# pragma mark - IM

- (void)setupIMUI {
    CGFloat bottomExtraDistance  = 0;
    if (@available(iOS 11.0, *)) {
        bottomExtraDistance = [self getIPhonexExtraBottomHeight];
    }
    
    self.chatRoomView = [[RCChatRoomView alloc] initWithFrame:CGRectMake(-10, kScreenHeight - (237 +50)  - bottomExtraDistance, kScreenWidth, 237+50)];
    [self.view addSubview:self.chatRoomView];
        
    [self setupBottomView];

}

- (void)setupBottomView {
    
    [self commentTf];
    
    UIView *bottomButtonView = [[UIView alloc] init];
    [self.view addSubview:bottomButtonView];
    [bottomButtonView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view);
        make.centerY.equalTo(self.commentTf);
        make.height.mas_equalTo(40);
    }];
    
    NSString *selectedImage[] = {@"icon_microphone_on", @"icon_video_on",@"icon_quit_show"};
    NSString *normalImage[] = {@"icon_microphone_off",@"video-close",@"icon_quit_show"};
    SEL selectors[] = {@selector(microphoneAction:),@selector(videoAction:),@selector(quitRoom)};
    CGFloat buttonWidth = 40;
    NSInteger space = (kScreenWidth - 200 - buttonWidth * 3)/4;
    
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
}


- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    QNIMMessageObject *message = [self.sendMsgTool createChatMessage:textField.text];
    [[QNIMChatService sharedOption] sendMessage:message];
    [self.chatRoomView sendMessage:message];
    
    [self.commentTf resignFirstResponder];
    self.commentTf.text = @"";
}

- (float)getIPhonexExtraBottomHeight {
    float height = 0;
    if (@available(iOS 11.0, *)) {
        height = [[[UIApplication sharedApplication] keyWindow] safeAreaInsets].bottom;
    }
    return height;
}

- (void)RTCClient:(QNRTCClient *)client didConnectionStateChanged:(QNConnectionState)state disconnectedInfo:(QNConnectionDisconnectedInfo *)info {
    
    if (state == QNConnectionStateConnected) {
        
        if ([self.model.userInfo.role isEqualToString:@"roomHost"]) {
            [self publishOwnTrack];
        }
        
        [self.roomTool requestRoomHeartBeatWithInterval:@"3"];
    }
    
}

- (void)RTCClient:(QNRTCClient *)client didReceiveMessage:(QNMessageInfo *)message {
        
    if (message.content.length > 0) {
        
        [self.seatViews enumerateObjectsUsingBlock:^(QNApplyOnSeatView * _Nonnull seatView, NSUInteger idx, BOOL * _Nonnull stop) {
                    
        NSInteger tag =  message.content.integerValue;
            
            if (tag == idx + 101) {
                seatView.userId = message.userId;
            }
        }];
    }
}

//远端用户视频首帧解码后的回调
- (void)RTCClient:(QNRTCClient *)client firstVideoDidDecodeOfTrack:(QNRemoteVideoTrack *)videoTrack remoteUserID:(NSString *)userID {
    
    [self.rtcClient subscribe:@[videoTrack]];
        
    if ([self.roomEntity.provideHostUid isEqualToString:userID]) {
        
        QNVideoView *seatView = [[QNVideoView alloc]initWithFrame:CGRectMake(0, 0, self.preview.frame.size.width, self.preview.frame.size.height)];
        [self.preview addSubview:seatView];
        [videoTrack play:seatView];
        
    } else {
        
        for (QNApplyOnSeatView *seatView in self.seatViews) {
            if ([seatView.userId isEqualToString:userID]) {
                QNVideoView *vv = [[QNVideoView alloc]initWithFrame:CGRectMake(0, 0, seatView.frame.size.width, seatView.frame.size.height)];
                [seatView addSubview:vv];
                seatView.isSeat = YES;
                [videoTrack play:vv];
            }
        }
    }

}

- (void)RTCClient:(QNRTCClient *)client didLeaveOfUserID:(NSString *)userID {
    
    dispatch_async(dispatch_get_main_queue(), ^{
                
        //房主退出 ，通知其他成员退出
        if ([self.roomEntity.provideHostUid isEqualToString:userID]) {
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"房主已退出" message:@"所有成员将被移出房间" preferredStyle:UIAlertControllerStyleAlert];

            UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [self leave];
            }];
            [alertController addAction:cancelBtn];
            
            UIAlertAction *changeBtn = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self leave];
            }];
            [alertController addAction:changeBtn];
            
            [self presentViewController:alertController animated:YES completion:nil];
            
        } else {
            
            //房间成员退出   恢复麦位
            
            for (QNApplyOnSeatView *seatView in self.seatViews) {
                if ([seatView.userId isEqualToString:userID]) {
                    
                    [seatView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if ([obj isKindOfClass:[QNVideoView class]]) {
                            [obj removeFromSuperview];
                            seatView.isSeat = NO;
                        }
                    }];
                    
                }
            }
            
        }
    });
    
}

- (void)RTCClient:(QNRTCClient *)client didUserPublishTracks:(NSArray<QNRemoteTrack *> *)tracks ofUserID:(NSString *)userID {
    
    
}

- (void)RTCClient:(QNRTCClient *)client didUserUnpublishTracks:(nonnull NSArray<QNRemoteTrack *> *)tracks ofUserID:(nonnull NSString *)userID {
        
    
}

//发布自己的音视频流
- (void)publishOwnTrack {

    [self.localVideoTrack startCapture];
    
    if ([self.model.userInfo.role isEqualToString:@"roomHost"]) {
        [self.localVideoTrack play:self.preview];
    }
        
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
    
    [self.rtcClient publish:tracks completeCallback:^(BOOL onPublished, NSError *error) {
        
//        if (![self.model.userInfo.role isEqualToString:@"roomHost"]) {
//            
//            
//            [self sendMessageWithContent:@""];
//        }
        
    }];
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.text = self.model.roomInfo.title;
        _titleLabel.textColor = [UIColor whiteColor];
        [self.view addSubview:_titleLabel];
        
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.top.equalTo(self.view).offset(40);
        }];
    }
    return _titleLabel;
}

- (UITextField *)commentTf {
    if (!_commentTf) {
        _commentTf = [[UITextField alloc]initWithFrame:CGRectMake(15, kScreenHeight - 60, 200, 40)];
        _commentTf.backgroundColor = [UIColor blackColor];
        _commentTf.alpha = 0.5;
        _commentTf.delegate = self;
        _commentTf.font = [UIFont systemFontOfSize:14];
        _commentTf.layer.cornerRadius = 10;
        _commentTf.clipsToBounds = YES;
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"  说点什么..." attributes:
             @{NSForegroundColorAttributeName:[UIColor whiteColor],
               NSFontAttributeName:[UIFont systemFontOfSize:14]}];
        _commentTf.attributedPlaceholder = attrString;
        _commentTf.textColor = [UIColor whiteColor];
        [self.view addSubview:_commentTf];
    }
    return _commentTf;
}

- (QNRoomTools *)roomTool {
    if (!_roomTool) {
        _roomTool = [[QNRoomTools alloc]initWithType:@"show" roomId:self.model.roomInfo.roomId];
    }
    return _roomTool;
}

-(QNSendMsgTool *)sendMsgTool {
    if (!_sendMsgTool) {
        _sendMsgTool = [[QNSendMsgTool alloc]initWithToId:self.model.imConfig.imGroupId];
    }
    return _sendMsgTool;
}
@end
