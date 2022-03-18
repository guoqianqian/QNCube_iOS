//
//  QNShowRoomController.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/11/8.
//

#import <UIKit/UIKit.h>
#import "QNRTCRoom.h"

NS_ASSUME_NONNULL_BEGIN

@class QNRoomDetailModel;

@interface QNShowRoomController : QNRTCRoom

@property (nonatomic, strong) QNRoomDetailModel *model;

@end

NS_ASSUME_NONNULL_END
