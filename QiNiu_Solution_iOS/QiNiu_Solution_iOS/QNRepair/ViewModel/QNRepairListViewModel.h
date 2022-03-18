//
//  QNRepairListViewModel.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/9/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class QNRepairListModel;
@interface QNRepairListViewModel : NSObject
//请求检修房间列表
+ (void)requestRepairListWithPageNum:(NSInteger)pageNum success:(void (^)(QNRepairListModel *listModel))success;
@end

NS_ASSUME_NONNULL_END
