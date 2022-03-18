//
//  QNMovieMicController.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/12/9.
//

#import <UIKit/UIKit.h>
#import <QNRTCKit/QNRTCKit.h>
#import "QNRoomUserView.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, QNMovieAction){
    
    QNMovieActionLeave = 0,//退出
    QNMovieActionBeauty,//美颜
    QNMovieActionMic,//麦克风
    QNMovieActionVideo,//摄像头
    QNMovieActionTurnAround, //旋转
};

@interface QNMovieMicController : UIViewController

@property (nonatomic, strong) QNGLKView *preView;

@property (nonatomic, strong) QNRoomUserView *userView;

@property (nonatomic, copy) void (^actionBlock)(QNMovieAction action);

@property (nonatomic, copy) void (^dismissBlock)(void);
@end

NS_ASSUME_NONNULL_END
