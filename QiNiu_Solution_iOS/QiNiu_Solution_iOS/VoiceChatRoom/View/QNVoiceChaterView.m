//
//  QNVoiceChaterView.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2022/1/10.
//

#import "QNVoiceChaterView.h"

@interface QNVoiceChaterView ()

@property (nonatomic,strong)UIImageView *chatingImageView;
//
//@property (nonatomic,strong)UILabel *onLineNumberLabel;

@end

@implementation QNVoiceChaterView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self mainImageView];
        [self nameLabel];
    }
    return self;
}

- (UIImageView *)mainImageView {
    if (!_mainImageView) {
        _mainImageView = [[UIImageView alloc]init];
        _mainImageView.backgroundColor = [UIColor lightGrayColor];
        _mainImageView.clipsToBounds = YES;
        _mainImageView.layer.cornerRadius = 20;
        [self addSubview:_mainImageView];
        
        [_mainImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.left.equalTo(self).offset(10);
            make.bottom.equalTo(self).offset(-23);
            make.top.equalTo(self);
        }];
    }
    return _mainImageView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc]init];
        _nameLabel.textColor = [UIColor blackColor];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.font = [UIFont systemFontOfSize:14];
        _nameLabel.text = @"ddddff";
        [self addSubview:_nameLabel];
        
        [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self.mainImageView.mas_bottom).offset(8);
        }];
    }
    return _nameLabel;
}

@end
