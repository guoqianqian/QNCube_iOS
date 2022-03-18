//
//  QNVoiceChatRoomCell.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2022/3/16.
//

#import "QNVoiceChatRoomCell.h"

@interface QNVoiceChatRoomCell ()
@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, strong) UIImageView *avatarView;

@property (nonatomic, strong) UIView *line;

@property (nonatomic, strong) UIView *line2;

@property (nonatomic, strong) UILabel *label;
@end

@implementation QNVoiceChatRoomCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.contentView setBackgroundColor:[UIColor blackColor]];
        
        self.contentView.alpha = 0.3;
        
        UIView *line = [[UIView alloc]initWithFrame:CGRectZero];
        line.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:line];
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.contentView);
            make.height.mas_equalTo(1);
            make.width.mas_equalTo(50);
        }];
        self.line = line;
        
        UIView *line2 = [[UIView alloc]initWithFrame:CGRectZero];
        line2.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:line2];
        [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.contentView);
            make.height.mas_equalTo(50);
            make.width.mas_equalTo(1);
        }];
        self.line2 = line2;
        
        UILabel *label = [[UILabel alloc]init];
        label.text = @"等待连麦";
        label.font = [UIFont systemFontOfSize:12];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:label];
        
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(line2.mas_bottom).offset(5);
            make.centerX.equalTo(line2);
        }];
        
        self.label = label;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickOnSeat)];
        self.userInteractionEnabled = YES;
        
        [self.contentView addGestureRecognizer:tap];

    }
    return self;
}

- (void)updateWithModel:(QNRTCMicsInfo *)model {
    
//    if (model.userExtension.length == 0) {
//        
//    }
    
    NSData *JSONData = [model.userExtension dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableLeaves error:nil];

    QNUserExtension *user = [QNUserExtension mj_objectWithKeyValues:dic];
    [self.avatarView sd_setImageWithURL:[NSURL URLWithString:user.userExtProfile.avatar]];
    
}

- (UIImageView *)avatarView {
    if (!_avatarView) {
        _avatarView = [[UIImageView alloc]initWithFrame:self.frame];
        [self addSubview:_avatarView];
        [self bringSubviewToFront:self.avatarView];
    }
    return _avatarView;
}

- (void)clickOnSeat {
    if (self.onSeatBlock) {
        self.onSeatBlock();
    }
}
@end
