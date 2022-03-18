//
//  QNChatTextModel.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/10/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QNChatTextInfoModel : NSObject

@property (nonatomic, copy) NSString *msgContent;

@property (nonatomic, copy) NSString *senderId;

@property (nonatomic, copy) NSString *senderName;

@end

@interface QNChatTextModel : NSObject

@property (nonatomic, copy) NSString *action;

@property (nonatomic, strong) QNChatTextInfoModel *data;


@end

NS_ASSUME_NONNULL_END
