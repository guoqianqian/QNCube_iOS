//
//  QNChatController.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/12/6.
//

#import "QNChatController.h"
#import "CSMessageCell.h"
#import "CSMessageModel.h"
#import "CSBigView.h"
#import "EmojiView.h"
#import "CSRecord.h"
#import <Masonry/Masonry.h>
#import <QNIMSDK/QNIMSDK.h>
#import "QNIMMessageModel.h"
#import <MJExtension/MJExtension.h>
#import "QNMovieTogetherChannelModel.h"
#import "QNInvitationModel.h"
#import "QNMicSeatMessageModel.h"

#define ScreenWidth  [UIScreen mainScreen].bounds.size.width
#define ScreenHight [UIScreen mainScreen].bounds.size.height

@interface QNChatController ()<UITextViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,CSMessageCellDelegate, EmojiViewDelegate,UITableViewDelegate,UITableViewDataSource,QNIMChatServiceProtocol>

@property (strong, nonatomic) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UIImageView *photoImageView;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) CSBigView *bigImageView;
@property (nonatomic, strong) EmojiView *ev;
@property (nonatomic, strong) UIImage *photoImage;
@property (nonatomic, strong) NSIndexPath *selectIndex;
@property (weak, nonatomic) NSLayoutConstraint *tableBottomConstraint;

@end

@implementation QNChatController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[QNIMChatService sharedOption] addDelegate:self delegateQueue:dispatch_get_main_queue()];
    _dataArray = [NSMutableArray arrayWithCapacity:0];
    
    [self tableView];
    _bigImageView = [[CSBigView alloc] init];
    _bigImageView.frame = [UIScreen mainScreen].bounds;
    
    _ev = [[EmojiView alloc] initWithFrame:CGRectMake(0, ScreenHight - 180, ScreenWidth, 180)];
    _ev.hidden = YES;
    _ev.delegate = self;
    [self.view addSubview:_ev];
    
    CSMessageModel *model = [[CSMessageModel alloc] init];
    model.showMessageTime=YES;
    model.messageTime = [NSString stringWithFormat:@"欢迎用户 %@ 进入房间",[[NSUserDefaults standardUserDefaults] objectForKey:QN_NICKNAME_KEY]];
    model.messageSenderType = MessageSenderTypeMe;
    model.messageType = MessageTypeJoin;
    [_dataArray addObject:model];
    
    [self sendMessageWithAction:@"welcome" content:model.messageTime];
           
    _tableView.separatorColor = [UIColor clearColor];
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
-(void)keyboardWillShow:(NSNotification *)aNotification
{
    _ev.hidden = YES;
    //获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    int height = keyboardRect.size.height;
    _tableBottomConstraint.constant = 44 + height;
    UIView *vi = [self.view viewWithTag:100];
    CGRect rec = vi.frame ;
    rec.origin.y = self.view.frame.size.height-64 - height;
    vi.frame = rec;
}
- (void)keyboardWillHide:(NSNotification *)aNotification
{
    _ev.hidden = YES;
    _tableBottomConstraint.constant = 44;
    UIView *vi = [self.view viewWithTag:100];
    vi.frame = CGRectMake(0, self.view.frame.size.height-64, [UIScreen mainScreen].bounds.size.width, 44);
}
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    UIView *vi = [self.view viewWithTag:100];
    if (!vi)
    {
        [self bottomView];
    }
    
}

- (void)sendMessageWithAction:(NSString *)action content:(NSString *)content {
    
    QNIMMessageModel *messageModel = [QNIMMessageModel new];
    messageModel.action = action;
    
    QNIMMessageStrModel *strModel = [QNIMMessageStrModel new];
    
    strModel.senderName = [[NSUserDefaults standardUserDefaults] objectForKey:QN_NICKNAME_KEY];
    strModel.senderId = [[NSUserDefaults standardUserDefaults] objectForKey:QN_IM_USER_ID_KEY];
    strModel.sendAvatar = [[NSUserDefaults standardUserDefaults] objectForKey:QN_USER_AVATAR_KEY];
    strModel.msgContent = content;
    
    messageModel.data = strModel;
    
    QNIMMessageObject *message = [[QNIMMessageObject alloc]initWithQNIMMessageText:messageModel.mj_JSONString fromId:strModel.senderId.longLongValue toId:self.groupId.longLongValue type:QNIMMessageTypeGroup conversationId:self.groupId.longLongValue];
    
    [[QNIMChatService sharedOption] sendMessage:message];
}

- (void)sendMessageWithMessage:(QNIMMessageObject *)message {
    [[QNIMChatService sharedOption] sendMessage:message];
}

- (void)messageStatusChanged:(QNIMMessageObject *)message error:(QNIMError *)error {
    
}

#pragma mark -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CSMessageCell *cell=[tableView dequeueReusableCellWithIdentifier:@"CSMessageCell" forIndexPath:indexPath];
    cell.messageModel = _dataArray[indexPath.row];
    cell.delegate = self;
    cell.backgroundColor = [[UIColor alloc] initWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CSMessageModel *model = _dataArray[indexPath.row];
    return [model cellHeight];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1;
}
- (void)messageCellSingleClickedWith:(CSMessageCell *)cell
{
    
    [self.view endEditing:YES];
        
    if (_ev.hidden == NO)
    {
        _ev.hidden = YES;
        _tableBottomConstraint.constant = 44;
        UIView *vi = [self.view viewWithTag:100];
        vi.frame = CGRectMake(0, self.view.frame.size.height-64, [UIScreen mainScreen].bounds.size.width, 44);
    }
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    CSMessageModel *model = _dataArray[indexPath.row];
    if (model.messageType == MessageTypeVoice)
    {
        [[CSRecord ShareCSRecord] playRecord];
        
        if ([_selectIndex isEqual: indexPath] == NO)
        {
            
            CSMessageCell *cell1 = [self.tableView cellForRowAtIndexPath:_selectIndex];
            [cell1 stopVoiceAnimation];
            
            _selectIndex = indexPath;
            [cell startVoiceAnimation];
        }
        else
        {
            if (cell.voiceAnimationImageView.isAnimating)
            {
                [cell stopVoiceAnimation];
            }
            else
            {
                [cell startVoiceAnimation];
            }
        }
    }
    else if (model.messageType == MessageTypeImage)
    {
        _bigImageView.bigImageView.image = model.imageSmall;
        _bigImageView.show = YES;
        
//        [[UIApplication sharedApplication].keyWindow bringSubviewToFront:_bigImageView];
    }
    
}

-(void)bottomView
{
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-64, [UIScreen mainScreen].bounds.size.width, 44)];
    bgView.tag = 100;
    bgView.backgroundColor = [UIColor blackColor];
    bgView.layer.masksToBounds = YES;
    bgView.layer.borderColor = [UIColor blackColor].CGColor;
    bgView.layer.borderWidth = 1;
    [self.view addSubview:bgView];
    
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(20, 0, bgView.bounds.size.width - 90, 44)];
    self.textView.layer.cornerRadius = 25;
    self.textView.clipsToBounds = YES;
    self.textView.delegate = self;
    self.textView.tag = 101;
    self.textView.textColor = [UIColor whiteColor];
    self.textView.returnKeyType = UIReturnKeySend;
    self.textView.backgroundColor = [UIColor darkGrayColor];
    self.textView.alpha = 0.7;
    self.textView.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
    [bgView addSubview:self.textView];

    
    UIButton *imageBtn = [[UIButton alloc] init];
    imageBtn.frame = CGRectMake(bgView.frame.size.width - 65, 5, 50, 34);
    imageBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [imageBtn setTitle:@"发送" forState:UIControlStateNormal];
    [imageBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [imageBtn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    imageBtn.tag = 14;
    [bgView addSubview:imageBtn];
    
}

- (void)textViewDidEndEditing:(UITextView *)textView {

        if (textView.text.length == 0)
        {
            return;
        }
        CSMessageModel *model = [[CSMessageModel alloc] init];
        model.messageSenderType = MessageSenderTypeMe;
        model.messageType = MessageTypeText;
        model.messageText = textView.text;
        [_dataArray addObject:model];
        [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:_dataArray.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:_dataArray.count - 1 inSection:0]
                                    animated:YES
                              scrollPosition:UITableViewScrollPositionMiddle];
        textView.text = @"";
    
    [self sendMessageWithAction:@"pubChatText" content:model.messageText];
    
}

//收到message
- (void)receivedMessages:(NSArray<QNIMMessageObject *> *)messages {
        
    QNIMMessageModel *messageModel = [QNIMMessageModel mj_objectWithKeyValues:messages.firstObject.content];
    
    if ([messageModel.action isEqualToString:@"pubChatText"]) {//聊天消息
        CSMessageModel *model = [[CSMessageModel alloc] init];
        model.messageSenderType = MessageSenderTypeOther;
        model.messageType = MessageTypeText;
        model.messageText = messageModel.data.msgContent;
        model.serverTimestamp = messages.firstObject.serverTimestamp;
       __block BOOL same = false;
        [self.dataArray enumerateObjectsUsingBlock:^(CSMessageModel   * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.serverTimestamp == model.serverTimestamp) {
                same = true;
            }
        }];
            
        if (same == false) {
            [_dataArray addObject:model];
            [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:_dataArray.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:_dataArray.count - 1 inSection:0]
                                        animated:YES
                                  scrollPosition:UITableViewScrollPositionMiddle];
        }
            
        
        
    } else if ([messageModel.action isEqualToString:@"welcome"]) {//欢迎消息
        
        CSMessageModel *model = [[CSMessageModel alloc] init];
        model.showMessageTime=YES;
        model.messageTime = [NSString stringWithFormat:@"欢迎用户 %@ 进入房间",messageModel.data.senderName];
        model.messageSenderType = MessageSenderTypeMe;
        model.messageType = MessageTypeJoin;
        model.serverTimestamp = messages.firstObject.serverTimestamp;
        __block BOOL same = false;
         [self.dataArray enumerateObjectsUsingBlock:^(CSMessageModel   * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
             if (obj.serverTimestamp == model.serverTimestamp) {
                 same = true;
             }
         }];
             
         if (same == false) {
             [_dataArray addObject:model];
             [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:_dataArray.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
             [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:_dataArray.count - 1 inSection:0]
                                         animated:YES
                                   scrollPosition:UITableViewScrollPositionMiddle];
             if (self.joinRoomBlock) {
                 self.joinRoomBlock(messageModel);
             }
         }
        
        
    } else if ([messageModel.action isEqualToString:@"quit_room"]) {//离开消息
      
        if (self.leaveRoomBlock) {
            self.leaveRoomBlock(messageModel);
        }
    } else if ([messageModel.action isEqualToString:@"channelAttributes_change"]) {//电影同步消息
        
        QNMovieTogetherChannelModel *model = [QNMovieTogetherChannelModel mj_objectWithKeyValues:messageModel.data.value.mj_keyValues];
        if (self.movieSynchronousBlock) {
            self.movieSynchronousBlock(model);
        }
        
    } else if ([messageModel.action isEqualToString:@"invite_send"]) {//连麦邀请消息
        
        QNInvitationModel *model = [QNInvitationModel mj_objectWithKeyValues:messages.firstObject.content];
        if (self.invitationBlock) {
            self.invitationBlock(model);
        }
        
    } else if ([messageModel.action isEqualToString:@"invite_reject"]) {//连麦被拒绝消息
        
        [MBProgressHUD showText:@"对方拒绝了你的连麦申请"];
        
    } else if ([messageModel.action isEqualToString:@"invite_accept"]) {//连麦被接受消息
        
        QNInvitationModel *model = [QNInvitationModel mj_objectWithKeyValues:messages.firstObject.content];
        if (self.invitationAcceptBlock) {
            self.invitationAcceptBlock(model);
        }
        
    } else if ([messageModel.action isEqualToString:@"rtc_sitDown"]) {//用户上麦信息
        
        QNMicSeatMessageModel *model = [QNMicSeatMessageModel mj_objectWithKeyValues:messages.firstObject.content];
        if (self.sitDownMicBlock) {
            self.sitDownMicBlock(model);
        }
    } else if ([messageModel.action isEqualToString:@"rtc_sitUp"]) {//用户下麦信息
        
        QNMicSeatMessageModel *model = [QNMicSeatMessageModel mj_objectWithKeyValues:messages.firstObject.content];
        if (self.sitUpMicBlock) {
            self.sitUpMicBlock(model);
        }
    }
    
}

static int iiii = 0;
- (void)touchDown:(UIButton *)btn
{
    if (iiii == 0)
    {
        [[CSRecord ShareCSRecord] beginRecord];
        iiii = 1;
    }
    
}
- (void)leaveBtnClicked:(UIButton *)btn
{
    iiii = 0;
    NSLog(@"松开了");
    [[CSRecord ShareCSRecord] endRecord];
}
- (void)btnClicked:(UIButton *)btn
{
    [self.view endEditing:YES];
    _ev.hidden = YES;
    _tableBottomConstraint.constant = 44;
    UIView *vi = [self.view viewWithTag:100];
    vi.frame = CGRectMake(0, self.view.frame.size.height-64, [UIScreen mainScreen].bounds.size.width, 44);
    switch (btn.tag)
    {
        case 11:
            
            break;
        case 12:
            
        {
            
            _ev.hidden = NO;
            _tableBottomConstraint.constant = 44 + 180;
            UIView *vi = [self.view viewWithTag:100];
            CGRect rec = vi.frame ;
            rec.origin.y = self.view.frame.size.height-64 - 180;
            vi.frame = rec;

        }
            
            break;
        case 13:
            {
                
                
                
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请选择" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
                [alertController addAction:[UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    UIImagePickerController * picker = [[UIImagePickerController alloc]init];
                    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                        
                        //图片选择是相册（图片来源自相册）
                        
                        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                        
                        //设置代理
                        
                        picker.delegate=self;
                        
                        //模态显示界面
                        
                        [self presentViewController:picker animated:YES completion:nil];
                        
                    }
                    
                    else {
                        
                        NSLog(@"不支持相机");
                        
                    }
                    

                    NSLog(@"点击确认");
                    
                }]];
                [alertController addAction:[UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                    UIImagePickerController * picker = [[UIImagePickerController alloc]init];
                    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                        
                        //图片选择是相册（图片来源自相册）
                        
                        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                        
                        //设置代理
                        
                        picker.delegate=self;
                        
                        //模态显示界面
                        
                        [self presentViewController:picker animated:YES completion:nil];
                        
                        
                        
                    }
                    
                    NSLog(@"点击确认");
                    
                }]];
                [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    
                    [self dismissViewControllerAnimated:YES completion:nil];
                    NSLog(@"点击取消");
                    
                }]];
                
                [self presentViewController:alertController animated:YES completion:nil];
                
            }
            break;
            
        case 14:{
            
            [self.textView endEditing:YES];
        }
            break;
        default:
            break;
    }
    NSLog(@"呀！我这个按钮别点击了！");
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
     if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary)
     {
        UIImage * image =info[UIImagePickerControllerOriginalImage];
        CSMessageModel * model = [[CSMessageModel alloc] init];
         model.messageSenderType = MessageSenderTypeOther;
         model.messageType = MessageTypeImage;
         model.imageSmall = image;
         [_dataArray addObject:model];
         
         [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:_dataArray.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
         [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:_dataArray.count - 1 inSection:0]
                                     animated:YES
                               scrollPosition:UITableViewScrollPositionMiddle];
         
        [self dismissViewControllerAnimated:YES completion:nil];
     }
   else if (picker.sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        UIImage * image =info[UIImagePickerControllerOriginalImage];
        CSMessageModel * model = [[CSMessageModel alloc] init];
        model.messageSenderType = MessageSenderTypeOther;
        model.messageType = MessageTypeImage;
        model.imageSmall = image;
        [_dataArray addObject:model];
        
        [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:_dataArray.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:_dataArray.count - 1 inSection:0]
                                    animated:YES
                              scrollPosition:UITableViewScrollPositionMiddle];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
- (void)showBigImage
{
    
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor blackColor];
        [self.view addSubview:_tableView];
    
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self.view);
            make.bottom.equalTo(self.view.mas_bottom).offset(-64);
        }];
        
        [_tableView registerClass:[CSMessageCell class] forCellReuseIdentifier:@"CSMessageCell"];
        
    }
    return _tableView;
}
#pragma mark - EmojiViewDelegate
- (void)emojiClicked:(NSString *)strEmoji {
    UITextView *tv = [self.view viewWithTag:101];
    tv.text = [tv.text stringByAppendingString:strEmoji];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
