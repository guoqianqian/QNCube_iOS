//
//  QNVoiceChatRoomController.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2022/1/10.
//

#import "QNVoiceChatRoomController.h"
#import "QNRoomDetailModel.h"
#import "QNRTCRoomEntity.h"
#import "QNVoiceChatRoomChaterCell.h"
#import "QNQNVoiceChatRoomOnlineCell.h"
#import "QNVoiceChatRoomBottomView.h"
#import "QNVoiceChatRoomListController.h"
#import "QNAudioTrackParams.h"
#import "QNMicSeatMessageModel.h"
#import "QNUserMicSeatModel.h"
#import "QNIMMessageModel.h"
#import <YYCategories/YYCategories.h>
#import "RCChatRoomView.h"
#import "QNApplyOnSeatView.h"
#import "QNRoomTools.h"
#import "QNSendMsgTool.h"
#import "QNAlertViewController.h"
#import "QNVoiceChatRoomCell.h"

@interface QNVoiceChatRoomController ()<QNRTCClientDelegate,UITextFieldDelegate,QNIMChatServiceProtocol,UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) RCChatRoomView * chatRoomView;

@property (nonatomic, strong) QNRoomTools *roomTool;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) QNSendMsgTool *sendMsgTool;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UITextField *commentTf;

@property (nonatomic, strong) UIImageView *masterSeat;//房主座位

@property (nonatomic, strong) NSMutableArray <QNUserInfo *> *allUserList;

@property (nonatomic, strong) NSMutableArray <QNRTCMicsInfo *> *onMicUserList;

@property (nonatomic, copy) NSString *role;

@property (nonatomic, copy) NSString *imGroupId;

@end

@implementation QNVoiceChatRoomController

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
    
    [[QNIMChatService sharedOption] addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    UIImageView *bg = [[UIImageView alloc]initWithFrame:self.view.frame];
    bg.image = [UIImage imageNamed:@"voice_chat_bg"];
    [self.view addSubview:bg];
   
    [self titleLabel];
    [self masterSeat];
//    [self collectionView];
    [self setupIMUI];
    [self setupBottomView];
    [self requestData];
    
}

- (float)getIPhonexExtraBottomHeight {
    float height = 0;
    if (@available(iOS 11.0, *)) {
        height = [[[UIApplication sharedApplication] keyWindow] safeAreaInsets].bottom;
    }
    return height;
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
    
    NSString *selectedImage[] = {@"icon_microphone_on", @"icon_quit_show"};
    NSString *normalImage[] = {@"icon_microphone_off",@"icon_quit_show"};
    SEL selectors[] = {@selector(microphoneAction:),@selector(quitRoom)};
    CGFloat buttonWidth = 40;
    NSInteger space = (kScreenWidth - self.commentTf.width - buttonWidth * ARRAY_SIZE(normalImage))/(ARRAY_SIZE(normalImage)+1);
    
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

- (void)quitRoom {
    if ([QN_User_id isEqualToString:self.model.roomInfo.creator]) {
        [QNAlertViewController showBaseAlertWithTitle:@"确定要关闭房间？" content:@"关闭房间后，其他成员也将被踢出房间" handler:^(UIAlertAction * _Nonnull action) {
            [self requestLeave];
        }];
    } else {
        [self requestLeave];
    }
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

//加入房间
- (void)requestData {
    
    NSMutableArray *arr = [NSMutableArray array];
    
    QNAttrsModel *model1 = [QNAttrsModel new];
    model1.key = @"role";
    model1.value = self.model.userInfo.role ?:@"roomAudience";
    self.role = model1.value;
    [arr addObject:model1];
        
    [self.roomTool requestJoinRoomWithParams:[QNAttrsModel mj_keyValuesArrayWithObjectArray:arr] success:^(QNRoomDetailModel * roomDetailodel) {
        
        self.model = roomDetailodel;
        self.allUserList = self.model.allUserList;
        QNUserInfo *userInfo = [QNUserInfo new];
        userInfo.role = self.role;
        self.model.userInfo = userInfo;
        
        __weak typeof(self)weakSelf = self;
        [[QNIMGroupService sharedOption] joinGroupWithGroupId:self.model.imConfig.imGroupId message:@"" completion:^(QNIMError * _Nonnull error) {
            weakSelf.imGroupId = weakSelf.model.imConfig.imGroupId;
            
            QNIMMessageObject *message = [self.sendMsgTool createJoinRoomMessage];
            [[QNIMChatService sharedOption] sendMessage:message];
            [self.chatRoomView sendMessage:message];
        }];
        
        [self joinRoomOption];
        
        } failure:nil];
    
    
}

//获取房间信息
- (void)getRoomInfo {
    
    [self.roomTool requestRoomInfoSuccess:^(QNRoomDetailModel * _Nonnull roomDetailodel) {
            
        self.model = roomDetailodel;
        self.allUserList = roomDetailodel.allUserList;
        
        QNUserInfo *userInfo = [QNUserInfo new];
        userInfo.role = self.role;
        self.model.userInfo = userInfo;
        
        } failure:^(NSError * _Nonnull error) {
        }];
}

//获取房间麦位信息
- (void) getRoomMicInfo {
    
    [self.roomTool requestRoomMicInfoSuccess:^(QNRoomDetailModel * _Nonnull roomDetailodel) {
        __weak typeof(self)weakSelf = self;
        [self dealMicArrayWithAllMics:roomDetailodel.mics callBack:^(NSMutableArray<QNRTCMicsInfo *> *arr) {
            weakSelf.onMicUserList = arr;
            [weakSelf.collectionView reloadData];
        }];
        
        } failure:^(NSError * _Nonnull error) {
            
        }];
}

//请求上麦接口
- (void)requestUpMicSeat {
    
    [self.roomTool requestUpMicSeatWithUserExtRoleType:self.model.userInfo.role clientRoleType:1 success:^{
        
        QNIMMessageObject *message = [self.sendMsgTool createOnMicMessage];
        [[QNIMChatService sharedOption] sendMessage:message];
        [self publishOwnTrack];
        [self getRoomMicInfo];
        } failure:^(NSError * _Nonnull error) {
            
        }];
}

//离开房间
- (void)requestLeave {
    
    QNIMMessageObject *message = [self.sendMsgTool createLeaveRoomMessage];
    [[QNIMChatService sharedOption] sendMessage:message];
    [self.chatRoomView sendMessage:message];
    [self.roomTool requestDownMicSeat];
    [self.roomTool requestLeaveRoom];
    [self dismissViewControllerAnimated:YES completion:nil];
    [self leaveRoom];
        
}

- (void)RTCClient:(QNRTCClient *)client didConnectionStateChanged:(QNConnectionState)state disconnectedInfo:(QNConnectionDisconnectedInfo *)info {
    
    if (state == QNConnectionStateConnected) {
        
        if ([QN_User_id isEqualToString:self.model.roomInfo.creator]) {
            [self requestUpMicSeat];
        } else {
            [self getRoomMicInfo];
        }
        
        [self.roomTool requestRoomHeartBeatWithInterval:@"3"];
    }
    
}

- (void)RTCClient:(QNRTCClient *)client didJoinOfUserID:(NSString *)userID userData:(NSString *)userData {    
    [self getRoomInfo];
}

- (void)RTCClient:(QNRTCClient *)client didLeaveOfUserID:(NSString *)userID {
    [self getRoomMicInfo];
    [self getRoomInfo];
}

- (void)RTCClient:(QNRTCClient *)client didUserPublishTracks:(NSArray<QNRemoteTrack *> *)tracks ofUserID:(NSString *)userID {
    [self getRoomMicInfo];
}

//发布自己的音频
- (void)publishOwnTrack {
        
    NSMutableArray *tracks = [NSMutableArray array];
    
    QNAudioTrackParams *param = [QNAudioTrackParams new];
    param.volume = 0.5;
    [self setUpLocalAudioTrackParams:param];
    [tracks addObject:self.localAudioTrack];
    
    [self.rtcClient publish:tracks completeCallback:^(BOOL onPublished, NSError *error) {
        
    }];
}

- (void)messageStatusChanged:(QNIMMessageObject *)message error:(QNIMError *)error {
    
}

- (void)receivedMessages:(NSArray<QNIMMessageObject *> *)messages {
    
    QNIMMessageModel *messageModel = [QNIMMessageModel mj_objectWithKeyValues:messages.firstObject.content];
    
    if ([messageModel.action isEqualToString:@"invite_send"]) {//连麦邀请消息
        
    } else if ([messageModel.action isEqualToString:@"invite_reject"]) {//连麦被拒绝消息
        
        [MBProgressHUD showText:@"对方拒绝了你的连麦申请"];
        
    } else if ([messageModel.action isEqualToString:@"invite_accept"]) {//连麦被接受消息
        
    } else if ([messageModel.action isEqualToString:@"rtc_sitDown"]) {//用户上麦信息
        
        [self getRoomMicInfo];
        
    } else if ([messageModel.action isEqualToString:@"rtc_sitUp"]) {//用户下麦信息
        
        [self getRoomMicInfo];
        
    } else if ([messageModel.action isEqualToString:@"welcome"]){ //进房消息
        [self.chatRoomView showMessage:messages.firstObject];
        [self getRoomInfo];
        [self getRoomMicInfo];
    } else if ([messageModel.action isEqualToString:@"quit_room"]) {//离开消息
        
        if ([messageModel.data.senderId isEqualToString:self.model.roomInfo.creator]) {
            [QNAlertViewController showBaseAlertWithTitle:@"房间已解散" content:@"房主离开后，其他成员也将被踢出房间" handler:^(UIAlertAction * _Nonnull action) {
                [self requestLeave];
            }];
        }
        
        [self.chatRoomView showMessage:messages.firstObject];
        [self getRoomInfo];
        [self getRoomMicInfo];
       
    } else if ([messageModel.action isEqualToString:@"pub_chat_text"]) {//聊天消息
        [self.chatRoomView showMessage:messages.firstObject];
    }
}

- (void)leaveToRoomList {
    
    UIViewController * presentingViewController = self.presentingViewController;
    do {
        if ([presentingViewController isKindOfClass:[QNVoiceChatRoomListController class]]) {
            break;
        }
        presentingViewController = presentingViewController.presentingViewController;
        
    } while (presentingViewController.presentingViewController);

    [presentingViewController dismissViewControllerAnimated:YES completion:nil];
    
    [self requestLeave];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 6;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    QNVoiceChatRoomCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"QNVoiceChatRoomCell" forIndexPath:indexPath];
    [cell updateWithModel:self.onMicUserList[indexPath.item]];
    __weak typeof(self)weakSelf = self;
    cell.onSeatBlock = ^{
        if ([self isOnMic]) {
            [MBProgressHUD showText:@"您已经在麦上"];
            return;
        }
        QNIMMessageObject *message = [self.sendMsgTool createChatMessage:@"参与了连麦"];
        [[QNIMChatService sharedOption] sendMessage:message];
        [self.chatRoomView sendMessage:message];
        [weakSelf requestUpMicSeat];
    };
    return cell;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    QNIMMessageObject *message = [self.sendMsgTool createChatMessage:textField.text];
    [[QNIMChatService sharedOption] sendMessage:message];
    [self.chatRoomView sendMessage:message];
    
    [self.commentTf resignFirstResponder];
    self.commentTf.text = @"";
}

//判断是否已经在麦上
- (BOOL)isOnMic {
    if ([QN_User_id isEqualToString:self.model.roomInfo.creator]) {
        [MBProgressHUD showText:@"您已经在麦上"];
        return YES;
    }
    for (QNRTCMicsInfo  *mic in self.onMicUserList) {
        if ([QN_User_id isEqualToString:mic.uid]) {
            return YES;
        }
    }
    return NO;
}
//处理麦位数组(将房主的麦位从数组中剔除)
- (void)dealMicArrayWithAllMics:(NSArray <QNRTCMicsInfo *> *)allMics callBack:(void (^)(NSMutableArray <QNRTCMicsInfo *> *arr))callBack{
        
    [self.onMicUserList removeAllObjects];
    
    NSMutableArray *arr = [NSMutableArray arrayWithArray:allMics];
    //房主不显示在连麦位置上
    for (QNRTCMicsInfo *mic in allMics) {
        if ([mic.uid isEqualToString:self.model.roomInfo.creator]) {
            
            NSData *JSONData = [mic.userExtension dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableLeaves error:nil];

            QNUserExtension *user = [QNUserExtension mj_objectWithKeyValues:dic];
            [self.masterSeat sd_setImageWithURL:[NSURL URLWithString:user.userExtProfile.avatar] placeholderImage:[UIImage imageNamed:@"titleImage"]];
            
            [arr removeObject:mic];
        }
    }
    //空位置index补充
    for (int i = 0; i < 6; i++) {
        QNRTCMicsInfo * mic = [QNRTCMicsInfo new];
        
        QNUserExtension *user = [QNUserExtension new];
        user.uid = @"uid";
        QNUserExtProfile *profile = [QNUserExtProfile new];
        profile.name = @"name";
//        profile.avatar = @"avatar";
        user.userExtProfile = profile;
        
        mic.userExtension = user.mj_JSONString;
        
        if (arr.count < 6) {
            [arr addObject:mic];
        }
    }
    callBack(arr);
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
        _commentTf = [[UITextField alloc]initWithFrame:CGRectMake(15, kScreenHeight - 60, 250, 40)];
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

- (UIImageView *)masterSeat{
    if (!_masterSeat) {
        _masterSeat = [[UIImageView alloc]initWithFrame:CGRectMake(20, 80, 120, 120)];
        _masterSeat.layer.cornerRadius = 10;
        _masterSeat.clipsToBounds = YES;
        [self.view addSubview:_masterSeat];
    }
    return _masterSeat;
}

- (void)setupIMUI {
    CGFloat bottomExtraDistance  = 0;
    if (@available(iOS 11.0, *)) {
        bottomExtraDistance = [self getIPhonexExtraBottomHeight];
    }
    self.chatRoomView = [[RCChatRoomView alloc] initWithFrame:CGRectMake(-10, kScreenHeight - (237 +50)  - bottomExtraDistance, kScreenWidth, 237+50)];
    [self.view addSubview:self.chatRoomView];
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.minimumLineSpacing = 10;
        layout.minimumInteritemSpacing = 10;
        layout.itemSize = CGSizeMake((kScreenWidth - 80)/3, (kScreenWidth - 80)/3);
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
        [_collectionView setBackgroundColor:[UIColor clearColor]];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        [_collectionView registerClass:[QNVoiceChatRoomCell class] forCellWithReuseIdentifier:@"QNVoiceChatRoomCell"];
        [self.view addSubview:_collectionView];
        [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(20);
            make.right.equalTo(self.view).offset(-20);
            make.top.equalTo(self.masterSeat.mas_bottom).offset(10);
            make.height.mas_equalTo(((kScreenWidth - 80)/3)*2+20);
        }];
    }
    return _collectionView;
}

- (QNRoomTools *)roomTool {
    if (!_roomTool) {
        _roomTool = [[QNRoomTools alloc]initWithType:@"voiceChatRoom" roomId:self.model.roomInfo.roomId];
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
