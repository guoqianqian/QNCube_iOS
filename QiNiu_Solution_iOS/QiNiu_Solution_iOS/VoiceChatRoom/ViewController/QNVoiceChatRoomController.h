//
//  QNVoiceChatRoomController.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2022/1/10.
//

#import <UIKit/UIKit.h>
#import "QNRTCRoom.h"
NS_ASSUME_NONNULL_BEGIN

@class QNRoomDetailModel;

@interface QNVoiceChatRoomController : QNRTCRoom

@property (nonatomic, strong)QNRoomDetailModel *model;

@end

NS_ASSUME_NONNULL_END
