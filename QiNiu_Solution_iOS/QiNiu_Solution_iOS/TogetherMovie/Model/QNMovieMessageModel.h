//
//  QNMovieMessageModel.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/12/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class QNMovieTogetherChannelModel;

@interface QNMovieMessageModel : NSObject

@property(nonatomic, copy) NSString *action;

@property(nonatomic, strong) QNMovieTogetherChannelModel *data;

@end

NS_ASSUME_NONNULL_END
