//
//  QNRTCRoomManager.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/9/23.
//

#import "QNRTCRoomManager.h"

@interface QNRTCRoomManager ()

@property (nonatomic, weak) id <QNRTCRoomLifecycleListener> listener;

@end

@implementation QNRTCRoomManager

static QNRTCRoomManager *manager;

+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        manager = [[QNRTCRoomManager alloc]init];
    });
    return manager;
}

- (void)addRoomLifecycleListener:(id<QNRTCRoomLifecycleListener>)listener {
    self.listener = listener;
}

- (void)removeRoomLifecycleListener:(id<QNRTCRoomLifecycleListener>)listener {
    self.listener = nil;
}

@end
