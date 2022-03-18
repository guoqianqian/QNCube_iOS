//
//  QNMovieListCell.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/11/29.
//

#import "QNMovieListCell.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/SDWebImage.h>

#import "QNMovieListModel.h"

@interface QNMovieListCell ()

@property (nonatomic, strong) UIImageView *movieMainImageView;

@property (nonatomic, strong) UIView *bottomBgView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIButton *addButton;

@end

@implementation QNMovieListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self movieMainImageView];
        [self bottomBgView];
        [self titleLabel];
        [self addButton];
    }
    return self;
}

- (void)setItemModel:(QNMovieListModel *)itemModel {
    [self.movieMainImageView sd_setImageWithURL:[NSURL URLWithString:itemModel.image]];
    self.titleLabel.text = itemModel.name;
}


- (UIImageView *)movieMainImageView {
    if (!_movieMainImageView) {
        _movieMainImageView = [[UIImageView alloc]init];
        _movieMainImageView.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_movieMainImageView];
        
        [_movieMainImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.equalTo(self.contentView).offset(10);
            make.right.equalTo(self.contentView).offset(-10);
            make.bottom.equalTo(self.contentView);
        }];
    }
    return _movieMainImageView;
}

- (UIView *)bottomBgView {
    if (!_bottomBgView) {
        _bottomBgView = [[UIView alloc]init];
        _bottomBgView.backgroundColor = [UIColor blackColor];
        _bottomBgView.alpha = 0.5;
        [self.movieMainImageView addSubview:_bottomBgView];
        
        [_bottomBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.left.right.equalTo(self.movieMainImageView);
            make.height.mas_equalTo(55);
        }];
    }
    return _bottomBgView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = @"wdrqwfwefdq";
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        [self.bottomBgView addSubview:_titleLabel];
        
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.bottomBgView).offset(10);
            make.centerY.equalTo(self.bottomBgView);
        }];
    }
    return _titleLabel;
}

- (UIButton *)addButton {
    if (!_addButton) {
        _addButton = [[UIButton alloc]init];
        [_addButton setImage:[UIImage imageNamed:@"Add_round"] forState:UIControlStateNormal];
        [self.bottomBgView addSubview:_addButton];
        
        [_bottomBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.bottomBgView).offset(-10);
            make.centerY.equalTo(self.bottomBgView);
            make.width.height.mas_equalTo(25);
        }];
    }
    return _addButton;
}

@end
