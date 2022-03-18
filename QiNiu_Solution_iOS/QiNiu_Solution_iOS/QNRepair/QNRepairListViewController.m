//
//  QNRepairListViewController.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/9/26.
//

#import "QNRepairListViewController.h"
#import "QNRefreshFooter.h"
#import <Social/Social.h>
#import <Masonry/Masonry.h>
#import <SDWebImage/SDWebImage.h>
#import <MJRefresh/MJRefresh.h>
#import "MBProgressHUD+QNShow.h"
#import <MJExtension/MJExtension.h>
#import <YYCategories/YYCategories.h>
#import "QNRepairListCell.h"
#import "QNRepairViewController.h"
#import "QNRepairListViewModel.h"
#import "QNRepairListModel.h"
#import "QNAddRepairItemModel.h"
#import "QNNetworkUtil.h"
#import "QNRTCRoomEntity.h"
#import "QNRepairRoleChooseView.h"
#import "QNRepairLiveViewController.h"

@interface QNRepairListViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) QNRepairListModel *listModel;
@property (nonatomic, assign) NSInteger pageIndex;

@end

@implementation QNRepairListViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"检修房间列表";
    self.view.backgroundColor = [UIColor whiteColor];

    [self tableView];
    [self requestData];
    [self setUpRefresh];

    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_increase"] style:UIBarButtonItemStyleDone target:self action:@selector(addRepair)];
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
    [QNRepairListViewModel requestRepairListWithPageNum:self.pageIndex success:^(QNRepairListModel * _Nonnull listModel) {

        [weakSelf setRefreshHeaderWithEndPage:listModel.endPage];
        weakSelf.listModel = listModel;
        [weakSelf.tableView reloadData];
    }];
}

- (void)requestMoreData {
    __weak typeof(self) weakSelf = self;
    [QNRepairListViewModel requestRepairListWithPageNum:++self.pageIndex success:^(QNRepairListModel * _Nonnull listModel) {
        NSMutableArray *array = [NSMutableArray arrayWithArray:weakSelf.listModel.list];
        [array addObjectsFromArray:listModel.list];
        weakSelf.listModel.list = array.copy;
        [weakSelf setRefreshFooterWithEndPage:listModel.endPage];
        [weakSelf.tableView reloadData];
    }];
}

//新建房间
- (void)addRepair {

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"新建检修房间" message:@"\n\n\n" preferredStyle:UIAlertControllerStyleAlert];
    
    QNRepairRoleChooseView *view = [[QNRepairRoleChooseView alloc]initWithFrame:CGRectMake(15, 50, 200, 45)];
    __block NSString *roleStr;
    view.roleChooseBlock = ^(NSString * _Nonnull role) {
        roleStr = role;
    } ;
    
    [alertController.view addSubview:view];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入房间名称";
        textField.tag = 1000;
    }];
    UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertController addAction:cancelBtn];
    
    UIAlertAction *changeBtn = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UITextField *textFiled1 = [alertController.view viewWithTag:1000];
        
        QNAddRepairItemModel *model = [QNAddRepairItemModel new];
        model.title = textFiled1.text;
        model.role = roleStr;
        [QNNetworkUtil postRequestWithAction:@"repair/createRoom" params:[model mj_keyValues] success:^(NSDictionary *responseData) {
        
            [MBProgressHUD showText:@"房间创建成功"];
//            [self requestData];
            
            QNRepairItemModel *model = [QNRepairItemModel mj_objectWithKeyValues:responseData[@"roomInfo"]];
            model.roleType = [roleStr isEqualToString:@"staff"] ? QNRepairRoleTypeStaff : QNRepairRoleTypeProfessor;
            [self intoRepairRoomWithModel:model];
            
        } failure:^(NSError *error) {
            [MBProgressHUD showText:@"房间创建失败"];
        }];
        
    }];
    [alertController addAction:changeBtn];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}


// 进入房间
- (void)intoRepairRoomWithModel:(QNRepairItemModel *)model {
    
    NSDictionary *configDic = [[NSUserDefaults standardUserDefaults] objectForKey:QN_SET_CONFIG_KEY];
    if (!configDic) {
        configDic = @{@"VideoSize":NSStringFromCGSize(CGSizeMake(480, 640)), @"FrameRate":@15, @"Bitrate":@(400*1000)};
    } else if (![configDic objectForKey:@"Bitrate"]) {
        configDic = @{@"VideoSize":NSStringFromCGSize(CGSizeMake(480, 640)), @"FrameRate":@15, @"Bitrate":@(400*1000)};
        [[NSUserDefaults standardUserDefaults] setObject:configDic forKey:QN_SET_CONFIG_KEY];
    }

    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:QN_ROOM_NAME_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    QNRepairViewController *vc = [QNRepairViewController new];
    vc.model = model;
    vc.popBlock = ^{
        [self.tableView reloadData];
    };
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listModel.list.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        
    QNRepairListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QNRepairListCell" forIndexPath:indexPath];
    QNRepairItemModel *itemModel = self.listModel.list[indexPath.row];
    cell.itemModel = itemModel;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    __weak typeof(self) weakSelf = self;
    
    cell.optionButtonBlock = ^(NSString * _Nonnull buttonTitle) {
        
        if ([buttonTitle isEqualToString:@"专家进入"]) {
            
            itemModel.roleType = QNRepairRoleTypeProfessor;
            [weakSelf intoRepairRoomWithModel:itemModel];
            
        } else if ([buttonTitle isEqualToString:@"学生进入"]) {
            
            [weakSelf studentIntoRoomAlertWithItemModel:itemModel];
            
        }else if ([buttonTitle isEqualToString:@"检修员进入"]) {
            
            itemModel.roleType = QNRepairRoleTypeStaff;
            [weakSelf intoRepairRoomWithModel:itemModel];
            
        } else {
            
        }
    };

    return cell;;
}

- (void)studentIntoRoomAlertWithItemModel:(QNRepairItemModel *)itemModel {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请选择进房方式" message:@"" preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:@"拉流播放" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        QNRepairLiveViewController *vc = [QNRepairLiveViewController new];
        vc.model = itemModel;
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:vc animated:YES completion:nil];
    }];
    [alertController addAction:cancelBtn];
    
    UIAlertAction *changeBtn = [UIAlertAction actionWithTitle:@"加入订阅" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        itemModel.roleType = QNRepairRoleTypeStudents;
        [self intoRepairRoomWithModel:itemModel];
    }];
    [alertController addAction:changeBtn];
    
    [self presentViewController:alertController animated:YES completion:nil];
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
        
        [_tableView registerClass:[QNRepairListCell class] forCellReuseIdentifier:@"QNRepairListCell"];
        
    }
    return _tableView;
}


@end
