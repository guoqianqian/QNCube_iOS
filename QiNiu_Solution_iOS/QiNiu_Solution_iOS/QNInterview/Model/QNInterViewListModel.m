//
//  QNInterViewListModel.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/4/14.
//

#import "QNInterViewListModel.h"
#import <YYCategories/YYCategories.h>

@implementation QNInterViewListModel

+ (NSDictionary *)objectClassInArray{
    return @{@"list" : [QNInterviewItemModel class]};
}

@end

@implementation QNInterviewItemModel

+ (NSDictionary *)objectClassInArray{
    return @{@"options" : [QNInterviewOptionsModel class]};
}

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"ID" : @"id"};
}

- (UIColor *)textColor {
    if (self.statusCode == 10) {//面试中
        return [UIColor colorWithHexString:@"176AFF"];
    } else if (self.statusCode == 0) {//待面试
        return [UIColor colorWithHexString:@"FABD48"];
    }
    return [UIColor colorWithHexString:@"999999"];
}

- (BOOL)showOptionView {
    if (self.options.count == 0) {
        return NO;
    }
    return YES;
}

@end

@implementation QNInterviewOptionsModel

@end

@implementation QNInterviewShareInfoModel

@end
