//
//  QNMovieListModel.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/12/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QNMovieListModel : NSObject

@property (nonatomic, copy) NSString *movieId;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *director;

@property (nonatomic, copy) NSString *image;

@property (nonatomic, copy) NSString *actorList;

@property (nonatomic, copy) NSString *kindList;

@property (nonatomic, copy) NSString *lyrics;

@property (nonatomic, copy) NSString *playUrl;

@property (nonatomic, copy) NSString *duration;

@property (nonatomic, copy) NSString *desc;

@property (nonatomic, copy) NSString *doubanScore;

@property (nonatomic, copy) NSString *imdbScore;

@property (nonatomic, copy) NSString *releaseTime;

@property (nonatomic, assign) BOOL isSelected;//是否被选中

@property (nonatomic, assign) BOOL isPlaying;//是否正在播放

@end

NS_ASSUME_NONNULL_END
