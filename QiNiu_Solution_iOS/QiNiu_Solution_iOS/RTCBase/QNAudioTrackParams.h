//
//  QNAudioTrackParams.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/9/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QNAudioTrackParams : NSObject

@property (nonatomic, assign) CGFloat bitrate;

@property (nonatomic, assign) CGFloat volume;

@property (nonatomic, assign) BOOL isMaster;

@property (nonatomic, copy) NSString *tag;

@end

NS_ASSUME_NONNULL_END
