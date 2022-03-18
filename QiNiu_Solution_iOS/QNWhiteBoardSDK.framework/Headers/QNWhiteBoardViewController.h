//
//  QNWhiteBoardViewController.h
//  QNWhiteBoardSDK
//
//  Created by 郭茜 on 2021/5/20.
//

#import <GLKit/GLKit.h>
#import <UIKit/UIKit.h>
#import "QNWhiteboardControl.h"
#import "QNWhiteboardUIDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface QNWhiteBoardViewController : GLKViewController<GLKViewControllerDelegate,QNWhiteboardUIDelegate,QNWhiteboardDelegate>

-(bool)initRender:(CGSize)size;

-(void)setDirty;


-(void)presentViewController:(UIViewController *)controller_;



-(void)initializeWhiteboard;
-(void)closeWhiteboard;

@end

NS_ASSUME_NONNULL_END
