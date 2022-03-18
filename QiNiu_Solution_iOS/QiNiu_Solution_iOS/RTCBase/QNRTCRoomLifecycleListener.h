//
//  QNRTCRoomLifecycleListener.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/9/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 房间生命周期
 */

@class QNRTCRoomEntity;

@protocol QNRTCRoomLifecycleListener <NSObject>

//进房中
- (void)onRoomEntering:(QNRTCRoomEntity *)roomEntity;
//加入了房间
- (void)onRoomJoined:(QNRTCRoomEntity *)roomEntity;
//加入失败
- (void)onRoomJoinFail:(QNRTCRoomEntity *)roomEntity;
//离开房间
- (void)onRoomLeaving:(QNRTCRoomEntity *)roomEntity;
//关闭房间
- (void)onCloseRoom:(QNRTCRoomEntity *)roomEntity;
//加入聊天室
- (void)onRoomChannelJoin:(QNRTCRoomEntity *)roomEntity;

@end

NS_ASSUME_NONNULL_END
