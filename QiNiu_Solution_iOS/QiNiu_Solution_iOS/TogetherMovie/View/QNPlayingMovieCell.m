//
//  QNPlayingMovieCell.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/12/7.
//

#import "QNPlayingMovieCell.h"
#import "QNMovieListModel.h"

@interface QNPlayingMovieCell ()

@property (nonatomic,strong)UIImageView *MovieImageView;

@property (nonatomic,strong)UILabel *timeLabel;

@property (nonatomic,strong)UIImageView *playingImageView;

@property (nonatomic,strong)UILabel *titleLabel;

@property (nonatomic,strong)UIImageView *rightPlayImageView;

@property (nonatomic, strong) QNMovieListModel *model;


@end

@implementation QNPlayingMovieCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor blackColor];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selectedClick)];
        self.contentView.userInteractionEnabled = YES;
        [self.contentView addGestureRecognizer:tap];
        
        [self MovieImageView];
//        [self timeLabel];
        [self playingImageView];
        [self titleLabel];
        [self rightPlayImageView];
    }
    return self;
}

- (void)setItemModel:(QNMovieListModel *)itemModel {
    self.model = itemModel;
    [self.MovieImageView sd_setImageWithURL:[NSURL URLWithString:itemModel.image]];
    self.titleLabel.text = itemModel.name;
    self.playingImageView.hidden = !itemModel.isPlaying;
    self.rightPlayImageView.hidden = !itemModel.isPlaying;
}

- (void)selectedClick {
    if (self.selectBlock) {
        self.selectBlock(self.model);
    }
}

- (UIImageView *)MovieImageView {
    if (!_MovieImageView) {
        _MovieImageView = [[UIImageView alloc]init];
        [self.contentView addSubview:_MovieImageView];
        [_MovieImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(15);
            make.top.equalTo(self.contentView).offset(5);
            make.width.mas_equalTo(kScreenWidth/2.5);
            make.height.mas_equalTo(kScreenWidth/4);
        }];
    }
    return _MovieImageView;
}

- (UIImageView *)playingImageView {
    if (!_playingImageView) {
        _playingImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"movie_Playing"]];
        _playingImageView.hidden = YES;
        [self.MovieImageView addSubview:_playingImageView];
        [_playingImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.MovieImageView);
        }];
    }
    return _playingImageView;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc]init];
        _timeLabel.text = @"03:35";
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        [self.MovieImageView addSubview:_timeLabel];
        [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.MovieImageView).offset(-10);
            make.bottom.equalTo(self.MovieImageView).offset(-5);
        }];
    }
    return _timeLabel;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.text = @"牛小七绝情谷归来";
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.numberOfLines = 0;
        [self.contentView addSubview:_titleLabel];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.MovieImageView.mas_right).offset(15);
            make.right.equalTo(self.contentView).offset(-50);
            make.centerY.equalTo(self.MovieImageView);
        }];
    }
    return _titleLabel;
}

- (UIImageView *)rightPlayImageView {
    if (!_rightPlayImageView) {
        _rightPlayImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"playing"]];
        [self.MovieImageView addSubview:_rightPlayImageView];
        _rightPlayImageView.hidden = YES;
        [_rightPlayImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.MovieImageView);
            make.right.equalTo(self.contentView).offset(-15);
        }];
    }
    return _rightPlayImageView;
}

@end
