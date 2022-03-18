//
//  QNInterviewDetailModel.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/4/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QNInterviewDetailModel : NSObject

@property (nonatomic, copy) NSString *authCode;

@property (nonatomic, copy) NSString *ID;

@property (nonatomic, copy) NSString *career;

@property (nonatomic, copy) NSString *government;

@property (nonatomic, copy) NSString *interviewerName;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *candidateName;

@property (nonatomic, copy) NSString *candidatePhone;

@property (nonatomic, copy) NSString *interviewerPhone;

@property (nonatomic, assign) CGFloat statusCode;

@property (nonatomic, copy) NSString *endTime;

@property (nonatomic, copy) NSString *startTime;

@property (nonatomic, copy) NSString *status;

@property (nonatomic, assign) BOOL enableJoinAuth;

@end


NS_ASSUME_NONNULL_END
