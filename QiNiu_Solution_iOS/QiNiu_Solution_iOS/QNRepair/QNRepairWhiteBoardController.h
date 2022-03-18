//
//  QNWhiteBoardDemoController.h
//  QNWhiteBoardDemo
//
//  Created by 郭茜 on 2021/5/13.
//

#import <UIKit/UIKit.h>

#import <QNWhiteBoardSDK/QNWhiteBoardViewController.h>
#import "QNRepairListModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface QNRepairWhiteBoardController : QNWhiteBoardViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (nonatomic, copy) NSString *roomToken;

@property (nonatomic, assign) QNRepairRoleType roleType;

@property (nonatomic, assign) CGFloat aspectRatio;
@end

NS_ASSUME_NONNULL_END
