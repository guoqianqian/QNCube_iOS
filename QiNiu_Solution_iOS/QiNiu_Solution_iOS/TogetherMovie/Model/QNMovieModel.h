//
//  QNMovieModel.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/12/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QNMovieModel : NSObject

@property (nonatomic, copy) NSString *song;

@property (nonatomic, copy) NSString *movieId;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *director;

@property (nonatomic, copy) NSString *image;

@property (nonatomic, copy) NSString *duration;

@property (nonatomic, copy) NSString *playUrl;

@property (nonatomic, copy) NSString *lyrics;

@property (nonatomic, copy) NSString *desc;

@property (nonatomic, copy) NSString *doubanScore;

@property (nonatomic, copy) NSString *imdbScore;

@property (nonatomic, copy) NSString *releaseTime;

@end

NS_ASSUME_NONNULL_END
