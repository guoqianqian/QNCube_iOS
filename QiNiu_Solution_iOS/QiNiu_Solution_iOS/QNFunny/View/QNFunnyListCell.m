//
//  QNFunnyListCell.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/11/2.
//

#import "QNFunnyListCell.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/SDWebImage.h>
#import "QNRoomDetailModel.h"

@interface QNFunnyListCell ()

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UILabel *numLabel;

@end

@implementation QNFunnyListCell

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        [self imageView];
        [self nameLabel];
        [self numLabel];
        
    }
    return self;
}

- (void)updateWithModel:(QNRoomInfo *)model {
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:model.image]];
    self.imageView.image = [UIImage imageNamed:@"titleImage"];
    self.nameLabel.text = model.title;
    self.numLabel.text = model.totalUsers;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc]init];
        [self.contentView addSubview:_imageView];
        
        [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.equalTo(self.contentView).offset(5);
            make.right.bottom.equalTo(self.contentView).offset(5);
        }];
    }
    return _imageView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc]init];
        _nameLabel.text = @"ssfdf";
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.font = [UIFont systemFontOfSize:13];
        [self.contentView addSubview:_nameLabel];
        
        [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(10);
            make.bottom.equalTo(self.contentView).offset(-10);
        }];
    }
    return _nameLabel;
}

- (UILabel *)numLabel {
    if (!_numLabel) {
        _numLabel = [[UILabel alloc]init];
        _numLabel.text = @"123";
        _numLabel.textColor = [UIColor whiteColor];
        _numLabel.font = [UIFont systemFontOfSize:13];
        [self.contentView addSubview:_numLabel];
        
        [_numLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(-10);
            make.bottom.equalTo(self.contentView).offset(-10);
        }];
    }
    return _numLabel;
}

@end
