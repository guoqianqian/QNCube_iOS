//
//  QNWhiteBoardDemoController.m
//  QNWhiteBoardDemo
//
//  Created by 郭茜 on 2021/5/13.
//

#import "QNRepairWhiteBoardController.h"
#import <AVFoundation/AVFoundation.h>
#import <QNWhiteBoardSDK/QNWhiteBoardSDK.h>
#import <YYCategories/YYCategories.h>

@interface QNRepairWhiteBoardController ()<QNWhiteboardDelegate,QNWhiteboardUIDelegate>

@end

@implementation QNRepairWhiteBoardController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [super initializeWhiteboard];
    
    [self.view setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.0]];
    
    [self joinRoom];
}

- (void)viewDidAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewBecomeActive)name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewBecomeActive)name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewBecomeActive {
    [self setDirty];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if(self.isMovingFromParentViewController)
    {
//        [[QNWhiteboardControl instance] leaveRoom];
//        [super closeWhiteboard];
    }
}

-(void)joinRoom
{
    [[QNWhiteboardControl instance] addListener:self];

    QNWhiteboardJoinRoomConfig *config = [[QNWhiteboardJoinRoomConfig alloc]init];
    config.aspectRatio = (CGFloat)9/16;
    [[QNWhiteboardControl instance] joinRoom:self.roomToken config:config];
    [[QNWhiteboardControl instance] setBackgroundColor:@"#00000000"];
    
}

- (NSString *)hexStringFromColor:(UIColor *)color {
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    return [NSString stringWithFormat:@"#%02lX%02lX%02lX", lroundf(components[0] * 255), lroundf(components[1] * 255), lroundf(components[2] * 255)];
}

- (void)onJoinSuccess:(QNWhiteBoardRoom *)room who:(QNWhiteBoardRoomMember *)me {
    
    if (self.roleType == QNRepairRoleTypeProfessor) {
        QNWhiteBoardInputConfig *config = [QNWhiteBoardInputConfig instanceWithPen:@"#FF252525" thickness:4.0f];
        [[QNWhiteboardControl instance] setInputMode:config];
    } else {
        QNWhiteBoardInputConfig *config = [QNWhiteBoardInputConfig instanceWithPen:@"#000000" thickness:0];
        [[QNWhiteboardControl instance] setInputMode:config];
    }
    
//    [[QNWhiteboardControl instance] setBackgroundColor:@"#00000000"];
}

//文档被滚动到顶部或底部时触发
- (void)onWidgetScrolled:(QNWhiteBoardWidgetScrollInfo *)info {
    
}

- (void)onBoardSizeChanged:(QNWhiteBoardInfo *)info_ {
    [[QNWhiteboardControl instance] setBackgroundColor:@"#00000000"];

}

//页面被清空时触发
- (void)onBoardCleaned:(NSString *)pageId_ {
    
    [self dismissViewControllerAnimated:YES completion:^{
        [[QNWhiteboardControl instance] leaveRoom];
        [super closeWhiteboard];
    }];
}
                     
@end
