//
//  QNJoinInterViewModel.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/4/23.
//

#import "QNJoinInterviewModel.h"

@implementation QNJoinInterviewModel

+ (NSDictionary *)objectClassInArray{
    return @{@"userInfo" : [QNJoinInterViewUserInfoModel class],
             @"onlineUserList" : [QNJoinInterViewUserInfoModel class],
             @"allUserList" : [QNJoinInterViewUserInfoModel class],
    };
}

@end

@implementation QNJoinInterViewUserInfoModel

@end

@implementation QNInterviewEndOption

@end

@implementation QNIMConfig

@end
