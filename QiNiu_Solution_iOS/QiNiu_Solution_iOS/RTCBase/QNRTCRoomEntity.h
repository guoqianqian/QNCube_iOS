//
//  QNRTCRoomEntity.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/9/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum{
    QNClientRoleTypeMaster = 0,//主播
    QNClientRoleTypeAudience = 1,//观众
    QNClientRoleTypePuller = -1,//拉流
}QNClientRoleType;

@interface QNUserExtProfile : NSObject

@property (nonatomic, copy)NSString *avatar;

@property (nonatomic, copy)NSString *name;

@end

@interface QNUserExtension : NSObject
@property (nonatomic, copy)NSString *userExtRoleType; //用户扩展类型，如果麦位角色不一样需求区分麦位上的角色
@property (nonatomic, strong) QNUserExtProfile *userExtProfile;  //用户扩展资料，如果有人上麦回调希望把上麦者资料通过rtc上麦回调显示UI
@property (nonatomic, copy)NSString *userExtensionMsg;//加入房间附加的扩展字段
@property (nonatomic, assign)QNClientRoleType clientRoleType;// 0主播 1观众 -1拉流
@property (nonatomic, copy)NSString *uid;
@end

//rtc房间抽象
@interface QNRTCRoomEntity : NSObject
//是否加入成功
@property (nonatomic, assign) BOOL isJoined;
//房间ID
@property (nonatomic, copy)NSString *provideRoomId;
//房主ID
@property (nonatomic, copy)NSString *provideHostUid;
//群ID
@property (nonatomic, copy)NSString *provideImGroupId;
//推流地址
@property (nonatomic, copy)NSString *providePushUrl;
//拉流地址
@property (nonatomic, copy)NSString *providePullUri;
//房间token
@property (nonatomic, copy)NSString *provideRoomToken;
//我的用户ID
@property (nonatomic, copy)NSString *provideMeId;

@property (nonatomic, strong)QNUserExtension *provideUserExtension;

@end

NS_ASSUME_NONNULL_END
