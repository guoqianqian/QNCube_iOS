//
//  QNMovieMemberListController.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/12/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QNUserInfo,QNRoomDetailModel;

@interface QNMovieMemberListController : UIViewController

@property (nonatomic, copy) NSArray<QNUserInfo *> *allUserList;

@property (nonatomic, copy) void (^invitationClickedBlock)(QNUserInfo *itemModel);

@end

NS_ASSUME_NONNULL_END
