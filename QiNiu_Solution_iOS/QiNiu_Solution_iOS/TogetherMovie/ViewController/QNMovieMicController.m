//
//  QNMovieMicController.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/12/9.
//

#import "QNMovieMicController.h"


@interface QNMovieMicController ()

@property (nonatomic, strong) UILabel *label;

@end

@implementation QNMovieMicController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    _label = [[UILabel alloc]init];
    _label.text = @"2人通话中";
    _label.textColor = [UIColor whiteColor];
    [self.view addSubview:_label];
    [_label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(20);
    }];
    
    UIButton *button = [[UIButton alloc]init];
    [button setImage:[UIImage imageNamed:@"Reduce"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(dismissController) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-20);
        make.centerY.equalTo(self.label);
    }];
    
    self.preView = [[QNGLKView alloc]init];
    [self.view addSubview:self.preView];
    [self.preView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.top.equalTo(self.view).offset(50);
        make.width.mas_equalTo(kScreenWidth/2);
        make.height.mas_equalTo(kScreenWidth/1.7);
    }];
    
    self.userView = [[QNRoomUserView alloc]init];
    [self.view addSubview:self.userView];
    [self.userView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.preView.mas_right);
        make.top.equalTo(self.view).offset(50);
        make.width.mas_equalTo(kScreenWidth/2);
        make.height.mas_equalTo(kScreenWidth/1.7);
    }];
    
    
    [self setupBottomButtons];
    [self setupBottomLabels];
}

- (void)conferenceAction {
    if (self.actionBlock) {
        self.actionBlock(QNMovieActionLeave);
    }
}

- (void)beautyAction {
    if (self.actionBlock) {
        self.actionBlock(QNMovieActionBeauty);
    }
}

- (void)microphoneAction {
    if (self.actionBlock) {
        self.actionBlock(QNMovieActionMic);
    }
}

- (void)videoAction {
    if (self.actionBlock) {
        self.actionBlock(QNMovieActionVideo);
    }
}

- (void)turnAroundAction {
    if (self.actionBlock) {
        self.actionBlock(QNMovieActionTurnAround);
    }
}

- (void)setupBottomButtons {
    
    UIView *bottomButtonView = [[UIView alloc] init];
    [self.view addSubview:bottomButtonView];
    [bottomButtonView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.mas_bottomLayoutGuide).offset(-45);
        make.height.mas_equalTo(40);
    }];
        
    NSString *normalImage[] = {@"leave_movie_room",@"movie_beauty",@"movie_mic",@"movie_video",@"movie_turn_around"};
    SEL selectors[] = {@selector(conferenceAction),@selector(beautyAction),@selector(microphoneAction),@selector(videoAction),@selector(turnAroundAction)};
    
    CGFloat buttonWidth = 60;
    NSInteger space = (kScreenWidth - buttonWidth * 5)/6;
    
    for (int i = 0; i < ARRAY_SIZE(normalImage); i ++) {
        UIButton *button = [[UIButton alloc] init];
        [button setImage:[UIImage imageNamed:normalImage[i]] forState:(UIControlStateNormal)];
        [button addTarget:self action:selectors[i] forControlEvents:(UIControlEventTouchUpInside)];
        button.selected = YES;
        [bottomButtonView addSubview:button];
    }
    
    [bottomButtonView.subviews mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:space leadSpacing:space tailSpacing:space];
    [bottomButtonView.subviews mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(bottomButtonView);
        make.width.height.mas_equalTo(buttonWidth);
    }];
}

- (void)setupBottomLabels {
    
    UIView *bottomButtonView = [[UIView alloc] init];
    [self.view addSubview:bottomButtonView];
    [bottomButtonView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.mas_bottomLayoutGuide).offset(-15);
        make.height.mas_equalTo(30);
    }];
        
    NSString *titleName[] = {@"退出", @"美颜",@"麦克风",@"摄像头",@"旋转"};
    CGFloat buttonWidth = 60;
    NSInteger space = (kScreenWidth - buttonWidth * 5)/6;
    
    for (int i = 0; i < ARRAY_SIZE(titleName); i ++) {
        UILabel *label = [[UILabel alloc] init];
        label.text = titleName[i];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:12];
        [bottomButtonView addSubview:label];
    }
    
    [bottomButtonView.subviews mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:space leadSpacing:space tailSpacing:space];
    [bottomButtonView.subviews mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(bottomButtonView);
        make.width.mas_equalTo(buttonWidth);
    }];
}

- (void)dismissController {
    [self showAlertWithTitle:@"确定退出吗？" content:@"" success:^{
        if (self.dismissBlock) {
            self.dismissBlock();
        }
        [self removeFromParentViewController];
        [self.view removeFromSuperview];
    }];
}

- (void)showAlertWithTitle:(NSString *)title content:(NSString *)content success:(void (^)(void))success{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:content preferredStyle:UIAlertControllerStyleAlert];
    UIView *subView = alertController.view.subviews.lastObject;
    UIView *alertContentView = subView.subviews.lastObject;
    
    for (UIView *subSubView in alertContentView.subviews) {
        subSubView.backgroundColor = [UIColor colorWithHexString:@"1B2C30"];
    }
    
    UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        
    }];
    [alertController addAction:cancelBtn];
    
    UIAlertAction *changeBtn = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        success();
    }];
    [alertController addAction:changeBtn];
    
    //修改title
    NSMutableAttributedString *alertControllerStr = [[NSMutableAttributedString alloc] initWithString:title];
    [alertControllerStr addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, alertControllerStr.length)];
    [alertController setValue:alertControllerStr forKey:@"attributedTitle"];

    //修改message
    NSMutableAttributedString *alertControllerMessageStr = [[NSMutableAttributedString alloc] initWithString:content];
    [alertControllerMessageStr addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, alertControllerMessageStr.length)];
    [alertController setValue:alertControllerMessageStr forKey:@"attributedMessage"];
    
    alertController.view.tintColor = [UIColor whiteColor];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
