//
//  QNWhiteBoardJoinInfo.h
//  QNWhiteBoardSDK
//
//  Created by 郭茜 on 2021/5/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QNWhiteBoardJoinInfo : NSObject
/**
* 应用id
*/
@property (nonatomic, copy) NSString * appId;
@property (nonatomic, copy) NSString * roomId;
@property (nonatomic, copy) NSString * userId;
@property (nonatomic, copy) NSString * token;

-(instancetype)initWithParam:(NSString *)appId_ room:(NSString *)roomId_ user:(NSString *)userId_ token:(NSString *)token_;

-(NSDictionary *)toDictionary;

@end

NS_ASSUME_NONNULL_END
