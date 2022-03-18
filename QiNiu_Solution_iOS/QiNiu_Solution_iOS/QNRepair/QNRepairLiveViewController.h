//
//  QNRepairLiveViewController.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/10/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QNRepairItemModel,QNRepairListModel;
//学生观看的直播画面
@interface QNRepairLiveViewController : UIViewController

@property (nonatomic, strong) QNRepairItemModel *model;

@end

NS_ASSUME_NONNULL_END
