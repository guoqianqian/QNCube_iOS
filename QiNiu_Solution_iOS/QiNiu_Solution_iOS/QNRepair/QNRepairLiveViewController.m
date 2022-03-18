//
//  QNRepairLiveViewController.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/10/12.
//

#import "QNRepairLiveViewController.h"
#import <PLPlayerKit/PLPlayerKit.h>
#import "QNNetworkUtil.h"
#import <MJExtension/MJExtension.h>
#import "QNJoinRepairModel.h"
#import "MBProgressHUD+QNShow.h"
#import <Masonry/Masonry.h>
#import <YYCategories/YYCategories.h>
#import "QNRepairListModel.h"

@interface QNRepairLiveViewController ()<
PLPlayerDelegate
>

@property (nonatomic, strong) PLPlayer *player;

@end

@implementation QNRepairLiveViewController

- (void)viewDidLoad {
    
    
    [super viewDidLoad];
    self.title = self.model.title;
    self.view.backgroundColor = [UIColor whiteColor];
    [self joinRoom];
    
}

- (void)joinRoom {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"roomId"] = self.model.roomId;
    params[@"role"] = @"student";
    
    [QNNetworkUtil postRequestWithAction:@"repair/joinRoom" params:params success:^(NSDictionary *responseData) {
        
        QNJoinRepairModel *repairModel = [QNJoinRepairModel mj_objectWithKeyValues:responseData];
        repairModel.allUserList = [QNJoinRepairUserInfoModel mj_objectArrayWithKeyValuesArray:responseData[@"allUserList"]];
        
        [self playWithUrlStr:repairModel.publishUrl];
        
    } failure:^(NSError *error) {
        
        [MBProgressHUD showText:@"加入房间失败!"];
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
