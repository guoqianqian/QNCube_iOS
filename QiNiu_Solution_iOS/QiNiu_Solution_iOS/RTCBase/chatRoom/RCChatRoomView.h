//
//  RCChatRoomView.h
//  NiuLiving
//
//  Created by liyan on 2020/4/8.
//  Copyright © 2020 PILI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCCRInputBarControl.h"
#import <QNIMSDK/QNIMSDK.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RCChatRoomViewDelegate <NSObject>

-(void)didReceiveQuitMessageWithMessageModel:(QNIMMessageObject *)model;

-(void)didReceiveMessageUserBackground:(QNIMMessageObject *)model;

- (void)didReceiveIMSignalMessage:(QNIMMessageObject *)message;

@end

@interface RCChatRoomView : UIView

@property(nonatomic, weak) id<RCChatRoomViewDelegate> delegate;

/*!
 消息列表CollectionView和输入框都在这个view里
 */
@property(nonatomic, strong) UIView *messageContentView;

/*!
 会话页面的CollectionView
 */
@property(nonatomic, strong) UICollectionView *conversationMessageCollectionView;

/**
 输入工具栏
 */
@property(nonatomic,strong) RCCRInputBarControl *inputBar;



/**
 底部按钮容器，底部的四个按钮都添加在此view上
 */
@property(nonatomic, strong) UIView *bottomBtnContentView;

/**
 *  评论按钮
 */
@property(nonatomic,strong)UIButton *commentBtn;

@property(nonatomic,strong) QNIMMessageObject *model;

/**
 数据模型
 */

- (void)sendMessage:(QNIMMessageObject *)messageContent;
//展示message
- (void)showMessage:(QNIMMessageObject *)message;

- (void)sendMessage:(NSString *)message
        pushContent:(NSString *)pushContent
           targetId:(NSString *)targetId
            success:(void (^)(long messageId))successBlock
              error:(void (^)(QNIMError *nErrorCode, long messageId))errorBlock;

- (void)alertErrorWithTitle:(NSString *)title message:(NSString *)message ok:(NSString *)ok;

- (instancetype)initWithFrame:(CGRect)frame ;

- (void)setDefaultBottomViewStatus;

@end

NS_ASSUME_NONNULL_END
