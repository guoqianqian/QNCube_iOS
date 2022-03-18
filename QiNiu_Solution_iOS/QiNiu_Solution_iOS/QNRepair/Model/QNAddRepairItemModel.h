//
//  QNAddRepairItemModel.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/9/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//新建检修房间model

@interface QNAddRepairItemModel : NSObject
//房间名称
@property (nonatomic, copy) NSString *title;
//进房权限 ，只能是{"staff", "professor",@"student"}
@property (nonatomic, copy) NSString *role;

@end

NS_ASSUME_NONNULL_END
