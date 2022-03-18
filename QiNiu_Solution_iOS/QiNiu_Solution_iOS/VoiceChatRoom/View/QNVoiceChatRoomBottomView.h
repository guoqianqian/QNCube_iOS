//
//  QNVoiceChatRoomBottomView.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2022/1/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum{
    QNVoiceChatRoomClickTypeLeave,//离开房间
    QNVoiceChatRoomClickTypeOnMic,//请求上麦
    QNVoiceChatRoomClickTypeVoice,//开关麦
}QNVoiceChatRoomClickType;

@interface QNVoiceChatRoomBottomView : UIView

@property (nonatomic, copy) void (^buttonClickBlock)(QNVoiceChatRoomClickType type);

@end

NS_ASSUME_NONNULL_END
