//
//  LATExpanableToolbar.m
//  WhiteboardTest
//
//  Created by mac zhang on 2021/5/16.
//

#import "QNWhiteBoardExpandableToolbar.h"
#import "QNWhiteBoardPrimaryToolbar.h"
#import "QNWhiteBoardPenToolbar.h"
#import <QNWhiteBoardSDK/QNWhiteBoardSDK.h>
#import "QNWhiteBoardEraseToolbar.h"
#import "QNWhiteBoardLaserToolbar.h"
#import "QNWhiteBoardGeometryToolbar.h"
#import "QNWhiteBoardToolbarColorButton.h"
#import "QNWhiteBoardSizeSelectionToolbar.h"
#import "QNWhiteBoardColorToolbar.h"
#import "QNWhiteBoardSubjectToolbar.h"


typedef NS_ENUM(NSInteger,LATToolbarStatus)
{
    LATToolbarStatusShowNothing,
    LATToolbarStatusShowPencil,
    LATToolbarStatusShowPencilDetail,
    LATToolbarStatusShowErase,
    LATToolbarStatusShowEraseDetail,
    LATToolbarStatusShowLaser,
    LATToolbarStatusShowGeometry,
    LATToolbarStatusShowGeometrySizeSelect,
    LATToolbarStatusShowGeometryColorSelect,
    LATToolbarStatusShowGeometrySubjectDetail,
    LATToolbarStatusShowSelection
};

@interface QNWhiteBoardExpandableToolbar()
{
    
    QNWhiteBoardInputConfig * penConfig;
    QNWhiteBoardInputConfig * eraserConfig;
    QNWhiteBoardInputConfig * selectConfig;
    QNWhiteBoardInputConfig * geometryConfig;
    QNWhiteBoardInputConfig * laserConfig;
    
    QNWhiteBoardInputConfig * currentInputConfig;
    LATToolbarStatus status;
    QNWhiteBoardGeometryToolbar * geometryBar;
    QNWhiteBoardPenToolbar * penBar;
    QNWhiteBoardSizeSelectionToolbar * sizeBar;
    
}
@end

@implementation QNWhiteBoardExpandableToolbar


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */
-(instancetype)init
{
    if(self = [super init])
    {
        self.axis = UILayoutConstraintAxisVertical;
        self.distribution = UIStackViewDistributionFillProportionally;
        self.alignment = UIStackViewAlignmentCenter;
        self.spacing = 5;
        
        
//        self.backgroundColor = UIColor.blueColor;
        
        [self addToolbar:[[QNWhiteBoardPrimaryToolbar alloc] initWithFrame:CGRectMake(0, 0, 280, 44)]];
            
        penBar = (QNWhiteBoardPenToolbar *)[self addToolbar:[[QNWhiteBoardPenToolbar alloc] initWithFrame:CGRectMake(0, 0, 460 ,44)]];
        
        [self addToolbar:[[QNWhiteBoardEraseToolbar alloc] initWithFrame:CGRectMake(0, 0, 240, 44)]];
        
        [self addToolbar:[[QNWhiteBoardLaserToolbar alloc] initWithFrame:CGRectMake(0, 0, 198, 44)]];
        
        
        geometryBar = (QNWhiteBoardGeometryToolbar *)[self addToolbar:[[QNWhiteBoardGeometryToolbar alloc] initWithFrame:CGRectMake(0, 0,280, 44)]];
        
        sizeBar = (QNWhiteBoardSizeSelectionToolbar *)[self addToolbar:[[QNWhiteBoardSizeSelectionToolbar alloc] initWithFrame:CGRectMake(0, 0, 180, 44 )]];
        
        [self addToolbar:[[QNWhiteBoardColorToolbar alloc] initWithFrame:CGRectMake(0, 0, 308, 44)]];
        
        
        penConfig = [QNWhiteBoardInputConfig instanceWithPen:@"#FF000000" thickness:2.0f];
        eraserConfig = [QNWhiteBoardInputConfig instanceWithErase:40.0];
        selectConfig = [QNWhiteBoardInputConfig instanceWithSelect];
        laserConfig = [QNWhiteBoardInputConfig instanceWithLaser:QNWBPenStyleLaserTypeHand];
        geometryConfig = [QNWhiteBoardInputConfig instanceWithGeometry:QNWBGeometryTypeLine color:@"#FF000000" thickness:4.0f];
        
        status = LATToolbarStatusShowNothing;
        
        currentInputConfig = penConfig;
        
        [penConfig addObserver:penBar forKeyPath:NSStringFromSelector(@selector(size)) options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
        [penConfig addObserver:penBar forKeyPath:NSStringFromSelector(@selector(penType)) options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
        [penConfig addObserver:sizeBar forKeyPath:NSStringFromSelector(@selector(penType)) options:NSKeyValueObservingOptionNew context:nil];
        [geometryConfig addObserver:geometryBar forKeyPath:NSStringFromSelector(@selector(size)) options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
        [geometryConfig addObserver:geometryBar forKeyPath:NSStringFromSelector(@selector(color)) options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
        
        [self refreshToolbar];
        
    }
    return self;
}
-(void)willMoveToSuperview:(UIView *)newSuperview
{
    if(newSuperview == nil)
    {
        [penConfig removeObserver:penBar forKeyPath:NSStringFromSelector(@selector(size))];
        [penConfig removeObserver:penBar forKeyPath:NSStringFromSelector(@selector(penType))];
        
        [geometryConfig removeObserver:geometryBar forKeyPath:NSStringFromSelector(@selector(size))];
        [geometryConfig removeObserver:geometryBar forKeyPath:NSStringFromSelector(@selector(color))];
    }
}
-(QNWhiteBoardBaseToolbar *)addToolbar:(QNWhiteBoardBaseToolbar *)bar
{
    bar.hidden = NO;
    bar.layer.cornerRadius = 10;
    bar.layer.masksToBounds = YES;
    bar.barDelegate = self;
    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:bar attribute:NSLayoutAttributeWidth  relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:bar.frame.size.width];
    
    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:bar attribute:NSLayoutAttributeHeight  relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:bar.frame.size.height];
    [bar addConstraints:@[width,height]];
    
    
    [self addArrangedSubview:bar];
    
    return bar;
}

-(QNWhiteBoardBaseToolbar *)loadToolbarFromNib:(NSString *)nibName owner:(id)target
{
    QNWhiteBoardBaseToolbar *bar  = [[NSBundle bundleForClass:[QNWhiteBoardPrimaryToolbar class] ]  loadNibNamed:nibName owner:target options:nil].firstObject;
    bar.hidden = NO;
    bar.layer.cornerRadius = 10;
    bar.layer.masksToBounds = YES;
    bar.barDelegate = self;
    
    [self addArrangedSubview:bar];
    return bar;
}

-(void)refreshToolbar
{
    switch(status)
    {
        case LATToolbarStatusShowPencil:
        {
            [self showSubMenu:@[[QNWhiteBoardPenToolbar class]]];
        }
            break;
        case LATToolbarStatusShowPencilDetail:
        {
            [self showSubMenu:@[[QNWhiteBoardPenToolbar class],[QNWhiteBoardSizeSelectionToolbar class]]];
        }
            break;
        case LATToolbarStatusShowErase:
        {
            [self showSubMenu:@[[QNWhiteBoardEraseToolbar class]]];
        }
            break;
        case LATToolbarStatusShowLaser:
        {
            [self showSubMenu:@[[QNWhiteBoardLaserToolbar class]]];
        }
            break;
        case LATToolbarStatusShowGeometry:
            [self showSubMenu:@[[QNWhiteBoardGeometryToolbar class]]];
            break;
        case LATToolbarStatusShowGeometrySizeSelect:
            [self showSubMenu:@[[QNWhiteBoardGeometryToolbar class],[QNWhiteBoardSizeSelectionToolbar class]]];
            break;
        case LATToolbarStatusShowGeometryColorSelect:
            [self showSubMenu:@[[QNWhiteBoardGeometryToolbar class],[QNWhiteBoardColorToolbar class]]];
            break;
        case LATToolbarStatusShowGeometrySubjectDetail:
            [self showSubMenu:@[[QNWhiteBoardGeometryToolbar class],[QNWhiteBoardSubjectToolbar class]]];
            break;
        case LATToolbarStatusShowNothing:
            [self showSubMenu:@[[QNWhiteBoardPrimaryToolbar class]]];
            break;
            
    }
}

-(void)showSubMenu:(NSArray<Class> *)views
{
    if(self.arrangedSubviews.count > 1)
    {
        for(int i = 1; i < self.arrangedSubviews.count ; i ++)
        {
            QNWhiteBoardBaseToolbar * toolbar = (QNWhiteBoardBaseToolbar *)self.arrangedSubviews[i];
            if([views containsObject:[toolbar class]])
            {
                toolbar.hidden = NO;
                
                [toolbar updateSelection];
            }
            else
                toolbar.hidden = YES;
        }
    }
    [self layoutSubviews];
}
-(UIView *)getSubviewByType:(Class)type_
{
    for(int i = 0; i < self.arrangedSubviews.count ; i ++)
    {
        
        if([self.arrangedSubviews[i] isKindOfClass:type_])
        {
            return self.arrangedSubviews[i];
        }
        
    }
    return nil;
}
-(void)hideAllSubMenus
{
    if(self.arrangedSubviews.count > 1)
    {
        for(int i = 1; i < self.arrangedSubviews.count ; i ++)
        {
            self.arrangedSubviews[i].hidden = YES;
        }
    }
}
-(void)addConstraintToParent:(UIView *)parent_
{
    self.translatesAutoresizingMaskIntoConstraints = false;
    
    
    NSLayoutConstraint *barTop = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:parent_ attribute:NSLayoutAttributeTop multiplier:1.0 constant:28];
    NSLayoutConstraint *barRight = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeRightMargin relatedBy:NSLayoutRelationEqual toItem:parent_ attribute:NSLayoutAttributeRightMargin multiplier:1.0 constant:-20];
    
//    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth  relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:500];
    NSLayoutConstraint *barLeft = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:parent_ attribute:NSLayoutAttributeLeft multiplier:1.0 constant:100];
    
    [parent_ addConstraints:[NSArray arrayWithObjects:barTop,barRight,barLeft,nil]];
}


-(QNWhiteBoardInputConfig *)getInputConfigByMode:(QNWBToolbarInputName)mode_
{
    switch(mode_)
    {
        case QNWBToolbarInputPencil:
            return penConfig;
        case QNWBToolbarInputErase:
            return eraserConfig;
        case QNWBToolbarInputSelect:
            return selectConfig;
        case QNWBToolbarInputGeometry:
            return geometryConfig;
        case QNWBToolbarInputLaser:
            return laserConfig;
        default:
            return nil;
    }
}


-(void)sendInputConfig:(QNWBToolbarInputName)mode_
{
    QNWhiteBoardInputConfig * config = [self getInputConfigByMode:mode_];
    if(config)
    {
        currentInputConfig = config;
        [[QNWhiteboardControl instance] setInputMode:currentInputConfig];
    }
}

-(void)onMenuEntryTaped:(QNWBToolbarMenuKey)menu_
{
    switch(menu_)
    {
        case QNWBToolbarMenuGeometrySize:
        {
            if(status == LATToolbarStatusShowGeometrySizeSelect)
            {
                //hide it
                status = LATToolbarStatusShowGeometry;
            }
            else
            {
                status = LATToolbarStatusShowGeometrySizeSelect;
            }
        }
            break;
        case QNWBToolbarMenuGeometryColor:
        {
            if(status == LATToolbarStatusShowGeometryColorSelect)
            {
                //hide it
                
                status = LATToolbarStatusShowGeometry;
            }
            else
            {
                status = LATToolbarStatusShowGeometryColorSelect;
            }
        }
            break;
        case QNWBToolbarMenuGeometryMath:
        case QNWBToolbarMenuGeometryPhysics:
        case QNWBToolbarMenuGeometryChemetry:
        {
            if(status == LATToolbarStatusShowGeometrySubjectDetail)
            {
                status = LATToolbarStatusShowGeometry;
            }
            else
            {
                status = LATToolbarStatusShowGeometrySubjectDetail;
            }
        }
            break;
        case QNWBToolbarMenuPenSize:
        {
            if(status == LATToolbarStatusShowPencilDetail)
            {
                
                status = LATToolbarStatusShowPencil;
            }
            else
            {
                status = LATToolbarStatusShowPencilDetail;
            }
        }
            break;
    }
    [self refreshToolbar];
}

-(void)switchInputMode:(QNWBToolbarInputName)mode_
{
    switch(mode_)
    {
        case QNWBToolbarInputPencil:
            if(status == LATToolbarStatusShowPencil)
                status = LATToolbarStatusShowNothing;
            else
                status = LATToolbarStatusShowPencil;
            break;
        case QNWBToolbarInputSelect:
            status = LATToolbarStatusShowNothing;
            break;
        case QNWBToolbarInputGeometry:
            if(status == LATToolbarStatusShowGeometry||
               status == LATToolbarStatusShowGeometrySizeSelect||
               status == LATToolbarStatusShowGeometryColorSelect ||
               status == LATToolbarStatusShowGeometrySubjectDetail)
            {
                status = LATToolbarStatusShowNothing;
            }
            else
                status = LATToolbarStatusShowGeometry;
            break;
        case QNWBToolbarInputErase:
            if(status == LATToolbarStatusShowErase)
            {
                status = LATToolbarStatusShowNothing;
            }
            else
                status = LATToolbarStatusShowErase;
            
            break;
        case QNWBToolbarInputLaser:
            if(status == LATToolbarStatusShowLaser)
            {
                status = LATToolbarStatusShowNothing;
            }
            else
                status = LATToolbarStatusShowLaser;
            break;
        case QNWBToolbarInputFile:
        {
            status = LATToolbarStatusShowNothing;
        }
            break;
    }
    [self refreshToolbar];
    [self sendInputConfig:mode_];
}
-(BOOL)isViewHidden:(Class)view_
{
    UIView * target = [self getSubviewByType:view_];
    if(target)
    {
        return target.hidden;
    }
    return NO;
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if([object isEqual:penConfig])
    {
        NSLog(@"new size:%.2f\n",penConfig.size);
        NSLog(@"changed:%@",change);
    }
}
-(QNWhiteBoardInputConfig *)getActiveInputConfig
{
    return currentInputConfig;
}
    

@end
