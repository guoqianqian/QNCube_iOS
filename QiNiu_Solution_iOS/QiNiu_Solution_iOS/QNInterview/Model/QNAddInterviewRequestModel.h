//
//  QNAddInterviewRequestModel.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/4/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QNAddInterviewRequestModel : NSObject
//面试标题
@property (nonatomic, copy) NSString *title;
//开始时间
@property (nonatomic, assign) NSInteger startTime;
//结束时间
@property (nonatomic, assign) NSInteger endTime;
//公司部门
@property (nonatomic, copy) NSString *goverment;
//职位
@property (nonatomic, copy) NSString *career;
//是否开启入会密码
@property (nonatomic, assign) BOOL isAuth;
//入会密码
@property (nonatomic, copy) NSString *authCode;
//是否进行录制
@property (nonatomic, assign) BOOL isRecorded;
//应聘者姓名
@property (nonatomic, copy) NSString *candidateName;
//应聘者手机号
@property (nonatomic, copy) NSString *candidatePhone;
//面试官姓名
@property (nonatomic, copy) NSString *interviewerName;
//面试官手机号
@property (nonatomic, copy) NSString *interviewerPhone;
@end

NS_ASSUME_NONNULL_END
