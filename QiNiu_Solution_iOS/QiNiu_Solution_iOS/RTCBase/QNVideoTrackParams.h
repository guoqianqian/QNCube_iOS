//
//  QNVideoTrackParams.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/9/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

//视频轨道参数
@interface QNVideoTrackParams : NSObject

//分辨率
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
//帧率
@property (nonatomic, assign) CGFloat fps;
//码率
@property (nonatomic, assign) CGFloat bitrate;

@property (nonatomic, assign) BOOL isMaster;

@property (nonatomic, copy) NSString *tag;


@end

NS_ASSUME_NONNULL_END
