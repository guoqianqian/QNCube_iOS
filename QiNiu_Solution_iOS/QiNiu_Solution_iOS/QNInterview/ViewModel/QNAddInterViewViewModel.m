//
//  QNAddInterViewViewModel.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/4/9.
//

#import "QNAddInterViewViewModel.h"
#import "QNAddInterViewInfoModel.h"
#import "QNAddInterviewRequestModel.h"
#import "NSDate+Operation.h"
#import "QNNetworkUtil.h"
#import <MJExtension/MJExtension.h>
#import "QNInterViewListModel.h"
#import <YYCategories/YYCategories.h>
#import "MBProgressHUD+QNShow.h"

@implementation QNAddInterViewViewModel

- (QNAddInterviewRequestModel *)requestModel {
    
    QNAddInterviewRequestModel *requestModel = [QNAddInterviewRequestModel new];
    requestModel.title = self.interviewModelArray[0].content;
    requestModel.startTime = [self timeStampWithTimeStr:self.interviewModelArray[1].content].integerValue;
    requestModel.endTime = [self timeStampWithTimeStr:self.interviewModelArray[2].content].integerValue;
    requestModel.goverment = self.interviewModelArray[3].content;
    requestModel.career = self.interviewModelArray[4].content;
    requestModel.candidateName = self.interviewModelArray[5].content;
    requestModel.candidatePhone = self.interviewModelArray[6].content;
    requestModel.isAuth = self.interviewModelArray[7].content;
    requestModel.authCode = self.interviewModelArray[8].content;
    requestModel.isRecorded = self.interviewModelArray[9].content;

    return requestModel;
}

//时间字符串转时间戳
- (NSString *)timeStampWithTimeStr:(NSString *)timeStr {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
       [dateFormatter setDateFormat:@"yyyy年MM月dd日HH:mm"];
       NSDate *tempDate = [dateFormatter dateFromString:timeStr];
       NSString *timeStamp = [NSString stringWithFormat:@"%ld", (long)[tempDate timeIntervalSince1970]];
    return timeStamp;
}

- (BOOL)warn {
    
    if (self.requestModel.title.length == 0) {
        [MBProgressHUD showText:@"请填写标题"];
        return YES;
    }
    if (self.requestModel.candidateName.length == 0) {
        [MBProgressHUD showText:@"请填写应聘者姓名"];
        return YES;
    }
    if (self.requestModel.candidatePhone.length == 0) {
        [MBProgressHUD showText:@"请填写应聘者手机号"];
        return YES;
    }
    if (self.requestModel.goverment.length == 0) {
        [MBProgressHUD showText:@"请填写公司/部门"];
        return YES;
    }
    if (self.requestModel.career.length == 0) {
        [MBProgressHUD showText:@"请填写职位名称"];
        return YES;
    }
    if (self.requestModel.startTime == 0 || self.requestModel.endTime == 0) {
        [MBProgressHUD showText:@"请选择面试时间"];
        return YES;
    }
    NSDate *startDate = [NSDate dateWithString:self.interviewModelArray[1].content format:@"yyyy年MM月dd日HH:mm"];
    NSDate *endDate = [NSDate dateWithString:self.interviewModelArray[2].content format:@"yyyy年MM月dd日HH:mm"];
    if ([[endDate earlierDate:startDate] isEqualToDate:endDate]) {
        [MBProgressHUD showText:@"结束时间不能早于开始时间"];
        return YES;
    }
    return NO;
}


- (void)requestCreateInterviewSuccess:(void (^) (void))success {
    
    if ([self warn]) {
        return;;
    }
    
    NSDictionary *params = self.requestModel.mj_keyValues;

    [QNNetworkUtil postRequestWithAction:@"interview" params:params success:^(NSDictionary *responseData) {
        [self saveGovermentInfo];
        success();
    } failure:^(NSError *error) {
            
    }];
}

- (void)requestEditInterviewWithInterviewId:(NSString *)interviewId Success:(void (^) (void))success {
    
    if ([self warn]) {
        return;;
    }
    
    NSMutableDictionary *params = self.requestModel.mj_keyValues;
    
    NSString *action = [NSString stringWithFormat:@"interview/%@",interviewId];

    [QNNetworkUtil postRequestWithAction:action params:params success:^(NSDictionary *responseData) {
        [self saveGovermentInfo];
        success();
    } failure:^(NSError *error) {
            
    }];
}

- (void)saveGovermentInfo {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.requestModel.goverment forKey:QN_GOVERMENT_KEY];
    [defaults setObject:self.requestModel.career forKey:QN_CAREER_KEY];
    [defaults synchronize];
}

- (NSString *)getGoverment {
    NSString *str = [[NSUserDefaults standardUserDefaults] objectForKey:QN_GOVERMENT_KEY];
    if (str.length > 0) {
        return str;
    }
    return @"";
}

- (NSString *)getCareer {
    NSString *str = [[NSUserDefaults standardUserDefaults] objectForKey:QN_CAREER_KEY];
    if (str.length > 0) {
        return str;
    }
    return @"";
}

- (NSMutableArray<QNAddInterViewInfoModel *> *)interviewModelArray {
    
    if (!_interviewModelArray) {
        _interviewModelArray  = [NSMutableArray array];
        NSArray *titleStrArray = @[@"面试标题",
                                   @"开始时间",
                                   @"结束时间",
                                   @"公司/部门",
                                   @"职位名称",
                                   @"姓名",
                                   @"手机号",
                                   @"入会密码",
                                   @"密码",
                                   @"是否开启面试录制"];
        
        NSArray *contentArray = @[self.infoModel.title.length > 0 ? self.infoModel.title : @"",
                                  [self getStartTime],
                                  [self getEndTime],
                                  self.infoModel.goverment.length > 0 ? self.infoModel.goverment : [self getGoverment],
                                  self.infoModel.career.length > 0 ? self.infoModel.career : [self getCareer],
                                  self.infoModel.candidateName.length > 0 ? self.infoModel.candidateName : @"",
                                  self.infoModel.candidatePhone.length > 0 ? self.infoModel.candidatePhone : @"",
                                  @(self.infoModel.isAuth).stringValue,
                                  self.infoModel.authCode.length > 0 ? self.infoModel.authCode : [self getRandomNumber],
                                  @(self.infoModel.isRecorded).stringValue];
        
        NSArray *placeholderArray = @[@"请输入面试标题",
                                      @"请选择面试开始时间",
                                      @"请选择面试结束时间",
                                      @"请输入公司/部门",
                                      @"请输入职位名称",
                                      @"请输入应聘者姓名",
                                      @"请输入应聘者手机号",
                                      @"",
                                      @"请输入四位数入会密码",
                                      @""];
        
        [titleStrArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            QNAddInterViewInfoModel *model = [QNAddInterViewInfoModel new];
            model.title = obj;
            model.placeholder = placeholderArray[idx];
            model.content = contentArray[idx];
            [_interviewModelArray addObject:model];
        }];
    }
    
    return _interviewModelArray;
}

//自动获取当前时间  当前时间11点的0~29分，则开始时间自动填写为11点30
- (NSString *)getStartTime {
    
    NSString *startTimeStr ;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYYY年MM月dd日HH:mm"];
    
    if (self.infoModel.startTime.length > 0) {
        NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:self.infoModel.startTime.integerValue];
        startTimeStr = [formatter stringFromDate:startDate];
        return startTimeStr ;
    }
    
    NSDate *currentDate = [NSDate date];
    NSString *currentTimeString = [formatter stringFromDate:currentDate];
    NSLog(@"currentTimeString =  %@",currentTimeString);
    
    NSString *dateStr = [currentTimeString substringToIndex:11];
    NSString *hourStr = [currentTimeString substringWithRange:NSMakeRange(11,2)];
    NSString *minStr = [currentTimeString substringFromIndex:currentTimeString.length - 2];
    if (minStr.integerValue < 30) {
        minStr = @"30";
    } else {
        hourStr = @(hourStr.integerValue + 1).stringValue;
        minStr = @"00";
    }
    
    startTimeStr  = [NSString stringWithFormat:@"%@%@:%@",dateStr,hourStr,minStr];
    return startTimeStr;
}

//自动获取结束时间
- (NSString *)getEndTime {
    
    NSString *endTimeStr;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYYY年MM月dd日HH:mm"];
    
    if (self.infoModel.endTime.length > 0) {
        
        NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:self.infoModel.endTime.integerValue];
        endTimeStr = [formatter stringFromDate:endDate];
        return endTimeStr ;
    }
    
    NSMutableString *startTimeStr = [[NSMutableString alloc]initWithString:[self getStartTime]];
//    NSInteger startMonth = [startTimeStr substringWithRange:NSMakeRange(17, 2)].integerValue;
//    NSInteger startDay = [startTimeStr substringWithRange:NSMakeRange(14, 2)].integerValue;
    NSInteger startHour = [startTimeStr substringWithRange:NSMakeRange(11, 2)].integerValue;
    NSString *endHourStr = @(startHour + 1).stringValue;
    if (startHour == 23) {
        endHourStr = @"00";
    }
    
    endTimeStr = [startTimeStr stringByReplacingCharactersInRange:NSMakeRange(11, 2) withString:endHourStr];
        
    return endTimeStr;
}

//获取四位数的随机数
- (NSString *)getRandomNumber {
    int num = (arc4random() % 10000);
    NSString *randomNumber = [NSString stringWithFormat:@"%.4d", num];
    return randomNumber;
}

@end
