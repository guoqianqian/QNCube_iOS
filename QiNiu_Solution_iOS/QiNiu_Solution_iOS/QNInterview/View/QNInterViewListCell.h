//
//  QNInterViewListCell.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/4/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, QNInterviewListOptionType) {
    QNInterviewListOptionTypeChange = 1,//修改面试
    QNInterviewListOptionTypeEnter = 100,//进入面试
    QNInterviewListOptionTypeCancel = 50,//取消面试
    QNInterviewListOptionTypeEnd = 51,//结束面试
    QNInterviewListOptionTypeShare = 200,//分享面试
};

@class QNInterviewItemModel,QNInterViewListModel;

@interface QNInterViewListCell : UITableViewCell

@property (nonatomic, strong) QNInterviewItemModel *itemModel;

@property (nonatomic, copy) void (^optionButtonBlock)(NSInteger optionType);

@end

NS_ASSUME_NONNULL_END
