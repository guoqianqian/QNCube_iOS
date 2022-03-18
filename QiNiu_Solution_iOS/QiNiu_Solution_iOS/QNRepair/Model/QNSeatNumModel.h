//
//  QNSeatNumModel.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/11/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class QNCustomVideoTrack,QNCustomAudioTrack;

@interface QNSeatNumModel : NSObject

@property (nonatomic, strong) QNCustomVideoTrack *cameraTrack;

@property (nonatomic, strong) QNCustomAudioTrack *audioTrack;
//房间上麦人数（不包括房主）
@property (nonatomic, copy) NSString *totalOnSeatNum;

@end

NS_ASSUME_NONNULL_END
