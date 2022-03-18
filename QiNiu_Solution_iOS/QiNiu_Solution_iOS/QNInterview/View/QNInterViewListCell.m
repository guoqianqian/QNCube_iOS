//
//  QNInterViewListCell.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/4/9.
//

#import "QNInterViewListCell.h"
#import <Masonry/Masonry.h>
#import <YYCategories/YYCategories.h>
#import "QNInterViewListModel.h"
#import "QNDateStringTool.h"

@interface QNInterViewListCell ()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *companyLabel;

@property (nonatomic, strong) UILabel *careerLabel;

@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) UILabel *statusLabel;

@property (nonatomic, strong) UIView *optionBgView;

@end

@implementation QNInterViewListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self titleLabel];
        [self companyLabel];
        [self careerLabel];
        [self timeLabel];
        [self statusLabel];
        [self optionBgView];
        [self setupConstraints];
    }
    return self;
}

- (void)setItemModel:(QNInterviewItemModel *)itemModel {
    
    _titleLabel.text = itemModel.title;
    _companyLabel.text = [NSString stringWithFormat:@" %@ ",itemModel.goverment];
    _careerLabel.text = [NSString stringWithFormat:@" %@ ",itemModel.career];
    NSString *startTime = [QNDateStringTool timeStringWithTimeStamp:itemModel.startTime];
    NSString *endTime = [QNDateStringTool timeStringWithTimeStamp:itemModel.endTime];
    _timeLabel.text = [NSString stringWithFormat:@"%@ - %@",startTime,endTime];
    _statusLabel.text = itemModel.status;
    _statusLabel.textColor = itemModel.textColor;
    _optionBgView.hidden = !itemModel.showOptionView;
    
    if (itemModel.showOptionView) {
        
        [self setOptionButtonsWithOptions:itemModel.options];
        
        [_timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.titleLabel);
            make.top.equalTo(self.companyLabel.mas_bottom).offset(10);
            make.height.mas_equalTo(15);
        }];
        [_optionBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.contentView);
            make.top.equalTo(self.timeLabel.mas_bottom).offset(5);
            make.bottom.equalTo(self.contentView.mas_bottom).offset(-10);
            make.height.mas_equalTo(25);
        }];
        
    } else {
        
        [_timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.titleLabel);
            make.top.equalTo(self.companyLabel.mas_bottom).offset(10);
            make.height.mas_equalTo(15);
            make.bottom.equalTo(self.contentView.mas_bottom).offset(-10);
        }];
    }
}

- (void)setOptionButtonsWithOptions:(NSArray<QNInterviewOptionsModel *> *)options {
    
    [options enumerateObjectsUsingBlock:^(QNInterviewOptionsModel * _Nonnull optionModel, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *button = [[UIButton alloc] init];
        [button setTitle:[NSString stringWithFormat:@"%@",optionModel.title] forState:UIControlStateNormal];
        button.tag = optionModel.type;
        button.backgroundColor = [UIColor colorWithHexString:@"298EFD"];
        button.titleLabel.font = [UIFont systemFontOfSize:13];
        button.layer.cornerRadius = 5;
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(optionClick:) forControlEvents:UIControlEventTouchUpInside];
        [_optionBgView addSubview:button];
        
        //适配文字宽度
        CGFloat fontWidth = [(NSString *)optionModel.title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]} context:nil].size.width + 15;
        
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.optionBgView);
            make.width.mas_equalTo(fontWidth);
            make.left.equalTo(self.contentView).offset(15 + (fontWidth + 10) * idx);
        }];
    }];
    
}

- (void)optionClick:(UIButton *)button {
    if (self.optionButtonBlock) {
        self.optionButtonBlock(button.tag);
    }
}

- (void)setupConstraints {
    
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 10)];
    lineView.backgroundColor = [UIColor colorWithHexString:@"f9f9f9"];
    [self.contentView addSubview:lineView];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(15);
        make.top.equalTo(lineView.mas_bottom).offset(15);
        make.right.equalTo(self.contentView).offset(-15);
    }];
    
    [self.companyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(10);
        make.height.mas_equalTo(20);
    }];
    
    [self.careerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.companyLabel.mas_right).offset(10);
        make.centerY.equalTo(self.companyLabel);
        make.height.mas_equalTo(20);
    }];
        
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel);
        make.top.equalTo(self.companyLabel.mas_bottom).offset(10);
        make.height.mas_equalTo(15);
    }];
    
    [_statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-15);
        make.centerY.equalTo(self.titleLabel);
    }];
    
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.text = @"郭茜的视频面试";
        _titleLabel.font = [UIFont boldSystemFontOfSize:16];
        [self.contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)companyLabel {
    if (!_companyLabel) {
        _companyLabel = [[UILabel alloc]init];
        _companyLabel.backgroundColor = [[UIColor colorWithHexString:@"85C6FF"]colorWithAlphaComponent:0.2];
        _companyLabel.layer.cornerRadius = 3;
        _companyLabel.clipsToBounds = YES;
        _companyLabel.textColor = [UIColor colorWithHexString:@"007AFF "];
        _companyLabel.text = @" 七牛云实时互动 ";
        [_companyLabel sizeToFit];
        _companyLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:_companyLabel];
    }
    return _companyLabel;
}

- (UILabel *)careerLabel {
    if (!_careerLabel) {
        _careerLabel = [[UILabel alloc]init];
        _careerLabel.backgroundColor = [[UIColor colorWithHexString:@"85C6FF"]colorWithAlphaComponent:0.2];
        _careerLabel.layer.cornerRadius = 3;
        _careerLabel.clipsToBounds = YES;
        _careerLabel.textColor = [UIColor colorWithHexString:@"007AFF "];
        _careerLabel.text = @" 开发工程师 ";
        [_careerLabel sizeToFit];
        _careerLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:_careerLabel];
    }
    return _careerLabel;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc]init];
        _timeLabel.text = @"2021年04月9日 11:00 - 2021年04月9日 12:00";
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.textColor = [UIColor darkGrayColor];
        [self.contentView addSubview:_timeLabel];
    }
    return _timeLabel;
}

- (UILabel *)statusLabel {
    if (!_statusLabel) {
        _statusLabel = [[UILabel alloc]init];
        _statusLabel.text = @"面试中";
        _statusLabel.textAlignment = NSTextAlignmentRight;
        _statusLabel.font = [UIFont boldSystemFontOfSize:14];
        _statusLabel.textColor = [UIColor colorWithHexString:@"176AFF "];
        [self.contentView addSubview:_statusLabel];
    }
    return _statusLabel;
}

- (UIView *)optionBgView {
    if (!_optionBgView) {
        _optionBgView = [[UIView alloc]init];
        [self.contentView addSubview:_optionBgView];
        [_optionBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.contentView);
            make.top.equalTo(self.timeLabel.mas_bottom).offset(5);
            make.bottom.equalTo(self.contentView.mas_bottom).offset(-10);
            make.height.mas_equalTo(25);
        }];
    }
    return _optionBgView;
}

@end
