//
//  QNWhiteBoardInfo.h
//  QNWhiteBoardSDK
//
//  Created by 郭茜 on 2021/5/13.
//

#import <Foundation/Foundation.h>
#import "QNWhiteBoardDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface QNWhiteBoardInfo : NSObject

@property (nonatomic,assign) QNWBBoardStatus status;
@property (nonatomic,assign) float maxWidth;
@property (nonatomic,assign) float maxHeight;
@property (nonatomic,assign) float displayWidth;
@property (nonatomic,assign) float displayHeight;
@property (nonatomic,assign) float xOffset;
@property (nonatomic,assign) float yOffset;
@property (nonatomic,retain) NSString * backgroundColor;

-(instancetype)initWithDictionary:(NSDictionary *)params_;

@end

NS_ASSUME_NONNULL_END
