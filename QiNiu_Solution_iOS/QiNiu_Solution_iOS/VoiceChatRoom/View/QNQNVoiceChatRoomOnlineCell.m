//
//  QNVoiceOnlineCell.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2022/1/10.
//

#import "QNQNVoiceChatRoomOnlineCell.h"
#import "QNVoiceChaterView.h"
#import "NSArray+Sudoku.h"

@implementation QNQNVoiceChatRoomOnlineCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    }
    return self;
}

- (void)setAllUserList:(NSMutableArray<QNUserInfo *> *)allUserList {
    
    if (allUserList.count == 0) {
        return;
    }
    
    [self.contentView removeAllSubviews];
    
    UIView *bottomButtonView = [[UIView alloc] init];
    [self.contentView addSubview:bottomButtonView];
    [bottomButtonView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(self.contentView);
    }];
    
    CGFloat buttonWidth = 85;
    NSInteger space = (kScreenWidth - buttonWidth * 4)/5;
    
    for (int i = 0; i < allUserList.count; i ++) {
        QNVoiceChaterView *view = [[QNVoiceChaterView alloc] init];
        [view.mainImageView sd_setImageWithURL:[NSURL URLWithString:allUserList[i].avatar]];
        view.nameLabel.text = allUserList[i].nickname;
        [bottomButtonView addSubview:view];
    }
    
    // 九宫格布局
    [bottomButtonView.subviews mas_distributeSudokuViewsWithFixedItemWidth:buttonWidth fixedItemHeight:buttonWidth fixedLineSpacing:space fixedInteritemSpacing:space warpCount:4 topSpacing:15 bottomSpacing:15 leadSpacing:space+10 tailSpacing:space+10];
    
}


@end
