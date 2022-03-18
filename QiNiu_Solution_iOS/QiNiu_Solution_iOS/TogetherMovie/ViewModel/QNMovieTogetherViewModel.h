//
//  QNMovieTogetherViewModel.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/12/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QNMovieTogetherViewModel : NSObject
//建立转推任务
+ (void)requestCreateTrackWithParams:(NSDictionary *)params success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure;
//列出转推任务
+ (void)requestGetTrackWithParams:(NSDictionary *)params success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure ;
//删除转推任务
+ (void)requestDeleteTrackWithParams:(NSDictionary *)params success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure ;
//开始转推
+ (void)requestStartTrackWithParams:(NSDictionary *)params success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure;
//停止转推
+ (void)requestStopTrackWithParams:(NSDictionary *)params success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure ;
//设置Seek
+ (void)requestSeekWithParams:(NSDictionary *)params success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure;
@end

NS_ASSUME_NONNULL_END
