//
//  QNSendMsgTool.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2022/3/16.
//

#import "QNSendMsgTool.h"
#import "QNMicSeatMessageModel.h"
#import "QNUserMicSeatModel.h"
#import "QNIMMessageModel.h"
#import "QNInvitationModel.h"
#import "QNRTCRoomEntity.h"

@interface QNSendMsgTool ()

@property(nonatomic, copy)NSString *toId;

@end

@implementation QNSendMsgTool

- (instancetype)initWithToId:(NSString *)toId {
    if (self = [super init]) {
        self.toId = toId;
    }
    return self;
}

//生成加入房间消息
- (QNIMMessageObject *)createJoinRoomMessage {
    
    QNIMMessageObject *message = [self messageWithAction:@"welcome" content:@"加入房间"];
    return message;
}

//生成离开房间消息
- (QNIMMessageObject *)createLeaveRoomMessage {
    
    QNIMMessageObject *message = [self messageWithAction:@"quit_room" content:@"离开房间"];
    return message;
    
}

//生成聊天消息
- (QNIMMessageObject *)createChatMessage:(NSString *)content {
    
    QNIMMessageObject *message = [self messageWithAction:@"pub_chat_text" content:content];
    return message;
    
}

//发送上麦信令
- (QNIMMessageObject *)createOnMicMessage {
    QNIMMessageObject *message = [self sendMicMessage:@"rtc_sitDown"];
    return message;
}

//发送下麦信令
- (QNIMMessageObject *)createDownMicMessage {
    QNIMMessageObject *message = [self sendMicMessage:@"rtc_sitUp"];
    return message;
}

//发送邀请信令
- (QNIMMessageObject *)createInviteMessageWithInvitationName:(NSString *)invitationName receiverId:(NSString *)receiverId {
    
    QNIMMessageObject *message = [self createInviteMessageWithAction:@"invite_send" invitationName:invitationName receiverId:receiverId];
    return message;
}

//发送取消邀请信令
- (QNIMMessageObject *)createCancelInviteMessageWithInvitationName:(NSString *)invitationName receiverId:(NSString *)receiverId {
    
    QNIMMessageObject *message = [self createInviteMessageWithAction:@"invite_cancel" invitationName:invitationName receiverId:receiverId];
    return message;
}

//发送接受邀请信令
- (QNIMMessageObject *)createAcceptInviteMessageWithInvitationName:(NSString *)invitationName receiverId:(NSString *)receiverId {
    
    QNIMMessageObject *message = [self createInviteMessageWithAction:@"invite_accept" invitationName:invitationName receiverId:receiverId];
    return message;
}

//发送拒绝邀请信令
- (QNIMMessageObject *)createRejectInviteMessageWithInvitationName:(NSString *)invitationName receiverId:(NSString *)receiverId {
    
    QNIMMessageObject *message = [self createInviteMessageWithAction:@"invite_reject" invitationName:invitationName receiverId:receiverId];
    return message;
}



//生成邀请信令
- (QNIMMessageObject *)createInviteMessageWithAction:(NSString *)action invitationName:(NSString *)invitationName receiverId:(NSString *)receiverId {
    
    QNInvitationModel *model = [QNInvitationModel new];
    model.action = action;
    
    QNInvitationData *invitationData = [QNInvitationData new];
    invitationData.invitationName = invitationName;
    
    QNInvitationInfo *info = [QNInvitationInfo new];
    info.channelId = self.toId;
    info.initiatorUid = QN_User_id;
    info.msg = [NSString stringWithFormat:@"用户 %@ 邀请你一起连麦，是否加入？",QN_User_nickname];
    info.receiver =  receiverId;
    info.timeStamp = [self getNowTimeTimestamp3];
    
    invitationData.invitation = info;
    
    model.data = invitationData;
    
    QNIMMessageObject *message = [[QNIMMessageObject alloc]initWithQNIMMessageText:model.mj_JSONString fromId:QN_IM_userId.longLongValue toId:self.toId.longLongValue type:QNIMMessageTypeGroup conversationId:self.toId.longLongValue];
    message.senderName = QN_User_nickname;
    return message;
}

//生成进房/离房/聊天消息
- (QNIMMessageObject *)messageWithAction:(NSString *)action content:(NSString *)content {
    
    QNIMMessageModel *messageModel = [QNIMMessageModel new];
    messageModel.action = action;
    
    QNIMMessageStrModel *model = [QNIMMessageStrModel new];
    
    model.senderName = QN_User_nickname;
    model.senderId = QN_IM_userId;
    model.msgContent = content;
    
    messageModel.data = model;
    
    QNIMMessageObject *message = [[QNIMMessageObject alloc]initWithQNIMMessageText:messageModel.mj_JSONString fromId:model.senderId.longLongValue toId:self.toId.longLongValue type:QNIMMessageTypeGroup conversationId:self.toId.longLongValue];
    message.senderName = QN_User_nickname;
    return message;
    
}

//上下麦信令
- (QNIMMessageObject *)sendMicMessage:(NSString *)action {
    
    NSString *senderId = [[NSUserDefaults standardUserDefaults] objectForKey:QN_IM_USER_ID_KEY];

    QNMicSeatMessageModel *messageModel = [QNMicSeatMessageModel new];
    messageModel.action = action;
    
    QNUserMicSeatModel *micSeat = [QNUserMicSeatModel new];
    micSeat.ownerOpenAudio = YES;
    micSeat.ownerOpenVideo = YES;
    micSeat.uid = QN_User_id;
    
    QNUserExtension *user = [QNUserExtension new];
    user.uid = QN_User_id;
    
    QNUserExtProfile *profile = [QNUserExtProfile new];
    profile.name = QN_User_nickname;
    profile.avatar = QN_User_avatar;
    
    user.userExtProfile = profile;
    
    micSeat.userExtension = user;
    
    messageModel.data = micSeat;
    
    QNIMMessageObject *message = [[QNIMMessageObject alloc]initWithQNIMMessageText:messageModel.mj_JSONString fromId:senderId.longLongValue toId:self.toId.longLongValue type:QNIMMessageTypeGroup conversationId:self.toId.longLongValue];
    message.senderName = QN_User_nickname;
    return message;
    
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

@end
