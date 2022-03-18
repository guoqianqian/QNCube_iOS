//
//  QNAddInterViewInfoModel.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/4/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QNAddInterViewInfoModel : NSObject

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *content;

@property (nonatomic, copy) NSString *placeholder;

@property (nonatomic, assign) BOOL isEdited;//已经编辑过。（用来记录是否手动编辑过面试标题）

@end

NS_ASSUME_NONNULL_END
