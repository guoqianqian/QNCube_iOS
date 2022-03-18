//
//  QNMovieLiveController.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/12/15.
//

#import "QNMovieLiveController.h"
#import <PLPlayerKit/PLPlayerKit.h>
#import "MBProgressHUD+QNShow.h"
#import <Masonry/Masonry.h>
#import <YYCategories/YYCategories.h>
#import "QNRoomDetailModel.h"

@interface QNMovieLiveController ()<
PLPlayerDelegate
>

@property (nonatomic, strong) PLPlayer *player;

@end

@implementation QNMovieLiveController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self joinMovieRoom];
    
}

- (void)joinMovieRoom {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"type"] = @"movie";
    params[@"roomId"] = self.model.roomInfo.roomId;
    
    [QNNetworkUtil postRequestWithAction:@"base/joinRoom" params:params success:^(NSDictionary *responseData) {
        
        self.model = [QNRoomDetailModel mj_objectWithKeyValues:responseData];
        self.model.roomInfo.params = [QNAttrsModel mj_objectArrayWithKeyValuesArray:responseData[@"roomInfo"][@"params"]];
        self.model.allUserList = [QNUserInfo mj_objectArrayWithKeyValuesArray:responseData[@"allUserList"]];
        
        QNUserInfo *userInfo = [QNUserInfo new];
        userInfo.role = self.model.userInfo.role;
        self.model.userInfo = userInfo;
        
        [self playWithUrlStr:self.model.rtcInfo.publishUrl];
        
    } failure:^(NSError *error) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)playWithUrlStr:(NSString *)urlStr {
    
    NSURL *url = [NSURL URLWithString:urlStr];
    
    PLPlayerOption *option = [PLPlayerOption defaultOption];
    PLPlayFormat format = kPLPLAY_FORMAT_UnKnown;
    
    [option setOptionValue:@(format) forKey:PLPlayerOptionKeyVideoPreferFormat];
    [option setOptionValue:@(kPLLogNone) forKey:PLPlayerOptionKeyLogLevel];
    
    self.player = [PLPlayer playerWithURL:url option:option];
    [self.view insertSubview:self.player.playerView atIndex:0];
    [self.player.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    self.player.playerView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.player.delegateQueue = dispatch_get_main_queue();
    self.player.delegate = self;
    
    [self.player play];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth - 54)/2, kScreenHeight - 100 , 54, 54)];
    [button setImage:[UIImage imageNamed:@"close-phone"] forState:(UIControlStateNormal)];
    [button addTarget:self action:@selector(conference) forControlEvents:(UIControlEventTouchUpInside)];
    button.selected = YES;
    [self.view addSubview:button];
}

// 退出房间
- (void)conference {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - PLPlayerDelegate

- (void)player:(nonnull PLPlayer *)player stoppedWithError:(nullable NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Player Errro: %@", error);
    });
}

- (void)player:(PLPlayer *)player width:(int)width height:(int)height {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Width: %d \nHeight: %d", width, height);
    });
}

- (void)player:(PLPlayer *)player willRenderFrame:(CVPixelBufferRef)frame pts:(int64_t)pts sarNumerator:(int)sarNumerator sarDenominator:(int)sarDenominator {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *str = [NSString stringWithFormat:@"  VideoBitrate: %.f kb/s \n  VideoFPS: %d", player.videoBitrate, player.videoFPS];
        NSLog(@"%@", str);
    });
}


@end
