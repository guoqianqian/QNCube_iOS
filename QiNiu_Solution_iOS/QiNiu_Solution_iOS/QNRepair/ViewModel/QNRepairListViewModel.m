//
//  QNRepairListViewModel.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/9/27.
//

#import "QNRepairListViewModel.h"
#import "QNRepairListModel.h"
#import "QNNetworkUtil.h"
#import <MJExtension/MJExtension.h>
#import "QNAddRepairItemModel.h"

@implementation QNRepairListViewModel

+ (void)requestRepairListWithPageNum:(NSInteger)pageNum success:(void (^)(QNRepairListModel * _Nonnull))success {
    
    NSMutableDictionary *params = [ NSMutableDictionary dictionary];
    params[@"pageNum"] = @(pageNum);
    params[@"pageSize"] = @(10);
    [QNNetworkUtil getRequestWithAction:@"repair/listRoom" params:params success:^(NSDictionary *responseData) {
        
        QNRepairListModel *listModel = [QNRepairListModel mj_objectWithKeyValues:responseData];
        listModel.list = [QNRepairItemModel mj_objectArrayWithKeyValuesArray:responseData[@"list"]];
        
        for (QNRepairItemModel *item in listModel.list) {
            item.options = [QNAddRepairItemModel mj_objectArrayWithKeyValuesArray:item.options.mj_keyValues];
        }
        
        success(listModel ?: nil);
        
    } failure:^(NSError *error) {
            
    }];
    
}

@end
