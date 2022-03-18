//
//  QNVoiceChatRoomCell.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2022/3/16.
//

#import <UIKit/UIKit.h>
#import "QNRoomDetailModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface QNVoiceChatRoomCell : UICollectionViewCell

@property (nonatomic, copy) void (^onSeatBlock)(void);

- (void)updateWithModel:(QNRTCMicsInfo *)model;

@end

NS_ASSUME_NONNULL_END
