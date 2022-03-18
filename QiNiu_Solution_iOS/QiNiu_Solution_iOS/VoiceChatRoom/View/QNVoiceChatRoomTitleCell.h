//
//  QNVoiceChatRoomTitleCell.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2022/1/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QNRoomDetailModel,QNRoomInfo;

@interface QNVoiceChatRoomTitleCell : UITableViewCell

- (void)updateWithModel:(NSArray <QNRoomInfo *> *)model;

@end

NS_ASSUME_NONNULL_END
