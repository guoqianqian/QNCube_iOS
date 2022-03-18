//
//  QNJoinInterViewModel.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/4/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class QNInterviewItemModel,QNInterViewListModel;


@interface QNJoinInterViewUserInfoModel : NSObject

@property (nonatomic, copy) NSString *accountId;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *profile;
@end

@interface QNInterviewEndOption : NSObject

@property (nonatomic, assign) BOOL showLeaveInterview;

@end

@interface QNIMConfig : NSObject

@property (nonatomic, copy) NSString *imGroupId;

@property (nonatomic, copy) NSString *type;

@end

@interface QNJoinInterviewModel : NSObject

@property (nonatomic, strong) QNInterviewItemModel *interview;

//七牛云房间token
@property (nonatomic, copy) NSString *roomToken;

@property (nonatomic, strong) QNIMConfig *imConfig;

//当前进房用户信息
@property (nonatomic, strong) NSArray <QNJoinInterViewUserInfoModel *> *userInfo;
//在线用户列表
@property (nonatomic, strong) NSArray <QNJoinInterViewUserInfoModel *> *onlineUserList;
//全部用户列表
@property (nonatomic, strong) NSArray <QNJoinInterViewUserInfoModel *> *allUserList;
//心跳间隔请求时间
@property (nonatomic, assign) NSInteger interval;

@property (nonatomic, strong) QNInterviewEndOption *options;

@end

NS_ASSUME_NONNULL_END
