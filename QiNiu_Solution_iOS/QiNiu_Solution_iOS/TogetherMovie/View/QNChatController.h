//
//  QNChatController.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/12/6.
//

#import <UIKit/UIKit.h>
#import <QNIMSDK/QNIMSDK.h>

NS_ASSUME_NONNULL_BEGIN

@class QNMovieTogetherChannelModel,QNInvitationModel,QNMicSeatMessageModel,QNIMMessageModel;

@interface QNChatController : UIViewController

@property (nonatomic,copy) NSString *groupId;

@property (nonatomic, copy) void (^movieSynchronousBlock)(QNMovieTogetherChannelModel *model);//收到电影同步信令

@property (nonatomic, copy) void (^invitationBlock)(QNInvitationModel *model);//收到邀请连麦信令

@property (nonatomic, copy) void (^invitationAcceptBlock)(QNInvitationModel *model);//连麦邀请被接受

@property (nonatomic, copy) void (^sitDownMicBlock)(QNMicSeatMessageModel *model);//收到上麦信令

@property (nonatomic, copy) void (^sitUpMicBlock)(QNMicSeatMessageModel *model);//收到下麦信令

@property (nonatomic, copy) void (^joinRoomBlock)(QNIMMessageModel *model);//收到加入房间信令

@property (nonatomic, copy) void (^leaveRoomBlock)(QNIMMessageModel *model);//收到离开房间信令

- (void)sendMessageWithMessage:(QNIMMessageObject *)message;

- (void)sendMessageWithAction:(NSString *)action content:(NSString *)content;

@end

NS_ASSUME_NONNULL_END
