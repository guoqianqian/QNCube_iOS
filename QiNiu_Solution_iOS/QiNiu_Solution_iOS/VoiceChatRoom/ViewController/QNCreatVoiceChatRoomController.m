//
//  QNCreatVoiceChatRoomController.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2022/1/10.
//

#import "QNCreatVoiceChatRoomController.h"
#import "QNVoiceChatRoomController.h"
#import "QNRoomDetailModel.h"

@interface QNCreatVoiceChatRoomController ()

@property (nonatomic, strong) UIButton *titleButton;

@end

@implementation QNCreatVoiceChatRoomController

-(void) viewWillAppear:(BOOL)animated
{
    self.view.superview.layer.cornerRadius = 20;
    self.view.superview.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.view.superview.clipsToBounds = YES;
    self.view.superview.frame = CGRectMake(0, kScreenHeight - 350, kScreenWidth, 350);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self addRoomTitleButton];
    [self startRoomButton];
    
    UIImageView *imageview = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"voice_chat_room_type"]];
    [self.view addSubview:imageview];
    [imageview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottom).offset(-185);
        make.width.mas_equalTo(320);
        make.height.mas_equalTo(100);
    }];
    
    UIView *line = [[UIView alloc]init];
    line.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottom).offset(-160);
        make.left.equalTo(self.view).offset(20);
        make.height.mas_equalTo(1);
    }];
    
    UILabel *label = [[UILabel alloc]init];
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:15];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"Start a room open to everyone";
    [self.view addSubview:label];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
//        make.top.equalTo(self.view).offset(70);
        make.bottom.equalTo(self.view.mas_bottom).offset(-135);
    }];
}

- (void)addRoomTitleButton{
    
    UIButton *button = [[UIButton alloc]init];
    [button setTitle:@"+ 输入房间名" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithHexString:@"3CB371"] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [button addTarget:self action:@selector(setRoomName) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-20);
        make.top.equalTo(self.view).offset(30);
    }];
    
    self.titleButton = button;
}

- (void)startRoomButton {
    
    UIButton *startButton = [[UIButton alloc]init];
    [startButton setTitle:@"开始聊天吧" forState:UIControlStateNormal];
    [startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    startButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [startButton setBackgroundColor:[UIColor colorWithHexString:@"3CB371"]];
    startButton.clipsToBounds = YES;
    startButton.layer.cornerRadius = 20;
    [self.view addSubview:startButton];
    [self.view bringSubviewToFront:startButton];
    [startButton addTarget:self action:@selector(startRoom) forControlEvents:UIControlEventTouchUpInside];
    
    [startButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottom).offset(-80);
        make.height.mas_equalTo(40);
        make.width.mas_equalTo(150);
    }];
}

- (void)setRoomName {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Set room title" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            
    }];
    
    UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertController addAction:cancelBtn];
    
    UIAlertAction *changeBtn = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [[alertController.textFields firstObject] endEditing:YES];
        
        [self.titleButton setTitle:[alertController.textFields firstObject].text forState:UIControlStateNormal];
                    
    }];
    [alertController addAction:changeBtn];
    
    [self presentViewController:alertController animated:YES completion:nil];

}

- (void)startRoom {
        
    NSMutableDictionary *requestParams = [NSMutableDictionary dictionary];
    requestParams[@"title"] = self.titleButton.titleLabel.text;
    requestParams[@"type"] = @"voiceChatRoom";
    
    [QNNetworkUtil postRequestWithAction:@"base/createRoom" params:requestParams success:^(NSDictionary *responseData) {
        
        QNRoomDetailModel *model = [QNRoomDetailModel mj_objectWithKeyValues:responseData];
        
        QNVoiceChatRoomController *vc = [QNVoiceChatRoomController new];
        vc.model = model;
        vc.model.userInfo.role = @"roomHost";
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:vc animated:YES completion:nil];
            
        } failure:^(NSError *error) {
            
        }];

}

@end
