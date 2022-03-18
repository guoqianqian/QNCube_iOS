//
//  QNAddInterViewViewController.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/4/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QNInterviewItemModel,QNInterViewListModel;

@interface QNAddInterViewViewController : UIViewController

@property (nonatomic, strong) QNInterviewItemModel *model;

@property (nonatomic, copy) void (^popBlock)(void);

@end

NS_ASSUME_NONNULL_END
