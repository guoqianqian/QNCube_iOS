//
//  QNInterViewListModel.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/4/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QNInterviewItemModel;

@interface QNInterViewListModel : NSObject

@property (nonatomic, strong) NSArray<QNInterviewItemModel *> *list;
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

@interface QNInterviewOptionsModel : NSObject
//类型
@property (nonatomic, assign) NSInteger type;
//操作名称
@property (nonatomic, copy) NSString *title;
//请求URL
@property (nonatomic, copy) NSString *requestUrl;

@property (nonatomic, copy) NSString *method;
@end

@interface QNInterviewShareInfoModel : NSObject

@property (nonatomic, copy) NSString *content;

@property (nonatomic, copy) NSString *icon;

@property (nonatomic, copy) NSString *url;
@end

@interface QNInterviewItemModel : NSObject

@property (nonatomic, copy) NSString *ID;
//面试部门
@property (nonatomic, copy) NSString *goverment;
//面试职位
@property (nonatomic, copy) NSString *career;
//角色码
@property (nonatomic, assign) CGFloat roleCode;
//操作列表
@property (nonatomic, strong) NSArray<QNInterviewOptionsModel *> *options;
//分享信息
@property (nonatomic, strong) QNInterviewShareInfoModel *shareInfo;
//面试标题
@property (nonatomic, copy) NSString *title;
//面试结束时间
@property (nonatomic, copy) NSString *endTime;
//面试状态码
@property (nonatomic, assign) CGFloat statusCode;
//角色名
@property (nonatomic, copy) NSString *role;
//面试开始时间
@property (nonatomic, copy) NSString *startTime;
//面试状态描述
@property (nonatomic, copy) NSString *status;
//是否开启进入验证
@property (nonatomic, assign) BOOL enableJoinAuth;
//应聘者姓名
@property (nonatomic, copy) NSString *candidateName;
//应聘者手机号
@property (nonatomic, copy) NSString *candidatePhone;
//面试官姓名
@property (nonatomic, copy) NSString *interviewerName;
//面试官手机号
@property (nonatomic, copy) NSString *interviewerPhone;
//是否开启入会密码
@property (nonatomic, assign) BOOL isAuth;
//入会密码
@property (nonatomic, copy) NSString *authCode;
//是否进行录制
@property (nonatomic, assign) BOOL isRecorded;
//面试状态字体颜色
@property (nonatomic, copy) UIColor *textColor;
//是否需要显示操作条
@property (nonatomic, assign) BOOL showOptionView;

@end

NS_ASSUME_NONNULL_END
