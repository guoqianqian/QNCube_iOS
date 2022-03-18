//
//  QNApplyOnSeatView.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/11/8.
//

#import "QNApplyOnSeatView.h"
#import <Masonry/Masonry.h>

@interface QNApplyOnSeatView ()

@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, strong) UIImageView *avatarView;

@property (nonatomic, strong) UIView *line;

@property (nonatomic, strong) UIView *line2;

@property (nonatomic, strong) UILabel *label;
@end

@implementation QNApplyOnSeatView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
                
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(35, 60, 50, 1)];
        line.backgroundColor = [UIColor whiteColor];
        [self addSubview:line];
        self.line = line;
        
        UIView *line2 = [[UIView alloc]initWithFrame:CGRectMake(60, 35, 1, 50)];
        line2.backgroundColor = [UIColor whiteColor];
        [self addSubview:line2];
        self.line2 = line2;
        
        UILabel *label = [[UILabel alloc]init];
        label.text = @"等待连麦";
        label.font = [UIFont systemFontOfSize:12];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(line2.mas_bottom).offset(5);
            make.centerX.equalTo(line2);
        }];
        
        self.label = label;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickOnSeat)];
        self.userInteractionEnabled = YES;
        
        [self addGestureRecognizer:tap];

    }
    return self;
}

- (void)setIsSeat:(BOOL)isSeat {
    self.label.hidden = isSeat;
    self.line.hidden = isSeat;
    self.line2.hidden = isSeat;
    self.alpha = isSeat ? 1 : 0.5;
    
    if (!isSeat) {
        self.userId = @"";
    }
   
}

- (void)setImageName:(NSString *)imageName {
    self.label.hidden = YES;
    self.line.hidden = YES;
    self.line2.hidden = YES;
    
    [_avatarView sd_setImageWithURL:[NSURL URLWithString:imageName]];
}


- (void)clickOnSeat {
    if (self.onSeatBlock) {
        self.onSeatBlock(self.tagIndex);
    }
}

- (UIImageView *)avatarView {
    if (!_avatarView) {
        _avatarView = [[UIImageView alloc]initWithFrame:self.frame];
        [self addSubview:_avatarView];
    }
    return _avatarView;
}

@end
