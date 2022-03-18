//
//  QNRepairListModel.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/9/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QNAddRepairItemModel;

typedef enum{
    QNRepairRoleTypeProfessor,//专家入口
    QNRepairRoleTypeStaff,//检修员入口
    QNRepairRoleTypeStudents,//学生入口
}QNRepairRoleType;

@interface QNRepairItemModel : NSObject

@property (nonatomic, copy) NSString *roomId;
//标题
@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *image;

@property (nonatomic, assign) NSInteger status;

@property (nonatomic, copy) NSString *requestId;
//操作列表
@property (nonatomic, strong) NSArray<QNAddRepairItemModel *> *options;

@property (nonatomic, assign) QNRepairRoleType roleType;

@end

@interface QNRepairListModel : NSObject

@property (nonatomic, strong) NSArray<QNRepairItemModel *> *list;
//当前数量
@property (nonatomic, assign) CGFloat cnt;
//全部数量
@property (nonatomic, assign) CGFloat total;
//下一个ID
@property (nonatomic, copy) NSString *nextId;
//是否最后一页
@property (nonatomic, assign) BOOL endPage;
//当前页码
@property (nonatomic, assign) NSInteger currentPageNum;
//下页页码，如果无下页则和当前页页码一致
@property (nonatomic, assign) NSInteger nextPageNum;
//当前页预计条数
@property (nonatomic, assign) NSInteger pageSize;

@end



NS_ASSUME_NONNULL_END
