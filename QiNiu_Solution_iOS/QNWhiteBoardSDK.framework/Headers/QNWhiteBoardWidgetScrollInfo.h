//
//  QNWhiteBoardWidgetScrollInfo.h
//  QNWhiteBoardSDK
//
//  Created by 郭茜 on 2021/7/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QNWhiteBoardWidgetScrollInfo : NSObject

@property (nonatomic,nonnull) NSString * widgetId;
@property (nonatomic,assign) NSInteger scrollToTop;
@property (nonatomic,assign) NSInteger scrollToBottom;


-(instancetype)initWithDictionary:(NSDictionary *)dict_;

@end

NS_ASSUME_NONNULL_END
