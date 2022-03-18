//
//  QNJoinRepairModel.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/9/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//加入房间Model

@class QNJoinRepairUserInfoModel,QNJoinRepairRoomModel,QNIMModel;

@interface QNJoinRepairModel : NSObject

@property (nonatomic, strong) QNJoinRepairUserInfoModel *userInfo;

@property (nonatomic, copy) NSString *roomToken;

@property (nonatomic, copy) NSString *publishUrl;

@property (nonatomic, strong) QNJoinRepairRoomModel *roomInfo;

@property (nonatomic, strong) NSArray <QNJoinRepairUserInfoModel *> *allUserList;

@property (nonatomic, strong) QNIMModel *imConfig;

@property (nonatomic, copy) NSString *requestId;

@end

@interface QNIMModel : NSObject

@property (nonatomic, copy) NSString *imGroupId;

@property (nonatomic, copy) NSString *type;

@end

@interface QNJoinRepairUserInfoModel : NSObject

@property (nonatomic, copy) NSString *accountId;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *profile;
@property (nonatomic, copy) NSString *role;
@end

@interface QNJoinRepairRoomModel : NSObject

@property (nonatomic, copy) NSString *roomId;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *field_4;

@end

NS_ASSUME_NONNULL_END
