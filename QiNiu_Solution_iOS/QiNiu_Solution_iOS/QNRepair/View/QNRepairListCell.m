//
//  QNRepairListCell.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/9/27.
//

#import "QNRepairListCell.h"
#import <Masonry/Masonry.h>
#import <YYCategories/YYCategories.h>
#import "QNRepairListModel.h"
#import "QNAddRepairItemModel.h"

@interface QNRepairListCell ()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIView *optionBgView;

@end

@implementation QNRepairListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self titleLabel];

        [self optionBgView];
        [self setupConstraints];
    }
    return self;
}

- (void)setItemModel:(QNRepairItemModel *)itemModel {
    
    _titleLabel.text = itemModel.title;
       
    [self setOptionButtonsWithOptions:itemModel.options];
        
}

- (void)setOptionButtonsWithOptions:(NSArray<QNAddRepairItemModel *> *)options {
    
    [options enumerateObjectsUsingBlock:^(QNAddRepairItemModel * _Nonnull optionModel, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *button = [[UIButton alloc] init];
        [button setTitle:[NSString stringWithFormat:@"%@",optionModel.title] forState:UIControlStateNormal];
//        button.backgroundColor = [UIColor colorWithHexString:@"298EFD"];
        button.titleLabel.font = [UIFont systemFontOfSize:13];
        button.layer.cornerRadius = 5;
        [button setTitleColor:[UIColor colorWithHexString:@"298EFD"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(optionClick:) forControlEvents:UIControlEventTouchUpInside];
        [_optionBgView addSubview:button];
        
        //适配文字宽度
        CGFloat fontWidth = [(NSString *)optionModel.title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]} context:nil].size.width + 15;
        
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.optionBgView);
            make.width.mas_equalTo(fontWidth);
            make.left.equalTo(self.contentView).offset(25 + (fontWidth + 15) * idx);
        }];
    }];
    
}

- (void)optionClick:(UIButton *)button {
    if (self.optionButtonBlock) {
        self.optionButtonBlock(button.titleLabel.text);
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

    [_optionBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(5);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-10);
        make.height.mas_equalTo(25);
    }];
    
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.font = [UIFont boldSystemFontOfSize:16];
        [self.contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UIView *)optionBgView {
    if (!_optionBgView) {
        _optionBgView = [[UIView alloc]init];
        [self.contentView addSubview:_optionBgView];
    }
    return _optionBgView;
}


@end
