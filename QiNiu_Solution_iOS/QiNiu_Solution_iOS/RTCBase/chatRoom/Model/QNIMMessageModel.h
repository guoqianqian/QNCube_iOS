//
//  QNIMMessageModel.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/4/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QNIMMessageStrModel : NSObject

@property(nonatomic, strong) NSString *senderId;

@property(nonatomic, strong) NSString *senderName;

@property(nonatomic, strong) NSString *msgContent;

@property(nonatomic, strong) NSString *sendAvatar;



@property (nonatomic, copy) NSString *key;

@property (nonatomic, copy) NSString *value;

@property (nonatomic, copy) NSString *roomId;

@end

@interface QNIMMessageModel : NSObject

@property(nonatomic, copy) NSString *action;

@property(nonatomic, strong) QNIMMessageStrModel *data;

@end

NS_ASSUME_NONNULL_END
