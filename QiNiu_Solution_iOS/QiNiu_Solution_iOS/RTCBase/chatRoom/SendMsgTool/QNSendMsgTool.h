//
//  QNSendMsgTool.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2022/3/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class QNIMMessageObject;

@interface QNSendMsgTool : NSObject

- (instancetype)initWithToId:(NSString *)toId;

//加入房间消息
- (QNIMMessageObject *)createJoinRoomMessage;

//离开房间消息
- (QNIMMessageObject *)createLeaveRoomMessage;

//聊天消息
- (QNIMMessageObject *)createChatMessage:(NSString *)content;

//上麦信令
- (QNIMMessageObject *)createOnMicMessage;

//下麦信令
- (QNIMMessageObject *)createDownMicMessage;

//邀请信令
- (QNIMMessageObject *)createInviteMessageWithInvitationName:(NSString *)invitationName receiverId:(NSString *)receiverId;

//取消邀请信令
- (QNIMMessageObject *)createCancelInviteMessageWithInvitationName:(NSString *)invitationName receiverId:(NSString *)receiverId;

//接受邀请信令
- (QNIMMessageObject *)createAcceptInviteMessageWithInvitationName:(NSString *)invitationName receiverId:(NSString *)receiverId;

//拒绝邀请信令
- (QNIMMessageObject *)createRejectInviteMessageWithInvitationName:(NSString *)invitationName receiverId:(NSString *)receiverId;


@end

NS_ASSUME_NONNULL_END
