//
//  QNInterviewListViewModel.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/4/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class QNInterViewListModel;

@interface QNInterviewListViewModel : NSObject
//请求面试列表
+ (void)requestInterviewListWithPageNum:(NSInteger)pageNum success:(void (^)(QNInterViewListModel *listModel))success;
// 取消面试
+ (void)requestCancelInterviewWithInterviewId:(NSString *)interviewId cancelBlock:(void (^)(void))cancelBlock;
// 结束面试
+ (void)requestEndInterviewWithInterviewId:(NSString *)interviewId endBlock:(void (^)(void))endBlock;

@end

NS_ASSUME_NONNULL_END
