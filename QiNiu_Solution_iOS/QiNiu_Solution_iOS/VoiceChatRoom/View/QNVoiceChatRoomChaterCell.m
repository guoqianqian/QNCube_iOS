//
//  QNVoiceChatRoomChaterCell.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2022/1/10.
//

#import "QNVoiceChatRoomChaterCell.h"
#import "QNVoiceChaterView.h"
#import "NSArray+Sudoku.h"
#import "QNRTCRoomEntity.h"

@implementation QNVoiceChatRoomChaterCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
    }
    return self;
}

- (void)setOnMicUserList:(NSArray <QNRTCMicsInfo *>*)onMicUserList {
    
    if (onMicUserList.count == 0 ) {
        return;
    }
    
    [self.contentView removeAllSubviews];
    
    UIView *bottomButtonView = [[UIView alloc] init];
    [self.contentView addSubview:bottomButtonView];
    [bottomButtonView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(self.contentView);
    }];
    
    CGFloat buttonWidth = 100;
    NSInteger space = (kScreenWidth - buttonWidth * 3)/4;
    
    for (int i = 0; i < onMicUserList.count; i ++) {
        
        NSData *JSONData = [onMicUserList[i].userExtension dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableLeaves error:nil];

        QNUserExtension *user = [QNUserExtension mj_objectWithKeyValues:dic];
        
        QNVoiceChaterView *view = [[QNVoiceChaterView alloc] init];
        [view.mainImageView sd_setImageWithURL:[NSURL URLWithString:user.userExtProfile.avatar]];
        view.nameLabel.text = user.userExtProfile.name;
        [bottomButtonView addSubview:view];
    }
    
    // 九宫格布局
    [bottomButtonView.subviews mas_distributeSudokuViewsWithFixedItemWidth:buttonWidth fixedItemHeight:buttonWidth fixedLineSpacing:space fixedInteritemSpacing:space warpCount:3 topSpacing:15 bottomSpacing:15 leadSpacing:space tailSpacing:space];
}


@end
