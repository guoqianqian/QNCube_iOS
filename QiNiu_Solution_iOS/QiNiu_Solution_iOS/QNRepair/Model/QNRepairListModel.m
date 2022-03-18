//
//  QNRepairListModel.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/9/27.
//

#import "QNRepairListModel.h"
#import "QNAddRepairItemModel.h"

@implementation QNRepairListModel

+ (NSDictionary *)objectClassInArray{
    return @{@"list" : [QNRepairItemModel class]};
}

@end

@implementation QNRepairItemModel

+ (NSDictionary *)objectClassInArray{
    return @{@"options" : [QNAddRepairItemModel class]};
}

@end

