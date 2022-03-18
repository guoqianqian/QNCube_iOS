//
//  LATLaserToolbar.m
//  WhiteboardTest
//
//  Created by mac on 2021/5/19.
//

#import "QNWhiteBoardLaserToolbar.h"

@implementation QNWhiteBoardLaserToolbar

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
        [self appendButtonsForImages:@[@"laserHand",@"laserDot",@"laserWhiteArrow",@"laserBlackArrow"]];
        
    }
    return self;
}

-(void)buttonGroup:(QNWhiteBoardButtonGroup *)buttonGroup didSelectButtonAtIndex:(NSUInteger)index
{
    QNWhiteBoardInputConfig * laserConfig = [self.barDelegate getInputConfigByMode:QNWBToolbarInputLaser];
    switch(index)
    {
        case 0:
            laserConfig.penType = QNWBPenStyleLaserTypeHand;
            break;
        case 1:
            laserConfig.penType = QNWBPenStyleLaserTypeDot;
            break;
        case 2:
            laserConfig.penType = QNWBPenStyleLasterTypeWhiteArrow;
            break;
        case 3:
            laserConfig.penType = QNWBPenStyleLaserTypeBlackArrow;
            break;
        
    }
    [self.barDelegate sendInputConfig:QNWBToolbarInputLaser];
}
-(void)updateSelection
{
    QNWhiteBoardInputConfig * laserConfig = [self.barDelegate getInputConfigByMode:QNWBToolbarInputLaser];
    
    switch(laserConfig.penType)
    {
        case QNWBPenStyleLaserTypeHand:
        
            [self selectButtonAtIndex:0];
            break;
        case QNWBPenStyleLaserTypeDot:
            [self selectButtonAtIndex:1];
            break;
        case QNWBPenStyleLasterTypeWhiteArrow:
            [self selectButtonAtIndex:2];
            break;
        case QNWBPenStyleLaserTypeBlackArrow:
            [self selectButtonAtIndex:3];
            break;
        default:
            break;
    }
}
@end
