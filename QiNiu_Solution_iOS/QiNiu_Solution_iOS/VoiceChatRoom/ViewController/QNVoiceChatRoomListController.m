//
//  QNVoiceChatRoomListController.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2022/1/5.
//

#import "QNVoiceChatRoomListController.h"
#import "QNVoiceChatRoomTitleCell.h"
#import "QNVoiceChatRoomListCell.h"

#import "QNCreatVoiceChatRoomController.h"
#import "QNVoiceChatRoomController.h"
#import "QNRoomDetailModel.h"

@interface QNVoiceChatRoomListController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray <QNRoomInfo *> *rooms;

@end

@implementation QNVoiceChatRoomListController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"语聊房";
    self.view.backgroundColor = [UIColor whiteColor];

    [self tableView];
    [self requestData];
    [self startRoomButton];

}

- (void)requestData {
    
    NSMutableDictionary *requestParams = [NSMutableDictionary dictionary];

    requestParams[@"type"] = @"voiceChatRoom";
    
    [QNNetworkUtil getRequestWithAction:@"base/listRoom" params:requestParams success:^(NSDictionary *responseData) {
            
        self.rooms = [QNRoomInfo mj_objectArrayWithKeyValuesArray:responseData[@"list"]];
        [self.tableView reloadData];
        
        } failure:^(NSError *error) {
            
        }];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? (self.rooms.count == 0 ? 0 : 1)  : self.rooms.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 0 ? 100 : 180;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        
    if (indexPath.section == 0) {
        QNVoiceChatRoomTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QNVoiceChatRoomTitleCell" forIndexPath:indexPath];
        [cell updateWithModel:self.rooms];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else {
        QNVoiceChatRoomListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QNVoiceChatRoomListCell" forIndexPath:indexPath];
        [cell updateWithModel:self.rooms[indexPath.row]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    QNRoomDetailModel *model = [QNRoomDetailModel new];
    
    QNVoiceChatRoomController *vc = [QNVoiceChatRoomController new];
    model.roomInfo = self.rooms[indexPath.row];
    vc.model = model;
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor colorWithHexString:@"f6f5ec"];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:_tableView];
    
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.bottom.equalTo(self.view);
        }];
        
        [_tableView registerClass:[QNVoiceChatRoomTitleCell class] forCellReuseIdentifier:@"QNVoiceChatRoomTitleCell"];
        [_tableView registerClass:[QNVoiceChatRoomListCell class] forCellReuseIdentifier:@"QNVoiceChatRoomListCell"];
        
        
    }
    return _tableView;
}

- (void)startRoomButton {
    
    UIButton *startButton = [[UIButton alloc]init];
    [startButton setTitle:@" + 创建房间 " forState:UIControlStateNormal];
    [startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    startButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [startButton setBackgroundColor:[UIColor colorWithHexString:@"3CB371"]];
    startButton.clipsToBounds = YES;
    startButton.layer.cornerRadius = 20;
    [self.view addSubview:startButton];
    [self.view bringSubviewToFront:startButton];
    [startButton addTarget:self action:@selector(startRoom) forControlEvents:UIControlEventTouchUpInside];
    
    [startButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottom).offset(-30);
        make.height.mas_equalTo(40);
        make.width.mas_equalTo(150);
    }];
}

- (void)startRoom {
    
    QNCreatVoiceChatRoomController *vc = [[QNCreatVoiceChatRoomController alloc]init];
    vc.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:vc animated:YES completion:nil];
    
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"+ Add a Topic" message:@"Start a room open to everyone" preferredStyle:UIAlertControllerStyleActionSheet];

    
}

@end
