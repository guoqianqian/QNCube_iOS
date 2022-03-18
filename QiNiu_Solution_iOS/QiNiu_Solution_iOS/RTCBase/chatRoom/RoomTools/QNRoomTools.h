//
//  QNRoomTools.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2022/3/16.
//

#import <Foundation/Foundation.h>
#import "QNRoomDetailModel.h"
#import "QNRTCRoomEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface QNRoomTools : NSObject

@property(nonatomic, strong)QNRoomDetailModel *model;

- (instancetype)initWithType:(NSString *)type roomId:(NSString *)roomId;

//请求加入房间
- (void)requestJoinRoomWithParams:(id)params success:(void (^)(QNRoomDetailModel *roomDetailodel))success failure:(void (^)(NSError *error))failure;

//获取房间信息
- (void)requestRoomInfoSuccess:(void (^)(QNRoomDetailModel *roomDetailodel))success failure:(void (^)(NSError *error))failure;

//获取房间麦位信息
- (void)requestRoomMicInfoSuccess:(void (^)(QNRoomDetailModel *roomDetailodel))success failure:(void (^)(NSError *error))failure;

//请求上麦接口
- (void)requestUpMicSeatWithUserExtRoleType:(NSString *)userExtRoleType  clientRoleType:(QNClientRoleType)clientRoleType success:(void (^)(void))success failure:(void (^)(NSError *error))failure;

- (void)requestDownMicSeat;

//房间心跳
- (void)requestRoomHeartBeatWithInterval:(NSString *)interval;

//请求离开房间接口
- (void)requestLeaveRoom;

@end

NS_ASSUME_NONNULL_END
