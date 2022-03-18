//
//  LATPrimaryToolbar.m
//  WhiteboardTest
//
//  Created by mac zhang on 2021/5/16.
//

#import "QNWhiteBoardPrimaryToolbar.h"
#import <QNWhiteBoardSDK/QNWhiteBoardSDK.h>

#import "QNWhiteBoardExpandableToolbar.h"

@interface QNWhiteBoardPrimaryToolbar()
{

}
@end
@implementation QNWhiteBoardPrimaryToolbar

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
        [self appendButtonsForImages:@[@"selectIcon",@"PenIcon",@"eraseIcon",@"geometryIcon",@"laserIcon",@"fileIcon"]];
        self.delegate = self;
    }
    return self;
}

-(void)buttonGroup:(QNWhiteBoardButtonGroup *)buttonGroup didSelectButtonAtIndex:(NSUInteger)index
{
    switch(index)
    {
        case 0:
            [self.barDelegate switchInputMode:QNWBToolbarInputSelect];
            break;
        case 1:
            [self.barDelegate switchInputMode:QNWBToolbarInputPencil];
            break;
        case 2:
            [self.barDelegate switchInputMode:QNWBToolbarInputErase];
            break;
        case 3:
            [self.barDelegate switchInputMode:QNWBToolbarInputGeometry];
            break;
        case 4:
            [self.barDelegate switchInputMode:QNWBToolbarInputLaser];
            break;
        case 5:
            //file
            [self.barDelegate switchInputMode:QNWBToolbarInputFile];
            break;
        default:
            break;
            
    }
}
-(void)updateSelection
{
    
}
@end
