//
//  QNInterviewViewController.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/4/13.
//

#import "QNRTCRoom.h"

static NSString *cameraTag = @"camera";
static NSString *screenTag = @"screen";
static NSString *audioTag = @"audio";

@class QNInterviewItemModel,QNInterViewListModel;

@interface QNInterviewViewController : QNRTCRoom

@property (nonatomic, strong) NSDictionary *configDic;

@property (nonatomic, strong) NSString *token;

@property (nonatomic, assign) BOOL isAudioPublished;
@property (nonatomic, assign) BOOL isVideoPublished;
@property (nonatomic, assign) BOOL isScreenPublished;

@property (nonatomic, assign) CGSize videoEncodeSize;
@property (nonatomic, assign) NSInteger bitrate;
@property (nonatomic, copy) void (^popBlock)(void);

@property (nonatomic, strong) QNInterviewItemModel *interviewInfoModel;

@end
