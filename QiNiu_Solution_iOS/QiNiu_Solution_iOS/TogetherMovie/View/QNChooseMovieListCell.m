//
//  QNChooseMovieListCell.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/12/12.
//

#import "QNChooseMovieListCell.h"
#import "QNMovieListModel.h"

@interface QNChooseMovieListCell ()

@property (nonatomic, strong) UIImageView *mainImageView;

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UIView *bottomBgView;

@property (nonatomic, strong) UILabel *numLabel;

@property (nonatomic, strong) UIImageView *selectImageView;

@property (nonatomic, strong) QNMovieListModel *model;

@end

@implementation QNChooseMovieListCell

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        [self mainImageView];
        [self bottomBgView];
        [self nameLabel];
        [self numLabel];
        
    }
    return self;
}

- (void)updateWithModel:(QNMovieListModel *)model {
    self.model = model;
    [self.mainImageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:[UIImage imageNamed:@"titleImage"]];
    self.nameLabel.text = model.name;
    self.numLabel.text = @"03:35";
}

- (void)selectedMovie {
        
    self.selectImageView.hidden = !self.selectImageView.hidden;
    self.numLabel.hidden = !self.selectImageView.hidden;
    self.model.isSelected = !self.selectImageView.hidden;
    
    if (self.selectBlock) {
        self.selectBlock(self.model);
    }
    if (self.model.isSelected) {
        [self movieOperation:@"select"];
    } else {
        [self movieOperation:@"delete"];
    }
    
}

- (void)movieOperation:(NSString *)operation {
    
    NSMutableDictionary *requestParams = [NSMutableDictionary dictionary];
    requestParams[@"roomId"] = self.roomId;
    requestParams[@"movieId"] = self.model.movieId;
    requestParams[@"operateType"] = operation;
    
    
    [QNNetworkUtil postRequestWithAction:@"watchMoviesTogether/movieOperation" params:requestParams success:^(NSDictionary *responseData) {
           
        } failure:^(NSError *error) {
        }];
}

- (UIImageView *)mainImageView {
    if (!_mainImageView) {
        _mainImageView = [[UIImageView alloc]init];
        _mainImageView.clipsToBounds = YES;
        _mainImageView.layer.cornerRadius = 15;
        [self.contentView addSubview:_mainImageView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selectedMovie)];
        _mainImageView.userInteractionEnabled = YES;
        [_mainImageView addGestureRecognizer:tap];
        
        [_mainImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.equalTo(self.contentView).offset(5);
            make.right.bottom.equalTo(self.contentView).offset(5);
        }];
    }
    return _mainImageView;
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

- (UIView *)bottomBgView {
    if (!_bottomBgView) {
        _bottomBgView = [[UIView alloc]init];
        _bottomBgView.backgroundColor = [UIColor blackColor];
        _bottomBgView.alpha = 0.5;
        [self.contentView addSubview:_bottomBgView];
        
        [_bottomBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.left.right.equalTo(self.mainImageView);
            make.height.mas_equalTo(35);
        }];
    }
    return _bottomBgView;
}

- (UIImageView *)selectImageView {
    if (!_selectImageView) {
        _selectImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"select"]];
        [self.contentView addSubview:_selectImageView];
        _selectImageView.hidden = YES;
        [_selectImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.numLabel);
            make.right.equalTo(self.contentView).offset(-20);
        }];
    }
    return _selectImageView;
}



@end
