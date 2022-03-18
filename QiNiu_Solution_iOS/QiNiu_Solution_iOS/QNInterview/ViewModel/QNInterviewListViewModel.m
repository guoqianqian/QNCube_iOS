//
//  QNInterviewListViewModel.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/4/22.
//

#import "QNInterviewListViewModel.h"
#import "QNNetworkUtil.h"
#import "QNInterViewListModel.h"
#import <MJExtension/MJExtension.h>

@implementation QNInterviewListViewModel

+ (void)requestInterviewListWithPageNum:(NSInteger)pageNum success:(void (^)(QNInterViewListModel * _Nonnull))success {
    
    NSMutableDictionary *params = [ NSMutableDictionary dictionary];
    params[@"pageNum"] = @(pageNum);
    params[@"pageSize"] = @(10);
    [QNNetworkUtil getRequestWithAction:@"interview" params:params success:^(NSDictionary *responseData) {
        
        QNInterViewListModel *listModel = [QNInterViewListModel mj_objectWithKeyValues:responseData];
        listModel.list = [QNInterviewItemModel mj_objectArrayWithKeyValuesArray:responseData[@"list"]];
        
        for (QNInterviewItemModel *item in listModel.list) {
            item.options = [QNInterviewOptionsModel mj_objectArrayWithKeyValuesArray:item.options.mj_keyValues];
        }
        
        success(listModel ?: nil);
        
    } failure:^(NSError *error) {
            
    }];
}

+ (void)requestCancelInterviewWithInterviewId:(NSString *)interviewId cancelBlock:(void (^)(void))cancelBlock {
    NSString *action = [NSString stringWithFormat:@"cancelInterview/%@",interviewId];
    
    [QNNetworkUtil postRequestWithAction:action params:nil success:^(NSDictionary *responseData) {
        
        cancelBlock();
        
    } failure:^(NSError *error) {
            
    }];
}

+ (void)requestEndInterviewWithInterviewId:(NSString *)interviewId endBlock:(void (^)(void))endBlock {
    NSString *action = [NSString stringWithFormat:@"endInterview/%@",interviewId];
    
    [QNNetworkUtil postRequestWithAction:action params:nil success:^(NSDictionary *responseData) {
        
        endBlock();
        
    } failure:^(NSError *error) {
            
    }];
}

@end
