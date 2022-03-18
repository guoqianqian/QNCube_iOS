//
//  QNVoiceChatRoomListCell.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2022/1/10.
//

#import "QNVoiceChatRoomListCell.h"
#import "QNRoomDetailModel.h"
#import "QNRTCRoomEntity.h"

@interface QNVoiceChatRoomListCell ()

@property (nonatomic,strong)UIImageView *onLineNumberImageview;

@property (nonatomic,strong)UILabel *onLineNumberLabel;

@property (nonatomic,strong)UIImageView *chatingNumberImageview;

@property (nonatomic,strong)UILabel *chatingNumberLabel;

@property (nonatomic,strong)UIImageView *firstImageView;

@property (nonatomic,strong)UIImageView *secondImageView;

@property (nonatomic,copy) NSString *mainimage;

@property (nonatomic,strong) NSString *secondImage;

@property (nonatomic,strong)UILabel *titleLabel;

@property (nonatomic,strong)UILabel *firstLabel;

@property (nonatomic,strong)UILabel *secondLabel;

@property (nonatomic,strong)UILabel *thirdLabel;

@property (nonatomic,strong)UILabel *fourthLabel;


@end

@implementation QNVoiceChatRoomListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupUI];
    }
    return self;
}

- (void)updateWithModel:(QNRoomInfo *)model {
    
    self.titleLabel.text = model.title;
    
    //获取麦位信息
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"roomId"] = model.roomId;
    params[@"type"] = @"voiceChatRoom";
    
    [QNNetworkUtil getRequestWithAction:@"base/getRoomMicInfo" params:params success:^(NSDictionary *responseData) {
            
        QNRoomDetailModel *detailModel = [QNRoomDetailModel mj_objectWithKeyValues:responseData];
        detailModel.mics = [QNRTCMicsInfo mj_objectArrayWithKeyValuesArray:responseData[@"mics"]];
        
        if (detailModel.mics.count == 0) {
            return;
        }
        NSArray *labelArray = @[self.firstLabel,self.secondLabel,self.thirdLabel,self.fourthLabel];
                
        [detailModel.mics enumerateObjectsUsingBlock:^(QNRTCMicsInfo * _Nonnull mic, NSUInteger idx, BOOL * _Nonnull stop) {
            NSData *JSONData = [mic.userExtension dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableLeaves error:nil];

            QNUserExtension *user = [QNUserExtension mj_objectWithKeyValues:dic];
            UILabel *label = labelArray[idx];
            label.text = user.userExtProfile.name;
            
            NSString *utf8_string = (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,(CFStringRef)user.userExtProfile.avatar,(CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]",NULL,kCFStringEncodingUTF8));
            
            if (idx == 0) {
                self.mainimage = utf8_string;
            } else if (idx == 1){
                self.secondImage = utf8_string;
            }
            
        }];
        
        [self.firstImageView sd_setImageWithURL:[NSURL URLWithString:self.mainimage] ];
        [self.secondImageView sd_setImageWithURL:[NSURL URLWithString:self.secondImage]];
        self.onLineNumberLabel.text = model.totalUsers;
        self.chatingNumberLabel.text = @(detailModel.mics.count).stringValue;
            
        } failure:^(NSError *error) {
            
        }];
    
}

- (void)setupUI {
    
    
    self.contentView.backgroundColor = [UIColor colorWithHexString:@"f6f5ec"];
    
    UIView *bgView = [[UIView alloc]init];
    bgView.backgroundColor = [UIColor whiteColor];
    bgView.clipsToBounds = YES;
    bgView.layer.cornerRadius = 15;
    [self.contentView addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.contentView).offset(15);
        make.right.equalTo(self.contentView).offset(-15);
        make.height.mas_equalTo(160);
    }];
    
    UILabel *titleLabel = [self roomTitleLabelWithText:@"交友群"];
    [bgView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(bgView).offset(15);
    }];
    self.titleLabel = titleLabel;
    
    UIImageView *firstImageView = [[UIImageView alloc]init];
    firstImageView.backgroundColor = [UIColor lightGrayColor];
    firstImageView.clipsToBounds = YES;
    firstImageView.layer.cornerRadius = 15;
    [bgView addSubview:firstImageView];
    [firstImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(titleLabel.mas_left);
        make.top.equalTo(titleLabel.mas_bottom).offset(8);
        make.width.height.mas_equalTo(45);
    }];
    
    UIImageView *secondImageView = [[UIImageView alloc]init];
    secondImageView.backgroundColor = [UIColor lightGrayColor];
    secondImageView.clipsToBounds = YES;
    secondImageView.layer.cornerRadius = 15;
    [bgView addSubview:secondImageView];
    [secondImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(firstImageView.mas_left).offset(22);
        make.top.equalTo(firstImageView.mas_top).offset(22);
        make.width.height.mas_equalTo(45);
    }];
    
    UILabel *firstLabel = [self roomTitleLabelWithText:@"虚位以待..."];
    [bgView addSubview:firstLabel];
    [firstLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(firstImageView);
        make.left.equalTo(secondImageView.mas_right).offset(10);
    }];
    self.firstLabel = firstLabel;
    
    UILabel *secondLabel = [self roomTitleLabelWithText:@"虚位以待..."];
    [bgView addSubview:secondLabel];
    [secondLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(firstLabel);
        make.top.equalTo(firstLabel.mas_bottom).offset(5);
    }];
    self.secondLabel = secondLabel;
    
    UILabel *thirdLabel = [self roomTitleLabelWithText:@"虚位以待..."];
    [bgView addSubview:thirdLabel];
    [thirdLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(firstLabel);
        make.top.equalTo(secondLabel.mas_bottom).offset(5);
    }];
    self.thirdLabel = thirdLabel;
    
    UILabel *fourthLabel = [self roomTitleLabelWithText:@"虚位以待..."];
    [bgView addSubview:fourthLabel];
    [fourthLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(firstLabel);
        make.top.equalTo(thirdLabel.mas_bottom).offset(5);
    }];
    self.fourthLabel = fourthLabel;
    
    self.onLineNumberLabel = [self onlineLabel];
    self.onLineNumberLabel.text = @"19";
    [bgView addSubview:self.onLineNumberLabel];
    [self.onLineNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(firstLabel);
        make.top.equalTo(fourthLabel.mas_bottom).offset(5);
    }];
    
    self.onLineNumberImageview = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_user"]];
    [bgView addSubview:self.onLineNumberImageview];
    [self.onLineNumberImageview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.onLineNumberLabel.mas_right).offset(5);
        make.top.equalTo(self.onLineNumberLabel);
        make.width.height.mas_equalTo(15);
    }];
    
    self.chatingNumberLabel = [self onlineLabel];
    self.chatingNumberLabel.text = @"3";
    [bgView addSubview:self.chatingNumberLabel];
    [self.chatingNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.onLineNumberImageview.mas_right).offset(10);
        make.top.equalTo(self.onLineNumberLabel);        
    }];
    
    self.onLineNumberImageview = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"record"]];
    [bgView addSubview:self.onLineNumberImageview];
    [self.onLineNumberImageview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.chatingNumberLabel.mas_right).offset(5);
        make.top.equalTo(self.onLineNumberLabel);
        make.width.height.mas_equalTo(15);
    }];
    
}

- (UILabel *)roomTitleLabelWithText:(NSString *)text {
    
    UILabel *label = [[UILabel alloc]init];
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:15];
    label.text = text;
    
    return label;
}

- (UILabel *)onlineLabel {
    
    UILabel *label = [[UILabel alloc]init];
    label.textColor = [UIColor lightGrayColor];
    label.font = [UIFont systemFontOfSize:14];
    
    return label;
}
@end
