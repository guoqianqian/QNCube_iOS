//
//  QNRoomDetailModel.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/11/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QNAttrsModel : NSObject

@property (nonatomic, copy) NSString *key;

@property (nonatomic, copy) NSString *value;

@property (nonatomic, copy) NSString *status;

@end

@interface QNRoomInfo : NSObject

@property (nonatomic, copy) NSString *image;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *creator;

@property (nonatomic, copy) NSString *desc;

@property (nonatomic, copy) NSString *status;

@property (nonatomic, copy) NSString *type;

@property (nonatomic, copy) NSString *totalUsers;

@property (nonatomic, copy) NSString *roomId;

@property (nonatomic, copy) NSArray <QNAttrsModel *> *params;

@end

@interface QNUserInfo : NSObject

@property (nonatomic, copy) NSString *role;

@property (nonatomic, copy) NSString *userId;

@property (nonatomic, copy) NSString *avatar;

@property (nonatomic, copy) NSString *nickname;

@property (nonatomic, copy) NSString *phone;

@property (nonatomic, copy) NSString *profile;

@end

@interface QNRTCInfo : NSObject

@property (nonatomic, copy) NSString *roomToken;

@property (nonatomic, copy) NSString *publishUrl;

@property (nonatomic, copy) NSString *rtmpPlayUrl;

@property (nonatomic, copy) NSString *flvPlayUrl;

@property (nonatomic, copy) NSString *hlsPlayUrl;

@end

@interface QNIMConfigModel : NSObject

@property (nonatomic, copy) NSString *imGroupId;

@property (nonatomic, copy) NSString *type;

@end

@interface QNRTCMicsInfo : NSObject

@property (nonatomic, strong) NSArray <QNAttrsModel *> *attrs;

@property (nonatomic, copy) NSString *userExtension;

@property (nonatomic, copy) NSString *uid;

@property (nonatomic, strong) NSArray <QNAttrsModel *> *params;

@end

@interface QNRoomDetailModel : NSObject

@property (nonatomic, strong) QNRoomInfo *roomInfo;

@property (nonatomic, strong) QNUserInfo *userInfo;

@property (nonatomic, strong) NSMutableArray <QNUserInfo *> *allUserList;

@property (nonatomic, strong) QNIMConfigModel *imConfig;

@property (nonatomic, strong) QNRTCInfo *rtcInfo;

@property (nonatomic, strong) NSArray <QNRTCMicsInfo *> *mics;

@end

NS_ASSUME_NONNULL_END
