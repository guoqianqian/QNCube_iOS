//
//  QNWhiteBoardFileInfo.h
//  QNWhiteBoardSDK
//
//  Created by 郭茜 on 2021/5/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QNWhiteBoardFileInfo : NSObject
@property (nonatomic,retain) NSString * path;
@property (nonatomic,retain) NSString * name;
@property (nonatomic,assign) float left;
@property (nonatomic,assign) float top;
@property (nonatomic,assign) float width;
@property (nonatomic,assign) float height;


/// 设置文件属性  （宽高是在白板屏幕空间下的像素值，而非系统屏幕像素值，[[QNWhiteboardControl instance] getBoardInfo] 可以获取到白板空间的大小）
/// @param path_ 文件路径
/// @param name_ 文件名
/// @param left_ 左间距
/// @param top_ 上间距
/// @param width_ 宽
/// @param height_ 高
-(instancetype)initWithParams:(NSString * _Nonnull)path_ withName:(NSString * _Nullable)name_ withLeft:(NSInteger)left_ withTop:(NSInteger)top_ withWidth:(NSInteger)width_ withHeight:(NSInteger)height_;

@end

NS_ASSUME_NONNULL_END
