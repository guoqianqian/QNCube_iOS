//
//  LATPenSizeToolbar.m
//  WhiteboardTest
//
//  Created by mac on 2021/5/18.
//

#import "QNWhiteBoardSizeSelectionToolbar.h"
#import "QNWhiteBoardToolbarColorButton.h"
@interface QNWhiteBoardSizeSelectionToolbar()
{
    NSArray * normalPenSizeArray;
    NSArray * markPenSizeArray;
    NSArray * geometrySizeArray;
    NSArray * sizeArray;
}
@end
@implementation QNWhiteBoardSizeSelectionToolbar

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        normalPenSizeArray = @[@(0.1f),@(0.15f),@(0.25f),@(0.4)];
        markPenSizeArray = @[@(0.2f),@(0.4f),@(0.6f),@(1.0)];
        geometrySizeArray = @[@(0.05f),@(0.1f),@(0.2f),@(0.4)];
        NSMutableArray *buttons = [NSMutableArray new];
        for(NSNumber * size in normalPenSizeArray)
        {
            QNWhiteBoardToolbarColorButton * button = [QNWhiteBoardToolbarColorButton buttonWithType:UIButtonTypeRoundedRect];
            button.color = UIColor.blackColor;
            button.scale = [size floatValue];
            [buttons addObject:button];
        }
        [self appendButtons:buttons];
    }
    return self;
}

-(void)buttonGroup:(QNWhiteBoardButtonGroup *)buttonGroup didSelectButtonAtIndex:(NSUInteger)index
{
    QNWhiteBoardInputConfig * config = [self.barDelegate getActiveInputConfig];
    
    NSNumber * value = sizeArray[index];
    config.size = [value floatValue] * 25;
    switch(config.mode)
    {
        case QNWBInputModePen:
            [self.barDelegate sendInputConfig:QNWBToolbarInputPencil];
            break;
        case QNWBInputModeGeometry:
            [self.barDelegate sendInputConfig:QNWBToolbarInputGeometry];
            break;
        default:
            break;
    }
    
}
-(void)updateSelection
{
    QNWhiteBoardInputConfig * config = [self.barDelegate getActiveInputConfig];
    switch(config.mode)
    {
        case QNWBInputModePen:
        {
            if(config.penType == QNWBPenStyleNormal)
            {
                sizeArray = normalPenSizeArray;
            }
            else if(config.penType == QNWBPenStyleMark)
            {
                sizeArray = markPenSizeArray;
            }
        }
            break;
        case QNWBInputModeGeometry:
        {
            sizeArray = geometrySizeArray;
        }
            break;
        default:
            break;
    }
    for(int i = 0;i < self.buttons.count; i ++)
    {
        QNWhiteBoardToolbarColorButton * btn = self.buttons[i];
        btn.scale = [sizeArray[i] floatValue];
        [btn setNeedsDisplay];
    }
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    [self updateSelection];
}
@end
