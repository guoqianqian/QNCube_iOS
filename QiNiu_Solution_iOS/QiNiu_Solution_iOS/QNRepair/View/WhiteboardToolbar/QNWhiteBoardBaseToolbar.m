//
//  QNWhiteBoardBaseToolbar.m
//  WhiteboardTest
//
//  Created by mac on 2021/5/19.
//

#import "QNWhiteBoardBaseToolbar.h"
#import "QNWhiteBoardToolbarColorButton.h"

@implementation QNWhiteBoardBaseToolbar

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
        self.backgroundColor = UIColor.whiteColor;
        self.buttonBackgroundColor = UIColor.lightGrayColor;
        self.textColor = UIColor.clearColor;
        
        self.delegate = self;
    }
    return self;
}
- (nonnull NSArray *)createColorGroupByColor:(nonnull NSArray *)colorArray {
    NSMutableArray * result = [NSMutableArray new];
    for(NSString * color in colorArray)
    {
        QNWhiteBoardToolbarColorButton * button = [QNWhiteBoardToolbarColorButton buttonWithType:UIButtonTypeRoundedRect];
        button.color = [self convertStringToUIColor:color];
        button.scale = 0.6;
        [result addObject:button];
        
    }
    return result;
}

-(UIColor *)convertStringToUIColor:(NSString *)color_
{
    float a,r,g,b;
    NSString * colorString = color_;
    if([color_ hasPrefix:@"#"])
    {
        colorString = [color_ substringFromIndex:1];
    }
    NSLog(@"convert %@ to uicolor",colorString);
    
    UInt64 hexNumber = 0;
    NSScanner * scanner = [[NSScanner alloc] initWithString:colorString];
    if([scanner scanHexLongLong:&hexNumber])
    {
        a = ((hexNumber & 0xff000000) >> 24) / 255.f;
        r = ((hexNumber & 0x00ff0000) >> 16) / 255.f;
        g = ((hexNumber & 0x0000ff00) >> 8) / 255.f;
        b = (hexNumber & 0x000000ff) / 255.f;
        
        return [[UIColor alloc] initWithRed:r green:g blue:b alpha:a];
    }
    return UIColor.blackColor;
}
-(NSString *)convertColorToString:(UIColor *)color_
{
    const CGFloat * components = CGColorGetComponents(color_.CGColor);
    int a = components[3] * 0xFF;
    int r = components[0] * 0xFF;
    int g = components[1] * 0xFF;
    int b = components[2] * 0xFF;
    
    NSString * colorString = [NSString stringWithFormat:@"#%02X%02X%02X%02X",a,r,g,b];
    return colorString;
}
-(QNWBToolbarInputName)getInputNameByInputMode:(QNWBInputMode)mode_
{
    switch(mode_)
    {
        case QNWBInputModePen:
            return QNWBToolbarInputPencil;
        case QNWBInputModeErase:
            return QNWBToolbarInputErase;
        case QNWBInputModeLaser:
            return QNWBToolbarInputLaser;
        case QNWBInputModeGeometry:
            return QNWBToolbarInputGeometry;
        case QNWBInputModeSelect:
            return QNWBToolbarInputSelect;
    }
    return QNWBToolbarInputPencil;
}
@end
