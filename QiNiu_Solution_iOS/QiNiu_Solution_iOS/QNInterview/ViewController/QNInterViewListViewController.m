//
//  QNInterViewListViewController.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/4/9.
//

#import "QNInterViewListViewController.h"
#import "QNInterViewListCell.h"
#import "QNAddInterViewViewController.h"
#import "QNInterviewViewController.h"
#import "QNInterviewListViewModel.h"
#import "QNInterViewListModel.h"
#import "QNRefreshFooter.h"
#import <Social/Social.h>
#import <Masonry/Masonry.h>
#import <SDWebImage/SDWebImage.h>
#import <MJRefresh/MJRefresh.h>
#import <MJExtension/MJExtension.h>
#import <YYCategories/YYCategories.h>

@interface QNInterViewListViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) QNInterViewListModel *listModel;
@property (nonatomic, assign) NSInteger pageIndex;

@end

@implementation QNInterViewListViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"面试列表";
    self.view.backgroundColor = [UIColor whiteColor];

    [self tableView];
    [self requestData];
    [self setUpRefresh];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_increase"] style:UIBarButtonItemStyleDone target:self action:@selector(addInterView)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_return"] style:UIBarButtonItemStyleDone target:self action:@selector(pop)];
    self.navigationItem.leftBarButtonItem = cancelButton;
   
}

- (void)pop {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark-------刷新

-(void)setUpRefresh
{
    MJRefreshNormalHeader *header =  [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(requestData)];
    header.lastUpdatedTimeLabel.hidden = YES;
    header.stateLabel.hidden = YES;
    self.tableView.mj_header = header;
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
    self.tableView.mj_footer.hidden = YES;
    self.tableView.mj_footer = [QNRefreshFooter footerWithRefreshingTarget:self refreshingAction:@selector(requestMoreData)];
    self.tableView.mj_footer.hidden = YES;
}

- (void)setRefreshFooterWithEndPage:(BOOL)endPage {
    [self.tableView.mj_footer endRefreshing];
    if (endPage) {
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    } else {
        self.tableView.mj_footer.hidden = NO;
    }
}

- (void)setRefreshHeaderWithEndPage:(BOOL)endPage {
    [self.tableView.mj_header endRefreshing];
    if (endPage) {
        self.tableView.mj_footer.hidden = YES;
    } else {
        self.tableView.mj_footer.hidden = NO;
    }
}

- (void)requestData {
    self.pageIndex=1;
    __weak typeof(self) weakSelf = self;
    [QNInterviewListViewModel requestInterviewListWithPageNum:self.pageIndex success:^(QNInterViewListModel * _Nonnull listModel) {
        [weakSelf setRefreshHeaderWithEndPage:listModel.endPage];
        weakSelf.listModel = listModel;
        [weakSelf.tableView reloadData];
    }];
}

- (void)requestMoreData {
    __weak typeof(self) weakSelf = self;
    [QNInterviewListViewModel requestInterviewListWithPageNum:++self.pageIndex success:^(QNInterViewListModel * _Nonnull listModel) {
        NSMutableArray *array = [NSMutableArray arrayWithArray:weakSelf.listModel.list];
        [array addObjectsFromArray:listModel.list];
        weakSelf.listModel.list = array.copy;
        [weakSelf setRefreshFooterWithEndPage:listModel.endPage];
        [weakSelf.tableView reloadData];
    }];
}

//新建面试
- (void)addInterView {
    __weak typeof(self) weakSelf = self;
    QNAddInterViewViewController *vc = [[QNAddInterViewViewController alloc]init];
    vc.popBlock = ^{
        [weakSelf requestData];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

//修改面试
- (void)changeInterviewWithModel:(QNInterviewItemModel *)model {
    QNAddInterViewViewController *vc = [[QNAddInterViewViewController alloc]init];
    vc.model = model;
    __weak typeof(self) weakSelf = self;
    vc.popBlock = ^{
        [weakSelf requestData];
    };

    [self.navigationController pushViewController:vc animated:YES];
}

//取消面试
- (void)cancelInterviewWithInterviewId:(NSString *)interviewId {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"是否取消当前面试？" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    
    UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertController addAction:cancelBtn];
    
    UIAlertAction *changeBtn = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        __weak typeof(self) weakSelf = self;
        [QNInterviewListViewModel requestCancelInterviewWithInterviewId:interviewId cancelBlock:^{
            [weakSelf requestData];
        }];
            
    }];
    [alertController addAction:changeBtn];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
    
}

//结束面试
- (void)endInterviewWithInterviewId:(NSString *)interviewId {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"是否结束当前面试？" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    
    UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertController addAction:cancelBtn];
    
    UIAlertAction *changeBtn = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        __weak typeof(self) weakSelf = self;
        [QNInterviewListViewModel requestEndInterviewWithInterviewId:interviewId endBlock:^{
            [weakSelf requestData];
        }];
            
    }];
    [alertController addAction:changeBtn];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}

// 进入面试房间
- (void)intoInterviewRoomWithModel:(QNInterviewItemModel *)model {
    
    NSDictionary *configDic = [[NSUserDefaults standardUserDefaults] objectForKey:QN_SET_CONFIG_KEY];
    if (!configDic) {
        configDic = @{@"VideoSize":NSStringFromCGSize(CGSizeMake(480, 640)), @"FrameRate":@15, @"Bitrate":@(400*1000)};
    } else if (![configDic objectForKey:@"Bitrate"]) {
        // 如果不存在 Bitrate key，做一下兼容处理
        configDic = @{@"VideoSize":NSStringFromCGSize(CGSizeMake(480, 640)), @"FrameRate":@15, @"Bitrate":@(400*1000)};
        [[NSUserDefaults standardUserDefaults] setObject:configDic forKey:QN_SET_CONFIG_KEY];
    }

    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:QN_ROOM_NAME_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    QNInterviewViewController *vc = [QNInterviewViewController new];
    vc.configDic = configDic;
    vc.interviewInfoModel = model;
    vc.popBlock = ^{
        [self.tableView reloadData];
    };
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
}

//分享
- (void)shareInterviewWithShareInfoModel:(QNInterviewShareInfoModel *)shareInfo {
    
    NSURL *imageUrl = [NSURL URLWithString:shareInfo.icon];
    NSData *dateImg = [NSData dataWithContentsOfURL:imageUrl];
    UIImage *imageToShare = [UIImage sd_imageWithData:dateImg];

    NSURL *urlToShare = [NSURL URLWithString:shareInfo.url];

    NSArray *activityItems = @[shareInfo.content, imageToShare, urlToShare];

    UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];
    [self presentViewController:activityVC animated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listModel.list.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        
    QNInterViewListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QNInterViewListCell" forIndexPath:indexPath];
    cell.itemModel = self.listModel.list[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    __weak typeof(self) weakSelf = self;
    
    cell.optionButtonBlock = ^(NSInteger optionType) {
        switch (optionType) {
            case QNInterviewListOptionTypeChange:{
                [weakSelf changeInterviewWithModel:self.listModel.list[indexPath.row]];
            }
                break;
            case QNInterviewListOptionTypeEnter:{
                [weakSelf intoInterviewRoomWithModel:self.listModel.list[indexPath.row]];
            }
                break;
            case QNInterviewListOptionTypeShare:{
                [weakSelf shareInterviewWithShareInfoModel:self.listModel.list[indexPath.row].shareInfo];
            }
                break;
            case QNInterviewListOptionTypeCancel:{
                [weakSelf cancelInterviewWithInterviewId:self.listModel.list[indexPath.row].ID];
            }
                break;
            case QNInterviewListOptionTypeEnd:{
                [weakSelf endInterviewWithInterviewId:self.listModel.list[indexPath.row].ID];
            }
                break;
            default:
                break;
        }
    };

    return cell;;
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
        
        [_tableView registerClass:[QNInterViewListCell class] forCellReuseIdentifier:@"QNInterViewListCell"];
        
    }
    return _tableView;
}


@end
