//
//  LATPenToolbar.m
//  WhiteboardTest
//
//  Created by mac zhang on 2021/5/16.
//

#import "QNWhiteBoardPenToolbar.h"
#import "QNWhiteBoardToolbarColorButton.h"
#import "QNWhiteBoardSizeSelectionToolbar.h"

@interface QNWhiteBoardPenToolbar()
{
    NSArray * normalColorArray;
    NSArray * markColorArray;
    NSArray * currentColorArray;
}
@end

@implementation QNWhiteBoardPenToolbar

-(instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        self.multiSelectAllowed = YES;
        
        [self appendButtonsForImages:@[@"PenIcon",@"markIcon"]];
        
        QNWhiteBoardToolbarColorButton * sizeEntry = [[QNWhiteBoardToolbarColorButton alloc] init];
        sizeEntry.color = UIColor.blackColor;
        sizeEntry.scale = 0.2;
        [self appendButton:sizeEntry];
        
        normalColorArray = @[@"#FF000000",@"#FF1F9F8C",@"#FFF44336",@"#FFFFFFFF",@"#FFFFC000",@"#FF0086D0"];
        markColorArray = @[@"#FFFF5252",
                           @"#FF1ECAB1",
                           @"#FFFFC000",
                           @"#FF0BA8FF",
                           @"#FFF921D6",
                           @"#FF7CDA14"
        
        ];
        //@"#FF7CDA14"
        NSArray * colorbuttons = [super createColorGroupByColor:normalColorArray];
        
        [self appendButtons:colorbuttons];
        currentColorArray = normalColorArray;
    }
    return self;
}

-(void)buttonGroup:(QNWhiteBoardButtonGroup *)buttonGroup didSelectButtonAtIndex:(NSUInteger)index
{
    QNWhiteBoardInputConfig * penConfig = [self.barDelegate getInputConfigByMode:QNWBToolbarInputPencil];
    switch(index)
    {
        case 0:
            penConfig.penType = QNWBPenStyleNormal;
            break;
        case 1:
            penConfig.penType = QNWBPenStyleMark;
            break;
        case 2:
            [self.barDelegate onMenuEntryTaped:QNWBToolbarMenuPenSize];
            [self updateSelection];
            return;
        default:
        {
            NSString * color = currentColorArray[index -3];
            penConfig.color = color;
        }
            break;
    }
    [self.barDelegate sendInputConfig:QNWBToolbarInputPencil];
    [self updateSelection];
}
-(void)updateSelection
{
    QNWhiteBoardInputConfig * penConfig = [self.barDelegate getInputConfigByMode:QNWBToolbarInputPencil];
    penConfig.size = 2.5f;
    switch(penConfig.penType)
    {
        case QNWBPenStyleNormal:
            [self selectButtonAtIndex:0];
            [self deselectButtonAtIndex:1];
            break;
        case QNWBPenStyleMark:
            [self selectButtonAtIndex:1];
            [self deselectButtonAtIndex:0];
            break;
    }
    QNWhiteBoardToolbarColorButton * sizeButton = self.buttons[2];
    sizeButton.scale = penConfig.size/10.f;
    if([self.barDelegate isViewHidden:[QNWhiteBoardSizeSelectionToolbar class]])
    {
        [self deselectButtonAtIndex:2];
    }
    else
    {
        [self selectButtonAtIndex:2];
    }
    for(int i = 3;i < self.buttons.count;i ++)
    {
        QNWhiteBoardToolbarColorButton * colorButton = self.buttons[i];
        
        NSString * colorString = [self convertColorToString:colorButton.color];
        NSLog(@"compare :%@ %@",colorString,penConfig.color);
        if([colorString caseInsensitiveCompare:penConfig.color])
        {
            [self deselectButtonAtIndex:i];
        }
        else
        {
            [self selectButtonAtIndex:i];
        }
    }
    [self setNeedsDisplay];
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if([keyPath compare:@"penType"] == NSOrderedSame)
    {
        if([change[@"new"] intValue] == QNWBPenStyleNormal)
        {
            currentColorArray = normalColorArray;
        }
        else
        if([change[@"new"] intValue] == QNWBPenStyleMark)
        {
            currentColorArray = markColorArray;
        }
        for(int i = 3;i < self.buttons.count ; i ++)
        {
            QNWhiteBoardToolbarColorButton * btn = self.buttons[i];
            btn.color = [self convertStringToUIColor:currentColorArray[i-3]];
            [btn setNeedsDisplay];
        }
    }
    else if([keyPath compare:@"size"] == NSOrderedSame)
    {
        QNWhiteBoardToolbarColorButton * sizeButton = self.buttons[2];
        sizeButton.scale = [change[@"new"] intValue]/10.f;
        if([self.barDelegate isViewHidden:[QNWhiteBoardSizeSelectionToolbar class]])
        {
            [self deselectButtonAtIndex:2];
        }
        else
        {
            [self selectButtonAtIndex:2];
        }
        [sizeButton setNeedsDisplay];
    }
}
@end
