//
//  QNAddInterViewViewModel.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/4/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class QNAddInterViewInfoModel,QNAddInterviewRequestModel,QNInterviewItemModel,QNInterViewListModel;

@interface QNAddInterViewViewModel : NSObject

@property (nonatomic, strong) QNAddInterviewRequestModel *requestModel;
//请求 创建面试
- (void)requestCreateInterviewSuccess:(void (^) (void))success;
// 请求 修改面试信息
- (void)requestEditInterviewWithInterviewId:(NSString *)interviewId Success:(void (^) (void))success;
//列表信息
@property (nonatomic, strong) NSMutableArray <QNAddInterViewInfoModel *> *interviewModelArray;

@property (nonatomic, strong) QNInterviewItemModel *infoModel;
@end

NS_ASSUME_NONNULL_END
