//
//  LATToolbarErase.m
//  WhiteboardTest
//
//  Created by mac zhang on 2021/5/16.
//

#import "QNWhiteBoardEraseToolbar.h"

@implementation QNWhiteBoardEraseToolbar

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
        [self appendButtonsForImages:@[@"eraserOne",@"eraserTwo",@"eraserThree",@"eraserFour",@"eraserFive"]];
    }
    return self;
}


-(void)buttonGroup:(QNWhiteBoardButtonGroup *)buttonGroup didSelectButtonAtIndex:(NSUInteger)index
{
    QNWhiteBoardInputConfig * eraserConfig = [self.barDelegate getInputConfigByMode:QNWBToolbarInputErase];
    eraserConfig.mode = QNWBInputModeErase;
    float eraseSize = eraserConfig.size;
    switch(index)
    {
        case 0:
            eraseSize = 20;
            break;
        case 1:
            eraseSize = 40;
            break;
        case 2:
            eraseSize = 100;
            break;
        case 3:
            eraseSize = 260;
            break;
        case 4:
            eraseSize = 500;
            break;
            
    }
    eraserConfig.size = eraseSize;
    [self.barDelegate sendInputConfig:QNWBToolbarInputErase];
}
-(void)updateSelection
{
    
}
@end
