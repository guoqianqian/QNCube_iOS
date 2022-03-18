//
//  QNWhiteBoardPageInfo.h
//  QNWhiteBoardSDK
//
//  Created by 郭茜 on 2021/5/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QNWhiteBoardPageInfo : NSObject
/**
 * 页id
 */
@property (nonatomic,retain,nonnull) NSString * pageId;
/**
 * 页号
 */
@property (nonatomic,assign) unsigned long pageNumber;
/**
 * 白板缩略图，没有时为空字符串
 */
@property (nonatomic,retain) NSString * thumbUrl;

@property (nonatomic,retain) NSString * backgroundColor;

@property (nonatomic,assign) unsigned long lastUpdateTime;


-(instancetype)initFromDictonary:(NSDictionary *)params_;

-(NSString *)getThumbnailUrl;

@end

NS_ASSUME_NONNULL_END
