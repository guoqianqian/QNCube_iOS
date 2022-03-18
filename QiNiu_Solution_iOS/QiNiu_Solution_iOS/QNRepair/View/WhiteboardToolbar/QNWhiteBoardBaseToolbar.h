//
//  LATBaseToolbar.h
//  WhiteboardTest
//
//  Created by mac on 2021/5/19.
//

#import <UIKit/UIKit.h>
#import "QNWhiteBoardToolbarDelegate.h"
#import "QNWhiteBoardButtonGroup.h"

NS_ASSUME_NONNULL_BEGIN

@interface QNWhiteBoardBaseToolbar : QNWhiteBoardButtonGroup <QNButtonGroupDelegate>

@property (nonatomic,weak) id<QNWhiteBoardToolbarDelegate> barDelegate;

-(NSArray *)createColorGroupByColor:(NSArray *)colorArray;

-(NSString *)convertColorToString:(UIColor *)color_;
-(UIColor *)convertStringToUIColor:(NSString *)color_;
-(void)updateSelection;
-(QNWBToolbarInputName)getInputNameByInputMode:(QNWBInputMode)mode_;
@end

NS_ASSUME_NONNULL_END
