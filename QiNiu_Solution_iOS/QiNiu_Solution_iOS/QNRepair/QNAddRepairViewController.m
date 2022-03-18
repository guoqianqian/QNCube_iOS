//
//  QNAddRepairViewController.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/9/27.
//

#import "QNAddRepairViewController.h"
#import "QNAddInterViewCell.h"
#import "QNAddInterViewViewModel.h"
#import <YYCategories/YYCategories.h>
#import <Masonry/Masonry.h>
#import <IQKeyboardManager/IQKeyboardManager.h>
#import "QNInterViewListModel.h"
#import "QNAddInterViewInfoModel.h"
#import "MBProgressHUD+QNShow.h"
#import "QNNetworkUtil.h"

@interface QNAddRepairViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) QNAddInterViewViewModel *viewModel;
@end

@implementation QNAddRepairViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"创建检修房间";
    
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside=YES;
    [self tableView];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(inputDone)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_return"] style:UIBarButtonItemStyleDone target:self action:@selector(pop)];
    self.navigationItem.leftBarButtonItem = cancelButton;
   
}

- (void)pop {
    [self.navigationController popViewControllerAnimated:YES];
}

//完成
- (void)inputDone {
    
//    [QNNetworkUtil postRequestWithAction:@"interview" params:params success:^(NSDictionary *responseData) {
//        
//        [MBProgressHUD showText:@"面试创建成功"];
//        [self popViewController];
//        
//    } failure:^(NSError *error) {
//        [MBProgressHUD showText:@"面试创建失败"];
//    }];
    
}

- (void)popViewController {
    if (self.popBlock) {
        self.popBlock();
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QNAddInterViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QNAddInterViewCell" forIndexPath:indexPath];
    [cell updateWithModel:self.viewModel.interviewModelArray[indexPath.section]];
    __weak typeof(self) weakSelf = self;
    cell.textEndEditBlock = ^(QNAddInterViewInfoModel * _Nonnull model) {
        weakSelf.viewModel.interviewModelArray[indexPath.section] = model;
    };

    return cell;;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (UITableView *)tableView {
    _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.view);
    }];
        
    [_tableView registerClass:[QNAddInterViewCell class] forCellReuseIdentifier:@"QNAddInterViewCell"];
        
    return _tableView;
}

- (QNAddInterViewViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [QNAddInterViewViewModel new];
    }
    return _viewModel;
}


@end
