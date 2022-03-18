//
//  QNApplyOnSeatView.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/11/8.
//

#import <UIKit/UIKit.h>
#import <QNRTCKit/QNRTCKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QNApplyOnSeatView : QNGLKView

@property (nonatomic, assign) BOOL isSeat;

@property (nonatomic, copy) NSString *imageName;

@property (nonatomic, assign) NSInteger tagIndex;

@property (nonatomic, copy) NSString *userId;

@property (nonatomic, copy) void (^onSeatBlock)(NSInteger tag);

@end

NS_ASSUME_NONNULL_END
