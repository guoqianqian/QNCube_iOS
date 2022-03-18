//
//  QNMovieOnlineView.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/12/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QNRoomDetailModel,QNUserInfo;

@interface QNMovieOnlineView : UIView

@property (nonatomic, strong)QNRoomDetailModel *model;

@property (nonatomic, copy) void (^playListBlock)(void);

@end

NS_ASSUME_NONNULL_END
