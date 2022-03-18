//
//  QNWhiteBoardDefine.h
//  QNWhiteBoardSDK
//
//  Created by 郭茜 on 2021/5/14.
//

#ifndef QNWhiteBoardDefine_h
#define QNWhiteBoardDefine_h

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,QNWBInputMode)
{
    /**
     * 笔输入模式
     */
    QNWBInputModePen,
    /**
     * 橡皮输入模式
     */
    QNWBInputModeErase,
    
    /**
     * 选择输入模式
     */
    QNWBInputModeSelect,
    /**
     * 几何图形
     */
    QNWBInputModeGeometry,
    
    /**
     * 激光笔
     */
    QNWBInputModeLaser
    
};
typedef NS_ENUM(NSInteger,QNWBPenStyle)
{
    /**
    普通笔
     */
    QNWBPenStyleNormal,
    /**
     mark笔
     */
    QNWBPenStyleMark,
    /**
     * 激光笔-点
     */
    QNWBPenStyleLaserTypeDot = 2,
    
    /**
     * 激光笔-手
     */
    QNWBPenStyleLaserTypeHand = 3,
    
    /**
     * 激光笔-白色箭头
     */
    QNWBPenStyleLasterTypeWhiteArrow = 4,
    
    /**
     * 激光笔-黑色箭头
     */
    QNWBPenStyleLaserTypeBlackArrow = 5,
    
};

typedef NS_ENUM(NSInteger,QNWBGeometryType)
{
    /**
       * 矩形
       */
      QNWBGeometryTypeRectangle = 0,

      /**
       * 圆形
       */
      QNWBGeometryTypeCircle = 1,

      /**
       * 线
       */
      QNWBGeometryTypeLine = 3,

      /**
       * 箭头
       */
      QNWBGeometryTypeArrow = 6

};
typedef NS_ENUM(NSInteger,QNWBBoardStatus) {
    /**
     * 空闲
     */
    QNWBBoardStatusIdle,

    /**
     * 正在加载
     */
    QNWBBoardStatusLoading,

    /**
     * 加载成功
     */
    QNWBBoardStatusSuccessful,

    /**
     * 加载失败
     */
    QNWBBoardStatusFailed,

    /**
     * 正在重连
     */
    QNWBBoardStatusReconnecting,

};

typedef NS_ENUM(NSInteger,QNWBWidgetType) {
    /**
     * 白板
     */
    QNWBWidgetTypeBoard = 0,

    /**
     * 文件
     */
    QNWBWidgetTypeFile = 1,

    /**
     * 图片
     */
    QNWBWidgetTypeImage = 2,

    /**
     * 几何图形
     */
    QNWBWidgetTypeGeometry = 3,

    /**
     * 选择框
     */
    QNWBWidgetTypeSelection = 5,
};

typedef NS_ENUM(NSInteger,QNWBWidgetAction)
{
    /**
     * 上传/插入新widget
     */
    QNWBWidgetActionUpload,

    /**
     * 删除widget
     */
    QNWBWidgetActionDelete,

    /**
     * 加载成功
     */
    QNWBWidgetActionSuccess,

    /**
     * 加载失败
     */
    QNWBWidgetActionFailed,
};
#endif /* QNWhiteBoardDefine_h */
