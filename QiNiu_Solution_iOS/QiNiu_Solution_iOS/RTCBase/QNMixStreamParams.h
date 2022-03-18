//
//  QNMixStreamParams.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/9/23.
//

#import <Foundation/Foundation.h>

@class QNBackgroundInfo;
NS_ASSUME_NONNULL_BEGIN

@interface QNMixStreamParams : NSObject

@property (nonatomic, assign) BOOL isNeed;

@property (nonatomic, assign) NSInteger mixStreamWidth;

@property (nonatomic, assign) NSInteger mixStringHeiht;

@property (nonatomic, assign) NSInteger mixStreamY;
//码率
@property (nonatomic, assign) NSInteger mixBitrate;
//帧率
@property (nonatomic, assign) NSInteger fps;
//背景参数
@property (nonatomic, strong) QNBackgroundInfo *backgroundInfo;

@end

NS_ASSUME_NONNULL_END
