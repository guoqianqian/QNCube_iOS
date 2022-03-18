//
//  QNPlayMovieListController.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/12/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QNMovieListModel;

@interface QNPlayMovieListController : UIViewController

@property (nonatomic,copy)NSString *roomId;

@property (nonatomic, copy) void (^listClickedBlock)(QNMovieListModel *movie);

@end

NS_ASSUME_NONNULL_END
