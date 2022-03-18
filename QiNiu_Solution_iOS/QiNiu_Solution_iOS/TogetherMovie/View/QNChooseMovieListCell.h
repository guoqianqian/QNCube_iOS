//
//  QNChooseMovieListCell.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/12/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QNMovieListModel;

@interface QNChooseMovieListCell : UICollectionViewCell

- (void)updateWithModel:(QNMovieListModel *)model;

@property (nonatomic,copy)NSString *roomId;

@property (nonatomic, copy) void (^selectBlock)(QNMovieListModel *model);

@end

NS_ASSUME_NONNULL_END
