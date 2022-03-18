//
//  QNRTCRoomManager.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/9/23.
//

#import <Foundation/Foundation.h>
#import "QNRTCRoomLifecycleListener.h"

NS_ASSUME_NONNULL_BEGIN

@interface QNRTCRoomManager : NSObject

+ (instancetype)shareManager;

- (void)addRoomLifecycleListener:(id<QNRTCRoomLifecycleListener>)listener;

- (void)removeRoomLifecycleListener:(id<QNRTCRoomLifecycleListener>)listener;

@end

NS_ASSUME_NONNULL_END
