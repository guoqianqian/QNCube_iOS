//
//  QNWhiteBoardRoom.h
//  QNWhiteBoardSDK
//
//  Created by 郭茜 on 2021/5/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/**
 * 房间数据
 */
@interface QNWhiteBoardRoom : NSObject
/**
 * 聊天室id
 */
@property (nonatomic,assign) NSInteger chatRoomId;

/**
 * 房间id
 */
@property (nonatomic,retain) NSString * roomId;

/**
* 房间云盘id
*/
@property (nonatomic,retain) NSString * fileGroupId;

-(instancetype)initWithParams:(NSInteger)chatId_ room:(NSString *)roomId_ fileGroup:(NSString *)fileGroupId_;

@end

NS_ASSUME_NONNULL_END
