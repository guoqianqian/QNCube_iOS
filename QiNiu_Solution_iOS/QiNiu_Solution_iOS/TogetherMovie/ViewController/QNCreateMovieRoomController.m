//
//  QNCreateMovieRoomController.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/12/2.
//

#import "QNCreateMovieRoomController.h"
#import <PLPlayerKit/PLPlayerKit.h>
#import "QNNetworkUtil.h"
#import <MJExtension/MJExtension.h>
#import "MBProgressHUD+QNShow.h"
#import <Masonry/Masonry.h>
#import <YYCategories/YYCategories.h>
#import "QNMovieListModel.h"
#import "QNTogetherMovieController.h"
#import "QNRoomDetailModel.h"
#import "QNMoreMovieRoomController.h"
#import <AVKit/AVKit.h>
#import "CLPlayerView.h"

@interface QNCreateMovieRoomController ()<PLPlayerDelegate>

@property (nonatomic, strong)CLPlayerView *playerView;

@property (nonatomic, strong)QNRoomDetailModel *model;

@end

@implementation QNCreateMovieRoomController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self playWithUrlStr:self.listModel.playUrl];
}

- (void)viewDidDisappear:(BOOL)animated {
    [_playerView pausePlay];
}

- (void)playWithUrlStr:(NSString *)urlStr {
    
    [_playerView destroyPlayer];
    CLPlayerView *playerView = [[CLPlayerView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 240)];
        
    [playerView updateWithConfigure:^(CLPlayerViewConfigure *configure) {
        configure.backPlay = NO;
        configure.topToolBarHiddenType = TopToolBarHiddenAlways;
        configure.progressPlayFinishColor = [UIColor colorWithHexString:@"58C1F4"];
        configure.strokeColor = [UIColor whiteColor];
    }];
        _playerView = playerView;
        [self.view addSubview:_playerView];
        //视频地址
        _playerView.url = [NSURL URLWithString:urlStr];
        //播放
        [_playerView playVideo];
        //返回按钮点击事件回调
        [_playerView backButton:^(UIButton *button) {
            NSLog(@"返回按钮被点击");
        }];
        //播放完成回调
        [_playerView endPlay:^{
            //销毁播放器
//            [_playerView destroyPlayer];
//            _playerView = nil;
            NSLog(@"播放完成");
        }];
    
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(20, 40 , 30, 30)];
    [button setImage:[UIImage imageNamed:@"icon_return"] forState:(UIControlStateNormal)];
    [button addTarget:self action:@selector(conference) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:button];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.text = self.listModel.name;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.top.equalTo(self.playerView.mas_bottom).offset(10);
    }];
    
    
    UIImageView *createBgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"RectangleBg"]];
    createBgView.userInteractionEnabled = YES;
    [self.view addSubview:createBgView];
    
    [createBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view);
        make.top.equalTo(titleLabel.mas_bottom).offset(40);
        make.left.equalTo(self.view).offset(25);
    }];
    
    UIButton *createButton = [[UIButton alloc]init];
    [createButton setImage:[UIImage imageNamed:@"add_room"] forState:UIControlStateNormal];
    [createBgView addSubview:createButton];
    [createButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(createBgView);
        make.top.equalTo(createBgView).offset(15);
    }];
    [createButton addTarget:self action:@selector(createRoom) forControlEvents:UIControlEventTouchUpInside];

    
    UILabel *createLabel = [[UILabel alloc]init];
    createLabel.text = @"创建房间";
    createLabel.textColor = [UIColor whiteColor];
    createLabel.font = [UIFont systemFontOfSize:14];
    [createBgView addSubview:createLabel];
    [createLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(createBgView);
        make.top.equalTo(createButton.mas_bottom).offset(10);
    }];

    
    UILabel *createDescLabel = [[UILabel alloc]init];
    createDescLabel.text = @"邀请好友连麦看视频";
    createDescLabel.textColor = [UIColor lightTextColor];
    createDescLabel.font = [UIFont systemFontOfSize:12];
    [createBgView addSubview:createDescLabel];
    [createDescLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(createBgView);
        make.top.equalTo(createLabel.mas_bottom).offset(10);
    }];
    
    
    
    UIImageView *moreBgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Rectangle"]];
    moreBgView.userInteractionEnabled = YES;
    [self.view addSubview:moreBgView];
    
    [moreBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(createBgView.mas_bottom).offset(20);
        make.left.equalTo(createBgView);
        make.width.height.mas_equalTo(150);
    }];
    
    UIButton *moreButton = [[UIButton alloc]init];
    [moreButton setImage:[UIImage imageNamed:@"Home"] forState:UIControlStateNormal];
    [moreBgView addSubview:moreButton];
    [moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(moreBgView);
        make.top.equalTo(moreBgView).offset(15);
    }];
    [moreButton addTarget:self action:@selector(moreRoom) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *moreLabel = [[UILabel alloc]init];
    moreLabel.text = @"更多房间";
    moreLabel.textColor = [UIColor whiteColor];
    moreLabel.font = [UIFont systemFontOfSize:14];
    [moreBgView addSubview:moreLabel];
    [moreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(moreBgView);
        make.top.equalTo(moreButton.mas_bottom).offset(10);
    }];
    
    UILabel *moreDescLabel = [[UILabel alloc]init];
    moreDescLabel.text = @"去广场，解锁更多聊天室";
    moreDescLabel.textColor = [UIColor lightTextColor];
    moreDescLabel.font = [UIFont systemFontOfSize:12];
    [moreBgView addSubview:moreDescLabel];
    [moreDescLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(moreBgView);
        make.top.equalTo(moreLabel.mas_bottom).offset(10);
    }];
    
    
    UIImageView *invitationBgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Rectangle"]];
    invitationBgView.userInteractionEnabled = YES;
    [self.view addSubview:invitationBgView];
    
    [invitationBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(createBgView.mas_bottom).offset(20);
        make.right.equalTo(createBgView);
        make.width.height.mas_equalTo(150);
    }];
    
    UIButton *invitationButton = [[UIButton alloc]init];
    [invitationButton setImage:[UIImage imageNamed:@"User_add"] forState:UIControlStateNormal];
    [invitationBgView addSubview:invitationButton];
    [invitationButton addTarget:self action:@selector(inputInviteCode) forControlEvents:UIControlEventTouchUpInside];
    [invitationButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(invitationBgView);
        make.top.equalTo(invitationBgView).offset(15);
    }];
    
    UILabel *invitationLabel = [[UILabel alloc]init];
    invitationLabel.text = @"邀请码";
    invitationLabel.textColor = [UIColor whiteColor];
    invitationLabel.font = [UIFont systemFontOfSize:14];
    [invitationBgView addSubview:invitationLabel];
    [invitationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(invitationBgView);
        make.top.equalTo(invitationButton.mas_bottom).offset(10);
    }];
    
    UILabel *invitationDescLabel = [[UILabel alloc]init];
    invitationDescLabel.text = @"输入邀请码快速加入";
    invitationDescLabel.textColor = [UIColor lightTextColor];
    invitationDescLabel.font = [UIFont systemFontOfSize:12];
    [invitationBgView addSubview:invitationDescLabel];
    [invitationDescLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(invitationBgView);
        make.top.equalTo(invitationLabel.mas_bottom).offset(10);
    }];
    
}

- (void)inputInviteCode {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请输入邀请码" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIView *subView = alertController.view.subviews.lastObject;
    UIView *alertContentView = subView.subviews.lastObject;
    
    for (UIView *subSubView in alertContentView.subviews) {
        subSubView.backgroundColor = [UIColor colorWithHexString:@"1B2C30"];
    }
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            
    }];
    
    UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertController addAction:cancelBtn];
    
    UIAlertAction *changeBtn = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        QNTogetherMovieController *vc = [QNTogetherMovieController new];
        vc.listModel = self.listModel;
        vc.model = self.model;
        vc.model.userInfo.role = @"roomAudience";
        vc.inviteCode = [alertController.textFields firstObject].text;
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:vc animated:YES completion:nil];
        
    }];
    [alertController addAction:changeBtn];
    
    NSMutableAttributedString *alertControllerStr = [[NSMutableAttributedString alloc] initWithString:@"请输入邀请码"];
    [alertControllerStr addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, 6)];
    [alertController setValue:alertControllerStr forKey:@"attributedTitle"];
    
    alertController.view.tintColor = [UIColor whiteColor];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

// 退出房间
- (void)conference {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)createRoom {
    
    
    NSMutableDictionary *requestParams = [NSMutableDictionary dictionary];
    requestParams[@"title"] = self.listModel.name;
    requestParams[@"type"] = @"movie";
//    requestParams[@"image"] = self.imageStr;
    
    
    [QNNetworkUtil postRequestWithAction:@"base/createRoom" params:requestParams success:^(NSDictionary *responseData) {
        
        self.model = [QNRoomDetailModel mj_objectWithKeyValues:responseData];
        self.model.roomInfo.params = [QNAttrsModel mj_objectArrayWithKeyValuesArray:responseData[@"roomInfo"][@"params"]];
        QNTogetherMovieController *vc = [QNTogetherMovieController new];
        vc.listModel = self.listModel;
        vc.model = self.model;
        vc.model.userInfo.role = @"roomHost";
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:vc animated:YES completion:nil];
        
        
        [self movieOperationWithRoomId:self.model.roomInfo.roomId];
            
        } failure:^(NSError *error) {
            
        }];
    
    
}

- (void)movieOperationWithRoomId:(NSString *)roomId {
    
    NSMutableDictionary *requestParams = [NSMutableDictionary dictionary];
    requestParams[@"roomId"] = roomId;
    requestParams[@"movieId"] = self.listModel.movieId;
    requestParams[@"operateType"] = @"select";
    
    
    [QNNetworkUtil postRequestWithAction:@"watchMoviesTogether/movieOperation" params:requestParams success:^(NSDictionary *responseData) {
           
        } failure:^(NSError *error) {
        }];
}

- (void)moreRoom {
    
    QNMoreMovieRoomController *vc = [QNMoreMovieRoomController new];
    vc.listModel = self.listModel;
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
}

@end
