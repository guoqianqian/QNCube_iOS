//
//  QNRoomMicInfoModel.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/12/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QNMicRoomInfo : NSObject

@property (nonatomic, copy)NSString *roomId;

@property (nonatomic, strong) NSArray *attrs;

@end

@interface QNMicInfo : NSObject

@property (nonatomic, copy)NSString *userExtension;

@property (nonatomic, copy)NSString *uid;

@property (nonatomic, strong) NSArray *attrs;

@property (nonatomic, strong) NSArray *params;

@end

@interface QNRoomMicInfoModel : NSObject

@property (nonatomic, strong) QNMicRoomInfo *roomInfo;

@property (nonatomic, strong) NSArray <QNMicInfo *> *mics;

@end

NS_ASSUME_NONNULL_END
