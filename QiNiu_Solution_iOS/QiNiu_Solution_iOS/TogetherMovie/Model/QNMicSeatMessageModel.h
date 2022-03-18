//
//  QNMicSeatMessageModel.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/12/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class QNUserMicSeatModel;

@interface QNMicSeatMessageModel : NSObject

@property(nonatomic, copy) NSString *action;

@property(nonatomic, strong) QNUserMicSeatModel *data;

@end

NS_ASSUME_NONNULL_END
