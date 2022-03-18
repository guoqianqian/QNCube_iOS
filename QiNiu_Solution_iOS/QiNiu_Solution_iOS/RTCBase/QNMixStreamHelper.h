//
//  QNMixStreamHelper.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/9/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class QNMixStreamParams,QNMergeTrackOption;
//混流器
@interface QNMixStreamHelper : NSObject

//启动前台转推，默认实现推本地轨道
- (void)startForwardJob;
//停止前台推流
- (void)stopForwardJob;
//开始混流转推
- (void)startMixStreamJob;
//停止混流转推
- (void)stopMixStreamJob;
//设置混流参数
- (void)setMixParams:(QNMixStreamParams *)params;
//主动更新某个座位的混流参数
- (void)updateUserVideoMergeOptions:(NSString *)uid option:(QNMergeTrackOption *)option;
- (void)updateUserAudioMergeOptions:(NSString *)uid option:(QNMergeTrackOption *)option;
- (void)updateUserScreenMergeOptions:(NSString *)uid option:(QNMergeTrackOption *)option;
- (void)updateExtraTrackMergeOptions:(NSString *)uid option:(QNMergeTrackOption *)option;

@end

NS_ASSUME_NONNULL_END
