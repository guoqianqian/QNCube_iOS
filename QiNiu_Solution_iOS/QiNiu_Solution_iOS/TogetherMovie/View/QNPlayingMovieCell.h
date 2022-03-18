//
//  QNPlayingMovieCell.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/12/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QNMovieListModel;

@interface QNPlayingMovieCell : UITableViewCell

@property (nonatomic, strong) QNMovieListModel *itemModel;

@property (nonatomic, copy) void (^selectBlock)(QNMovieListModel *model);


@end

NS_ASSUME_NONNULL_END
