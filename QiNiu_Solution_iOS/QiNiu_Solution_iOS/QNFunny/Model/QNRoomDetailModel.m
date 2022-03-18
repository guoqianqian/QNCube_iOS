//
//  QNRoomDetailModel.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/11/8.
//

#import "QNRoomDetailModel.h"

@implementation QNRoomDetailModel

+ (NSDictionary *)objectClassInArray{
    return @{@"allUserList" : [QNUserInfo class],
             @"mics" : [QNRTCMicsInfo class]
    };
}

@end

@implementation QNRoomInfo

+ (NSDictionary *)objectClassInArray{
    return @{@"params" : [QNAttrsModel class]};
}

@end

@implementation QNAttrsModel

@end

@implementation QNUserInfo

@end

@implementation QNRTCInfo

@end

@implementation QNIMConfigModel

@end

@implementation QNRTCMicsInfo

+ (NSDictionary *)objectClassInArray{
    return @{@"params" : [QNAttrsModel class],
             @"attrs" : [QNAttrsModel class]
    };
}

@end
