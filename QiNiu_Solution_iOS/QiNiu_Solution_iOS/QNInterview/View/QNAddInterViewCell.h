//
//  QNAddInterViewCell.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/4/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QNAddInterViewInfoModel;

@interface QNAddInterViewCell : UITableViewCell

@property (nonatomic, copy) void (^textEndEditBlock)(QNAddInterViewInfoModel *model);

@property (nonatomic, copy) void (^interviewNameBlock)(NSString *interviewName);

- (void)updateWithModel:(QNAddInterViewInfoModel *)model;

@end

NS_ASSUME_NONNULL_END
