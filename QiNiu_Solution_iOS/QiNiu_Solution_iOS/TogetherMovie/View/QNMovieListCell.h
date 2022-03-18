//
//  QNMovieListCell.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/11/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class QNMovieListModel;
@interface QNMovieListCell : UITableViewCell

@property (nonatomic, strong) QNMovieListModel *itemModel;

@end

NS_ASSUME_NONNULL_END
