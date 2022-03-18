//
//  QNMovieOnlineView.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/12/3.
//

#import "QNMovieOnlineView.h"
#import <SDWebImage/SDWebImage.h>
#import <Masonry/Masonry.h>
#import "MBProgressHUD+QNShow.h"
#import "QNRoomDetailModel.h"

@interface QNMovieOnlineView ()

@property (nonatomic,strong) UIImageView *onlinePointImageView;

@property (nonatomic,strong) UILabel *onlineNumLabel;

@property (nonatomic,strong) UILabel *movieListLabel;

@property (nonatomic,strong) UIImageView *iconImageView;

@property (nonatomic,strong) UIButton *inviteButton;

@property (nonatomic,strong) UIButton *cancelInviteButton;
@property (nonatomic,strong) QNRoomDetailModel *roomModel;

@end

@implementation QNMovieOnlineView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        UIImageView *bg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"movie_online_BgView"]];
        [self addSubview:bg];
        [bg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.bottom.equalTo(self);
        }];
        
        [self onlinePointImageView];
        [self onlineNumLabel];
        [self movieListLabel];
        [self iconImageView];
        [self inviteButton];
        [self cancelInviteButton];
    }
    return self;
}

- (void)setModel:(QNRoomDetailModel *)model {
    self.roomModel = model;
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:model.userInfo.avatar] placeholderImage:[UIImage imageNamed:@"icon_image"]];
    self.onlineNumLabel.text = [NSString stringWithFormat:@"%ld人在线",model.allUserList.count];
}

- (void)inviteButtonClicked {

    for (QNAttrsModel *attr in self.roomModel.roomInfo.params) {
        if ([attr.key isEqualToString:@"invitationCode"]) {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = attr.value;
            [MBProgressHUD showText:[NSString stringWithFormat:@"复制邀请码%@成功",attr.value]];
        }
    }
        
}

- (void)PlayListClick {
    if (self.playListBlock) {
        self.playListBlock();
    }
}

- (UIImageView *)onlinePointImageView {
    if (!_onlinePointImageView) {
        _onlinePointImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"onLine_point"]];
        [self addSubview:_onlinePointImageView];
        
        [_onlinePointImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.equalTo(self).offset(20);
        }];
    }
    return _onlinePointImageView;
}

- (UILabel *)onlineNumLabel {
    if (!_onlineNumLabel) {
        _onlineNumLabel = [[UILabel alloc]init];
        _onlineNumLabel.text = @"1人在线";
        _onlineNumLabel.font = [UIFont systemFontOfSize:12];
        _onlineNumLabel.textColor = [UIColor lightTextColor];
        [self addSubview:_onlineNumLabel];
        
        [_onlineNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.onlinePointImageView);
            make.left.equalTo(self.onlinePointImageView.mas_right).offset(8);
        }];
    }
    return _onlineNumLabel;
}

- (UILabel *)movieListLabel {
    if (!_movieListLabel) {
        _movieListLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _movieListLabel.text = @"播放列表 >";
        _movieListLabel.textColor = [UIColor lightTextColor];
        _movieListLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:_movieListLabel];
        
        _movieListLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(PlayListClick)];
        [self.movieListLabel addGestureRecognizer:tap];
        
        [_movieListLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.onlinePointImageView);
            make.right.equalTo(self).offset(-20);
        }];
    }
    return _movieListLabel;
}

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_image"]];
        _iconImageView.layer.cornerRadius = 15;
        _iconImageView.clipsToBounds = YES;
        [self addSubview:_iconImageView];
        [_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.onlineNumLabel.mas_bottom).offset(10);
            make.left.equalTo(self).offset(25);
            make.width.height.mas_equalTo(30);
        }];
    }
    return _iconImageView;
}

- (UIButton *)cancelInviteButton {
    if (!_cancelInviteButton) {
        _cancelInviteButton = [[UIButton alloc]init];
        [_cancelInviteButton setImage:[UIImage imageNamed:@"cancelInvite"] forState:UIControlStateNormal];
        [self addSubview:_cancelInviteButton];
        [_cancelInviteButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-20);
            make.centerY.equalTo(self.iconImageView);
        }];
    }
    return _cancelInviteButton;
}

-(UIButton *)inviteButton {
    if (!_inviteButton) {
        _inviteButton = [[UIButton alloc]init];
        [_inviteButton setImage:[UIImage imageNamed:@"inviteMember"] forState:UIControlStateNormal];
        [self addSubview:_inviteButton];
        [_inviteButton addTarget:self action:@selector(inviteButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [_inviteButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.cancelInviteButton.mas_left).offset(-8);
            make.centerY.equalTo(self.iconImageView);
        }];
    }
    return _inviteButton;
}
@end
