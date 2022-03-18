//
//  QNMessageSend.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/12/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QNMessageSend : NSObject

//发送进房信令
+ (void)sendJoinRoomMessage:(NSString *)message;
//邀请信令
+ (void)sendInvitationMessage;
//上麦信令
+ (void)sendSitUpMessage;

@end

NS_ASSUME_NONNULL_END
