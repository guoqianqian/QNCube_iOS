//
//  QNMovieRoomListCell.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/12/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QNRoomDetailModel,QNRoomInfo;

@interface QNMovieRoomListCell : UICollectionViewCell

- (void)updateWithModel:(QNRoomInfo *)model;


@end

NS_ASSUME_NONNULL_END
