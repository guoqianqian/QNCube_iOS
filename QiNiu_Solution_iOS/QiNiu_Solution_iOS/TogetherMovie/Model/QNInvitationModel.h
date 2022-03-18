//
//  QNInvitationModel.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/12/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QNInvitationInfo : NSObject

@property(nonatomic, copy) NSString *channelId;

@property(nonatomic, copy) NSString *flag;

@property(nonatomic, copy) NSString *initiatorUid;

@property(nonatomic, copy) NSString *msg;

@property(nonatomic, copy) NSString *receiver;

@property(nonatomic, copy) NSString *timeStamp;
@end

@interface QNInvitationData : NSObject

@property(nonatomic, strong) QNInvitationInfo *invitation;

@property(nonatomic, copy) NSString *invitationName;

@end

@interface QNInvitationModel : NSObject

@property(nonatomic, copy) NSString *action;

@property(nonatomic, strong) QNInvitationData *data;

@end

NS_ASSUME_NONNULL_END
