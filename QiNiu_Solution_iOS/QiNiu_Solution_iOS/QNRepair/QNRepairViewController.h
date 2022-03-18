//
//  QNRepairViewController.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/9/26.
//

#import "QNRTCRoom.h"
#import "QNRepairListModel.h"

NS_ASSUME_NONNULL_BEGIN

//检修房间

@interface QNRepairViewController : QNRTCRoom

@property (nonatomic, strong) QNRepairItemModel *model;

@property (nonatomic, copy) void (^popBlock)(void);

@end

NS_ASSUME_NONNULL_END
