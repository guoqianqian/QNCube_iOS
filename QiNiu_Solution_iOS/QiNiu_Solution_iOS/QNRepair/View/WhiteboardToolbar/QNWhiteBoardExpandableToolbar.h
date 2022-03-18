//
//  LATExpanableToolbar.h
//  WhiteboardTest
//
//  Created by mac zhang on 2021/5/16.
//

#import <UIKit/UIKit.h>
#import "QNWhiteBoardToolbarDelegate.h"



NS_ASSUME_NONNULL_BEGIN

@interface QNWhiteBoardExpandableToolbar : UIStackView <QNWhiteBoardToolbarDelegate>

@property (nonatomic,weak) id<QNWhiteboardUIDelegate> uiDelegate;

-(void)addConstraintToParent:(UIView *)parent_;

@end

NS_ASSUME_NONNULL_END
