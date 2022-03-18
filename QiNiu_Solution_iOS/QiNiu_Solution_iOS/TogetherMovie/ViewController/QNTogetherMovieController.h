//
//  QNTogetherMovieController.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/12/3.
//

#import <UIKit/UIKit.h>
#import "QNRTCRoom.h"

NS_ASSUME_NONNULL_BEGIN

@class QNMovieListModel,QNRoomDetailModel;

@interface QNTogetherMovieController : QNRTCRoom

@property (nonatomic, strong)QNMovieListModel *listModel;

@property (nonatomic, strong)QNRoomDetailModel *model;

@property (nonatomic, copy)NSString *inviteCode;
@end

NS_ASSUME_NONNULL_END
