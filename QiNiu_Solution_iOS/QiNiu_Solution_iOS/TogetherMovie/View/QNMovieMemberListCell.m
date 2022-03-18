//
//  QNMovieMemberListCell.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/12/8.
//

#import "QNMovieMemberListCell.h"
#import "QNRoomDetailModel.h"

@interface QNMovieMemberListCell ()

@property (nonatomic,strong)UIImageView *iconImageView;

@property (nonatomic,strong)UILabel *titleLabel;

@property (nonatomic,strong)UIImageView *selectImageView;

@property (nonatomic,strong) QNUserInfo *model;

@end

@implementation QNMovieMemberListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor blackColor];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(itemClieked)];
        self.contentView.userInteractionEnabled = YES;
        [self.contentView addGestureRecognizer:tap];
        
        [self iconImageView];
        [self titleLabel];
        [self selectImageView];
    }
    return self;
}

- (void)itemClieked {
    if (self.listClickedBlock) {
        self.listClickedBlock(self.model);
    }
    self.selectImageView.hidden = NO;
}

- (void)setItemModel:(QNUserInfo *)itemModel {
    self.model = itemModel;
    [_iconImageView sd_setImageWithURL:[NSURL URLWithString:itemModel.avatar] placeholderImage:[UIImage imageNamed:@"icon_image"]];
    _titleLabel.text = itemModel.nickname;
}

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc]init];
        _iconImageView.clipsToBounds = YES;
        _iconImageView.layer.cornerRadius = 17;
        [self.contentView addSubview:_iconImageView];
        [_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(20);
            make.top.equalTo(self.contentView).offset(5);
            make.width.height.mas_equalTo(34);
        }];
    }
    return _iconImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.numberOfLines = 0;
        [self.contentView addSubview:_titleLabel];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.iconImageView.mas_right).offset(15);
            make.centerY.equalTo(self.iconImageView);
        }];
    }
    return _titleLabel;
}

- (UIImageView *)selectImageView {
    if (!_selectImageView) {
        _selectImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"select"]];
        [self.contentView addSubview:_selectImageView];
        _selectImageView.hidden = YES;
        [_selectImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.iconImageView);
            make.right.equalTo(self.contentView).offset(-20);
        }];
    }
    return _selectImageView;
}


@end
