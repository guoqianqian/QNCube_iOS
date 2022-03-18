//
//  QNRepairRoleChooseView.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/10/10.
//

#import "QNRepairRoleChooseView.h"
#import <Masonry/Masonry.h>

@interface QNRepairRoleChooseView ()
@property (nonatomic,strong) UILabel *label;
@property (nonatomic,strong) UIButton *professorButton;//专家
@property (nonatomic,strong) UIButton *staffButton;//检修员

@end

@implementation QNRepairRoleChooseView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self label];
        [self professorButton];
        [self staffButton];
    }
    return self;
}

- (void)clickedProfessorButton:(UIButton *)button {
    button.selected = !button.selected;
    if (button.selected) {
        self.staffButton.selected = NO;
        [button setBackgroundColor:[UIColor blueColor]];
        [self.staffButton setBackgroundColor:[UIColor clearColor]];
        if (self.roleChooseBlock) {
            self.roleChooseBlock(@"professor");
        }
    } else {
        [button setBackgroundColor:[UIColor clearColor]];
        
    }
}

- (void)clickedStaffButton:(UIButton *)button {
    button.selected = !button.selected;
    if (button.selected) {
        self.professorButton.selected = NO;
        [button setBackgroundColor:[UIColor blueColor]];
        [self.professorButton setBackgroundColor:[UIColor clearColor]];
        if (self.roleChooseBlock) {
            self.roleChooseBlock(@"staff");
        }
    } else {
        [button setBackgroundColor:[UIColor clearColor]];
    }
}

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc]init];
        _label.text = @"点击选择您的身份";
        _label.font = [UIFont systemFontOfSize:14];
        [self addSubview:_label];
        
        [_label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.equalTo(self).offset(8);
            make.height.mas_equalTo(15);
        }];
    }
    return _label;
}

- (UIButton *)professorButton {
    if (!_professorButton) {
        _professorButton = [[UIButton alloc]init];
        [_professorButton setTitle:@"专家" forState:UIControlStateNormal];
        _professorButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_professorButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_professorButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        _professorButton.selected = NO;
        [self addSubview:_professorButton];
        [_professorButton addTarget:self action:@selector(clickedProfessorButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [_professorButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.label.mas_bottom).offset(8);
            make.left.equalTo(self.label);
            make.height.mas_equalTo(25);
            make.width.mas_equalTo(60);
        }];
    }
    return _professorButton;
}

- (UIButton *)staffButton {
    if (!_staffButton) {
        _staffButton = [[UIButton alloc]init];
        [_staffButton setTitle:@"检修员" forState:UIControlStateNormal];
        _staffButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_staffButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_staffButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        _staffButton.selected = NO;
        [self addSubview:_staffButton];
        [_staffButton addTarget:self action:@selector(clickedStaffButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [_staffButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.professorButton);
            make.left.equalTo(self.professorButton.mas_right).offset(20);
            make.height.mas_equalTo(25);
            make.width.mas_equalTo(60);
        }];
    }
    return _staffButton;
}

@end
