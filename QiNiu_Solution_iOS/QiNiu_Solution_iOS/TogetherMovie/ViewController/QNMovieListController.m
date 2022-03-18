//
//  QNMovieListController.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/11/29.
//

#import "QNMovieListController.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/SDWebImage.h>
#import "MBProgressHUD+QNShow.h"
#import <MJExtension/MJExtension.h>
#import <YYCategories/YYCategories.h>
#import <MJRefresh/MJRefresh.h>

#import "QNMovieListCell.h"
#import "QNNetworkUtil.h"
#import "QNMovieListModel.h"
#import "QNCreateMovieRoomController.h"

@interface QNMovieListController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray <QNMovieListModel *> *listModel;
@property (nonatomic, assign) NSInteger pageIndex;

@end

@implementation QNMovieListController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"一起看视频吧";
    self.view.backgroundColor = [UIColor whiteColor];

    [self tableView];
    [self requestData];
//    [self setUpRefresh];

}

- (void)requestData {
    
    NSMutableDictionary *requestParams = [NSMutableDictionary dictionary];

    requestParams[@"pageNum"] = @(1);
    requestParams[@"pageSize"] = @(20);
    
    [QNNetworkUtil getRequestWithAction:@"watchMoviesTogether/movieList" params:requestParams success:^(NSDictionary *responseData) {
            
        self.listModel = [QNMovieListModel mj_objectArrayWithKeyValuesArray:responseData[@"list"]];
        
        [self.tableView reloadData];
        
        } failure:^(NSError *error) {
            
        }];
    
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listModel.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 260;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        
    QNMovieListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QNMovieListCell" forIndexPath:indexPath];
    cell.itemModel = self.listModel[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    QNCreateMovieRoomController *vc = [QNCreateMovieRoomController new];
    vc.listModel = self.listModel[indexPath.row];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:_tableView];
    
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.bottom.equalTo(self.view);
        }];
        
        [_tableView registerClass:[QNMovieListCell class] forCellReuseIdentifier:@"QNMovieListCell"];
        
    }
    return _tableView;
}

@end
