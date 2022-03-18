//
//  QNAddInterViewCell.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/4/9.
//

#import "QNAddInterViewCell.h"
#import "QNAddInterViewViewModel.h"
#import "QNAddInterViewInfoModel.h"
#import <Masonry/Masonry.h>
#import <YYCategories/YYCategories.h>
#import "MBProgressHUD+QNShow.h"
#import "QNDatePickerView.h"
#import <IQKeyboardManager/IQKeyboardManager.h>

@interface QNAddInterViewCell ()<UITextFieldDelegate>

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UITextField *contentTf;

@property (nonatomic, strong) UIButton *isAuthButton;

@property (nonatomic, strong) UIButton *secretButton;

@property (nonatomic, strong) QNDatePickerView *datePicker;

@property (nonatomic, strong) QNAddInterViewInfoModel *model;

@end

@implementation QNAddInterViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self titleLabel];
        [self contentTf];
        [self isAuthButton];
        [self secretButton];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)updateWithModel:(QNAddInterViewInfoModel *)model {
    _model = model;
    _titleLabel.text = _model.title;
    NSAttributedString *placeHolderStr = [[NSAttributedString alloc]initWithString:_model.placeholder attributes:@{
        NSForegroundColorAttributeName:[UIColor lightGrayColor],
        NSFontAttributeName:_contentTf.font
    }];
    _contentTf.attributedPlaceholder = placeHolderStr;
    if (_model.content.length > 0) {
        _contentTf.text = _model.content;
    }
    
    if ([model.title isEqualToString:@"入会密码"] || [model.title isEqualToString:@"是否开启面试录制"]) {
        self.contentTf.hidden = YES;
        self.isAuthButton.hidden = NO;
        self.isAuthButton.selected = _model.content.integerValue;
        [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(200);
        }];
    }
    
    if ([model.title isEqualToString:@"密码"]) {
        self.secretButton.hidden = NO;
        self.contentTf.secureTextEntry = YES;
    }
    
    if ([model.title isEqualToString:@"手机号"]) {
        self.contentTf.keyboardType = UIKeyboardTypeNumberPad;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([self.model.title isEqualToString:@"开始时间"] || [self.model.title isEqualToString:@"结束时间"]) {
        [_contentTf resignFirstResponder];
        __weak typeof(self) weakSelf = self;
        
        NSDate *showDate = [NSDate dateWithString:self.model.content format:@"yyyy年MM月dd日HH:mm"];
        
        _datePicker = [[QNDatePickerView alloc]initWithDateStyle:CXDateStyleShowYearMonthDayHourMinute scrollToDate:showDate CompleteBlock:^(NSDate *date) {
            NSDateFormatter *dateForm = [[NSDateFormatter alloc]init];
            dateForm.dateFormat =@"yyyy年MM月dd日HH:mm";
            weakSelf.contentTf.text = [dateForm stringFromDate:date];
            weakSelf.model.content = weakSelf.contentTf.text;
        }];

        [_datePicker show];
        
    } else {
        
    }
}

- (void)isAuthButtonClick {
    self.isAuthButton.selected = !self.isAuthButton.selected;
    self.model.content = @(self.isAuthButton.selected).stringValue;
}

- (void)isSecretButtonClick {
    self.secretButton.selected = !self.secretButton.selected;
    self.model.content = @(self.isAuthButton.selected).stringValue;
    _contentTf.secureTextEntry = !_secretButton.selected;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
    self.model.content = textField.text;
    if ([self.model.title isEqualToString:@"手机号"] && self.model.content.length != 11){
        [MBProgressHUD showText:@"请输入正确的手机号"];
    }
    if (self.textEndEditBlock) {
        self.textEndEditBlock(self.model);
    }
    
    if ([self.model.title isEqualToString:@"面试标题"]) {
        self.model.isEdited = YES;
    }
    
    if ([self.model.title isEqualToString:@"姓名"]) {
        if (self.interviewNameBlock) {
            self.interviewNameBlock(textField.text);
        }
    }
    
    if ([self.model.title isEqualToString:@"开始时间"] || [self.model.title isEqualToString:@"结束时间"]) {
        [_datePicker dismiss];
    }
    return YES;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.font = [UIFont boldSystemFontOfSize:16];
        [self.contentView addSubview:_titleLabel];
        
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(20);
            make.centerY.equalTo(self.contentView);
            make.width.mas_equalTo(80);
        }];
    }
    return _titleLabel;
}

- (UITextField *)contentTf {
    if (!_contentTf) {
        _contentTf = [[UITextField alloc] init];
        _contentTf.font = [UIFont systemFontOfSize:16];
        _contentTf.delegate = self;
        [self.contentView addSubview:_contentTf];
        
        [_contentTf mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.height.mas_equalTo(30);
            make.right.equalTo(self.contentView).offset(-20);
            make.left.equalTo(self.titleLabel.mas_right).offset(15);

        }];
    }
    return _contentTf;
}

- (UIButton *)isAuthButton {
    if (!_isAuthButton) {
        _isAuthButton = [[UIButton alloc]init];
        [_isAuthButton setImage:[UIImage imageNamed:@"icon_button_off"] forState:UIControlStateNormal];
        [_isAuthButton setImage:[UIImage imageNamed:@"icon_button_on"] forState:UIControlStateSelected];
        [_isAuthButton addTarget:self action:@selector(isAuthButtonClick) forControlEvents:UIControlEventTouchUpInside];
        _isAuthButton.selected = NO;
        _isAuthButton.hidden = YES;
        [self.contentView addSubview:_isAuthButton];
        
        [_isAuthButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.right.equalTo(self.contentView.mas_right).offset(-20);
            make.height.mas_equalTo(35);
            make.width.mas_equalTo(60);
        }];
    }
    return _isAuthButton;
}

- (UIButton *)secretButton {
    if (!_secretButton) {
        _secretButton = [[UIButton alloc]init];
        [_secretButton setImage:[UIImage imageNamed:@"icon_eye_off"] forState:UIControlStateNormal];
        [_secretButton setImage:[UIImage imageNamed:@"icon_eye_on"] forState:UIControlStateSelected];
        [_secretButton addTarget:self action:@selector(isSecretButtonClick) forControlEvents:UIControlEventTouchUpInside];
        _secretButton.hidden = YES;
        [self.contentView addSubview:_secretButton];
        
        [_secretButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.isAuthButton);
            make.height.mas_equalTo(20);
            make.width.mas_equalTo(30);
        }];
    }
    return _secretButton;
}

@end
