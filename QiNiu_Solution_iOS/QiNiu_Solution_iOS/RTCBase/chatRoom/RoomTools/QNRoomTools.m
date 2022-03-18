//
//  QNRoomTools.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2022/3/16.
//

#import "QNRoomTools.h"

@interface QNRoomTools ()

@property(nonatomic, copy)NSString *type;

@property(nonatomic, copy)NSString *roomId;

@end

@implementation QNRoomTools

-(instancetype)initWithType:(NSString *)type roomId:(NSString *)roomId {
    if (self = [super init]) {
        self.type = type;
        self.roomId = roomId;
    }
    return self;
}

//加入房间
- (void)requestJoinRoomWithParams:(id)params success:(void (^)(QNRoomDetailModel *roomDetailodel))success failure:(void (^)(NSError *error))failure {
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    dic[@"type"] = self.type;
    if (self.roomId.length > 0) {
        dic[@"roomId"] = self.roomId;
    }    
    dic[@"params"] = params;
    
    [QNNetworkUtil postRequestWithAction:@"base/joinRoom" params:dic success:^(NSDictionary *responseData) {
            
        QNRoomDetailModel *model = [QNRoomDetailModel mj_objectWithKeyValues:responseData];
        
        model.roomInfo.params = [QNAttrsModel mj_objectArrayWithKeyValuesArray:responseData[@"roomInfo"][@"params"]];
        model.allUserList = [QNUserInfo mj_objectArrayWithKeyValuesArray:responseData[@"allUserList"]];
        self.model = model;
        
        [[NSUserDefaults standardUserDefaults] setObject:model.userInfo.avatar forKey:QN_USER_AVATAR_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        success(model);
    } failure:^(NSError *error) {
        [MBProgressHUD showText:@"加入房间失败!"];
        failure(error);
    }];
}

//获取房间信息
- (void)requestRoomInfoSuccess:(void (^)(QNRoomDetailModel *roomDetailodel))success failure:(void (^)(NSError *error))failure {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"roomId"] = self.roomId;
    params[@"type"] = self.type;
    
    [QNNetworkUtil getRequestWithAction:@"base/getRoomInfo" params:params success:^(NSDictionary *responseData) {
            
        self.model = [QNRoomDetailModel mj_objectWithKeyValues:responseData];
        self.model.roomInfo.params = [QNAttrsModel mj_objectArrayWithKeyValuesArray:responseData[@"roomInfo"][@"params"]];
        self.model.allUserList = [QNUserInfo mj_objectArrayWithKeyValuesArray:responseData[@"allUserList"]];

        success(self.model);
        
        } failure:^(NSError *error) {
            [MBProgressHUD showText:@"获取房间信息失败!"];
            failure(error);
        }];
}

//获取房间麦位信息
- (void)requestRoomMicInfoSuccess:(void (^)(QNRoomDetailModel *roomDetailodel))success failure:(void (^)(NSError *error))failure {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"roomId"] = self.roomId;
    params[@"type"] = self.type;
    
    [QNNetworkUtil getRequestWithAction:@"base/getRoomMicInfo" params:params success:^(NSDictionary *responseData) {
            
        QNRoomDetailModel *model = [QNRoomDetailModel mj_objectWithKeyValues:responseData];
        model.mics = [QNRTCMicsInfo mj_objectArrayWithKeyValuesArray:responseData[@"mics"]];
        
        success(model);
        
        } failure:^(NSError *error) {
            
            failure(error);
        }];
}

//请求上麦接口
- (void)requestUpMicSeatWithUserExtRoleType:(NSString *)userExtRoleType  clientRoleType:(QNClientRoleType)clientRoleType success:(void (^)(void))success failure:(void (^)(NSError *error))failure {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"roomId"] = self.roomId;
    params[@"type"] = self.type;
    
    QNUserExtension *userExtension = [QNUserExtension new];
    userExtension.userExtRoleType = self.model.userInfo.role;
    userExtension.clientRoleType = clientRoleType;
    userExtension.uid = QN_User_id;
    
    QNUserExtProfile *profile = [QNUserExtProfile new];
    profile.avatar = QN_User_avatar;
    profile.name = QN_User_nickname;
    
    userExtension.userExtProfile = profile;
    
    params[@"userExtension"] = userExtension.mj_JSONString;
    
    [QNNetworkUtil postRequestWithAction:@"base/upMic" params:params success:^(NSDictionary *responseData) {

        success();
        
        } failure:^(NSError *error) {
            failure(error);
        }];
}

//请求下麦接口
- (void)requestDownMicSeat {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"roomId"] = self.roomId;
    params[@"type"] = self.type;
    [QNNetworkUtil postRequestWithAction:@"base/downMic" params:params success:^(NSDictionary *responseData) {
        } failure:^(NSError *error) {
        }];
}

//房间心跳
- (void)requestRoomHeartBeatWithInterval:(NSString *)interval {
    
    __weak typeof(self) weakSelf = self;
        
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"roomId"] = self.roomId;
    params[@"type"] = self.type;
    
    [QNNetworkUtil getRequestWithAction:@"base/heartBeat" params:params success:^(NSDictionary *responseData) {
        
        NSNumber *inter = responseData[@"interval"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(inter.integerValue * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
            [weakSelf requestRoomHeartBeatWithInterval:responseData[@"interval"]];
        });
        
    } failure:^(NSError *error) {
        [self requestRoomHeartBeatWithInterval:@"1"];
    }];
    
}

//请求离开房间接口
- (void)requestLeaveRoom {
        
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"roomId"] = self.roomId;
    params[@"type"] = self.type;
    
    [QNNetworkUtil postRequestWithAction:@"base/leaveRoom" params:params success:^(NSDictionary *responseData) {
        
        
    } failure:^(NSError *error) {
        
    }];
        
}

@end
