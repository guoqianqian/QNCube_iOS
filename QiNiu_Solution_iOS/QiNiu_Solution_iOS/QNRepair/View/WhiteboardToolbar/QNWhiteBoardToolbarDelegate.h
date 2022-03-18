//
//  QNWhiteBoardToolbarDelegate.h
//  WhiteboardTest
//
//  Created by mac on 2021/5/18.
//

#import <Foundation/Foundation.h>
#import <QNWhiteBoardSDK/QNWhiteBoardSDK.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,QNWBToolbarMenuKey)
{
    QNWBToolbarMenuPenSize,
    QNWBToolbarMenuGeometryColor,
    QNWBToolbarMenuGeometrySize,
    QNWBToolbarMenuGeometryMath,
    QNWBToolbarMenuGeometryPhysics,
    QNWBToolbarMenuGeometryChemetry,
};

typedef NS_ENUM(NSInteger,QNWBToolbarInputName)
{
    QNWBToolbarInputPencil,
    QNWBToolbarInputErase,
    QNWBToolbarInputLaser,
    QNWBToolbarInputSelect,
    QNWBToolbarInputGeometry,
    QNWBToolbarInputFile,
};

@protocol QNWhiteBoardToolbarDelegate <NSObject>

-(QNWhiteBoardInputConfig *)getInputConfigByMode:(QNWBToolbarInputName)mode_;

-(QNWhiteBoardInputConfig *)getActiveInputConfig;
-(void)sendInputConfig:(QNWBToolbarInputName)mode_;

-(void)switchInputMode:(QNWBToolbarInputName)mode_;

-(void)onMenuEntryTaped:(QNWBToolbarMenuKey)menu_;

-(BOOL)isViewHidden:(Class)view_;


@end

NS_ASSUME_NONNULL_END
