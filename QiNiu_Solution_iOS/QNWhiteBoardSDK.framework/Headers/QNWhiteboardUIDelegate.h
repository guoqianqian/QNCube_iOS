//
//  QNWhiteboardUIDelegate.h
//  QNWhiteBoardSDK
//
//  Created by 郭茜 on 2021/5/14.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QNWhiteBoardSDK/QNWhiteBoardInputConfig.h>
#import <QNWhiteBoardSDK/QNActiveWidgetInfo.h>

NS_ASSUME_NONNULL_BEGIN

@protocol QNWhiteboardUIDelegate <NSObject>
-(void)presentViewController:(UIViewController *)controller_;
-(void)addView:(UIView *)view_;
-(void)snapShot:(CGRect)rect_ callback:(void(^)(NSString * _Nullable))callback_;
-(void)onDocumentSize:(int)width_ height:(int)height_ max_w:(int)max_width max_h:(int)max_height;
@end

NS_ASSUME_NONNULL_END
