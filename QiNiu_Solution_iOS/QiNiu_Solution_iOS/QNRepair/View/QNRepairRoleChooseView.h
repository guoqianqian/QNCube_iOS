//
//  QNRepairRoleChooseView.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/10/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

//选择创建检修房间的身份
@interface QNRepairRoleChooseView : UIView

@property (nonatomic, copy) void (^roleChooseBlock)(NSString *role);

@end

NS_ASSUME_NONNULL_END
