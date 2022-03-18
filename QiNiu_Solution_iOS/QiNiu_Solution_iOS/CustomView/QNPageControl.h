//
//  QNPageControl.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/4/9.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, QNPageControlContentMode){
    
    QNPageControlContentModeLeft=0,
    QNPageControlContentModeCenter,
    QNPageControlContentModeRight,
};

typedef NS_ENUM(NSInteger, QNPageControlStyle)
{
    /** 默认按照 controlSize 设置的值,如果controlSize未设置 则按照大小为5的小圆点 */
    QNPageControlStyelDefault = 0,
    /** 长条样式 */
    QNPageControlStyelRectangle,
    /** 圆点 + 长条 样式 */
    QNPageControlStyelDotAndRectangle,
    
};


@class QNPageControl;
@protocol QNPageControlDelegate <NSObject>

-(void)QNPageControlClick:(QNPageControl*_Nonnull)pageControl index:(NSInteger)clickIndex;

@end


@interface QNPageControl : UIControl


/** 位置 默认居中 */
@property(nonatomic) QNPageControlContentMode PageControlContentMode;

/** 滚动条样式 默认按照 controlSize 设置的值,如果controlSize未设置 则为大小为5的小圆点 */
@property(nonatomic) QNPageControlStyle PageControlStyle;

@property(nonatomic) NSInteger numberOfPages;          // default is 0
@property(nonatomic) NSInteger currentPage;            // default is 0. value pinned to 0..numberOfPages-1

/** 距离初始位置 间距  默认10 */
@property (nonatomic) CGFloat marginSpacing;
/** 间距 默认3 */
@property (nonatomic) CGFloat controlSpacing;

/** 大小 默认(5,5) 如果设置PageControlStyle,则失效 */
@property (nonatomic) CGSize controlSize;

/** 其他page颜色 */
@property(nullable, nonatomic,strong) UIColor *otherColor;

/** 当前page颜色 */
@property(nullable, nonatomic,strong) UIColor *currentColor;

/** 设置图片 */
@property(nonatomic,strong) UIImage * _Nullable currentBkImg;

@property(nonatomic,weak)id<QNPageControlDelegate> _Nullable delegate;


@end


