//
//  LATGeometryToolbar.m
//  WhiteboardTest
//
//  Created by mac on 2021/5/17.
//

#import "QNWhiteBoardGeometryToolbar.h"
#import "QNWhiteBoardSizeSelectionToolbar.h"
#import "QNWhiteBoardToolbarColorButton.h"
#import "QNWhiteBoardColorToolbar.h"

@implementation QNWhiteBoardGeometryToolbar
@synthesize barDelegate;
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
        QNWhiteBoardToolbarColorButton * colorButton = [QNWhiteBoardToolbarColorButton buttonWithType:UIButtonTypeRoundedRect];
        colorButton.color = UIColor.blackColor;
        colorButton.scale = 0.7;
        
        QNWhiteBoardToolbarColorButton * sizeButton = [QNWhiteBoardToolbarColorButton buttonWithType:UIButtonTypeRoundedRect];
        sizeButton.color = UIColor.blackColor;
        sizeButton.scale = 0.2;
        
        [self appendButtons:@[colorButton,sizeButton]];
        [self appendButtonsForImages:@[@"line",@"arrow",@"rectangle",@"circle"]];
        
//        [self appendButtonsForTitles:@[@"数学",@"物理",@"化学"]];
    }
    return self;
}
-(void)buttonGroup:(QNWhiteBoardButtonGroup *)buttonGroup didSelectButtonAtIndex:(NSUInteger)index
{
    
    QNWhiteBoardInputConfig * geometryConfig = [barDelegate getInputConfigByMode:QNWBToolbarInputGeometry];
    geometryConfig.mode = QNWBInputModeGeometry;
    switch(index)
    {
        case 0:
            [barDelegate onMenuEntryTaped:QNWBToolbarMenuGeometryColor];
            return;
        case 1:
            [barDelegate onMenuEntryTaped:QNWBToolbarMenuGeometrySize];
            return;
        case 2:
            geometryConfig.geometryType = QNWBGeometryTypeLine;
            break;
        case 3:
            geometryConfig.geometryType = QNWBGeometryTypeArrow;
            break;
        case 4:
            geometryConfig.geometryType = QNWBGeometryTypeRectangle;
            break;
        case 5:
            geometryConfig.geometryType = QNWBGeometryTypeCircle;
            break;
        case 6:
            [barDelegate onMenuEntryTaped:QNWBToolbarMenuGeometryMath];
            break;
        case 7:
            [barDelegate onMenuEntryTaped:QNWBToolbarMenuGeometryPhysics];
            break;
        case 8:
            [barDelegate onMenuEntryTaped:QNWBToolbarMenuGeometryChemetry];
            break;
    }
    [barDelegate sendInputConfig:QNWBToolbarInputGeometry];
}
-(void)updateSelection
{
    
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if([keyPath compare:@"color"] == NSOrderedSame)
    {
        NSString * colorString = change[@"new"];
        QNWhiteBoardToolbarColorButton * button = self.buttons[0];
        button.color = [self convertStringToUIColor:colorString];
        [button setNeedsDisplay];
    }
    else if([keyPath compare:@"size"] == NSOrderedSame)
    {
        QNWhiteBoardToolbarColorButton * sizeButton = self.buttons[1];
        sizeButton.scale = [change[@"new"] intValue]/10.f;
        if([self.barDelegate isViewHidden:[QNWhiteBoardSizeSelectionToolbar class]])
        {
            [self deselectButtonAtIndex:1];
        }
        else
        {
            [self selectButtonAtIndex:1];
        }
        [sizeButton setNeedsDisplay];
    }
}
@end
