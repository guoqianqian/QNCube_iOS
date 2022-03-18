//
//  QNWBScreenShotsDelegate.h
//  QNWhiteBoardSDK
//
//  Created by 郭茜 on 2021/5/14.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol QNWBScreenShotsDelegate <NSObject>
-(void)done:(UIImage *)image;
@end

NS_ASSUME_NONNULL_END
