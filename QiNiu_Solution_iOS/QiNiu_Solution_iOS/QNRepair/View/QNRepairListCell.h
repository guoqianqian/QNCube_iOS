//
//  QNRepairListCell.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/9/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QNRepairItemModel;

@interface QNRepairListCell : UITableViewCell

@property (nonatomic, strong) QNRepairItemModel *itemModel;

@property (nonatomic, copy) void (^optionButtonBlock)(NSString *buttonTitle);

@end

NS_ASSUME_NONNULL_END
