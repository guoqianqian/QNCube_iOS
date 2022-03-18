//
//  QNMovieTogetherChannelModel.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/12/8.
//

#import <Foundation/Foundation.h>
#import "QNMovieListModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface QNMovieTogetherChannelModel : NSObject
//当前播放进度
@property (nonatomic, assign) long long currentPosition;
//当前进度对应的时间戳
@property (nonatomic, assign) long long currentTimeMillis;
//当前电影实体 （服务器端定义的结构）
@property (nonatomic, strong) QNMovieListModel *movieInfo;
//电影ID
@property (nonatomic, copy) NSString *videoId;
//电影控制者ID
@property (nonatomic, copy) NSString *videoUid;
//开始播放的时间戳
@property (nonatomic, assign) long long startTimeMillis;
//播放状态 0 暂停 1 播放 2 出错
@property (nonatomic, assign) NSInteger playStatus;

@end

NS_ASSUME_NONNULL_END
