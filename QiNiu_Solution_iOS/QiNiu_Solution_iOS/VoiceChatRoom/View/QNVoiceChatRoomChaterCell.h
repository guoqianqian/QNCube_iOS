//
//  QNVoiceChatRoomChaterCell.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2022/1/10.
//

#import <UIKit/UIKit.h>
#import "QNRoomDetailModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface QNVoiceChatRoomChaterCell : UITableViewCell

@property (nonatomic, strong) NSArray <QNRTCMicsInfo *> *onMicUserList;

@end

NS_ASSUME_NONNULL_END
