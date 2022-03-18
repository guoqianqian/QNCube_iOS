//
//  QNVoiceChatRoomTitleCell.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2022/1/10.
//

#import "QNVoiceChatRoomTitleCell.h"
#import "QNRoomDetailModel.h"


@interface QNVoiceChatRoomTitleCell ()

@property (nonatomic,strong)UILabel *firstLabel;

@property (nonatomic,strong)UILabel *secondLabel;

@property (nonatomic,strong)UILabel *thirdLabel;

@end

@implementation QNVoiceChatRoomTitleCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupUI];
    }
    return self;
}

- (void)updateWithModel:(NSArray<QNRoomInfo *> *)model {
    
    self.firstLabel.text = [NSString stringWithFormat:@"%@",model[0].title];
    self.secondLabel.text = model.count > 1 ? model[1].title : @"...";
    self.thirdLabel.text = model.count > 2 ? model[2].title : @"...";
}

- (void)setupUI {
    
    self.contentView.backgroundColor = [UIColor colorWithHexString:@"f6f5ec"];
    
    UIView *bgView = [[UIView alloc]init];
    bgView.backgroundColor = [UIColor colorWithHexString:@"F3F3F3"];
    bgView.clipsToBounds = YES;
    bgView.layer.cornerRadius = 15;
    [self.contentView addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.contentView).offset(15);
        make.right.equalTo(self.contentView).offset(-15);
        make.height.mas_equalTo(80);
    }];
    
    UILabel *firstLabel = [self roomTitleLabelWithText:@"..."];
    [bgView addSubview:firstLabel];
    [firstLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(bgView).offset(15);
    }];
    self.firstLabel = firstLabel;
    
    UILabel *secondLabel = [self roomTitleLabelWithText:@"虚位以待"];
    [bgView addSubview:secondLabel];
    [secondLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(bgView).offset(15);
        make.top.equalTo(firstLabel.mas_bottom).offset(5);
    }];
    self.secondLabel = secondLabel;
    
    UILabel *thirdLabel = [self roomTitleLabelWithText:@"虚位以待"];
    [bgView addSubview:thirdLabel];
    [thirdLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(bgView).offset(15);
        make.top.equalTo(secondLabel.mas_bottom).offset(5);
    }];
    self.thirdLabel = thirdLabel;
}

- (UILabel *)roomTitleLabelWithText:(NSString *)text {
    
    UILabel *label = [[UILabel alloc]init];
    label.textColor = [UIColor grayColor];
    label.font = [UIFont systemFontOfSize:14];
    label.text = text;
    
    return label;
}

@end
