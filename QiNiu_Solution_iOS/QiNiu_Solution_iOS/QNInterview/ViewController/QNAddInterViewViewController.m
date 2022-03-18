//
//  QNAddInterViewViewController.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/4/9.
//

#import "QNAddInterViewViewController.h"
#import "QNAddInterViewCell.h"
#import "QNAddInterViewViewModel.h"
#import <YYCategories/YYCategories.h>
#import <Masonry/Masonry.h>
#import <IQKeyboardManager/IQKeyboardManager.h>
#import "QNInterViewListModel.h"
#import "QNAddInterViewInfoModel.h"
#import "MBProgressHUD+QNShow.h"

@interface QNAddInterViewViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) QNAddInterViewViewModel *viewModel;

@end

@implementation QNAddInterViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"创建面试";
    if (self.model ) {
        self.title = @"修改面试";
    }
    
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
    
    __weak typeof(self) weakSelf = self;
    
    if (self.model) {
        [self.viewModel requestEditInterviewWithInterviewId:self.model.ID Success:^{
            [MBProgressHUD showText:@"面试修改成功"];
            [weakSelf popViewController];
        }];
        return;
    }
    [self.viewModel requestCreateInterviewSuccess:^{
        [MBProgressHUD showText:@"面试创建成功"];
        [weakSelf popViewController];
    }];
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
    return self.viewModel.interviewModelArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 8 || section == 10) {
        return 10;
    } else {
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc]init];
    view.backgroundColor = [UIColor colorWithHexString:@"f9f9f9"];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QNAddInterViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QNAddInterViewCell" forIndexPath:indexPath];
    [cell updateWithModel:self.viewModel.interviewModelArray[indexPath.section]];
    __weak typeof(self) weakSelf = self;
    cell.textEndEditBlock = ^(QNAddInterViewInfoModel * _Nonnull model) {
        weakSelf.viewModel.interviewModelArray[indexPath.section] = model;
        if (indexPath.section == 2) {
            [weakSelf timeChooseWarningWithStartTime:weakSelf.viewModel.interviewModelArray[indexPath.section - 1].content endTime:model.content];
        }
    };
    cell.interviewNameBlock = ^(NSString * _Nonnull interviewName) {
        QNAddInterViewInfoModel *titleModel = weakSelf.viewModel.interviewModelArray.firstObject;
        if (!titleModel.isEdited) {
            titleModel.content = [NSString stringWithFormat:@"%@的面试",interviewName];
            [weakSelf.tableView reloadData];
        }        
    };
    return cell;;
}

- (void)timeChooseWarningWithStartTime:(NSString *)startTime endTime:(NSString *)endTime {
    
    NSDate *startDate = [NSDate dateWithString:startTime format:@"yyyy年MM月dd日HH:mm"];
    NSDate *endDate = [NSDate dateWithString:endTime format:@"yyyy年MM月dd日HH:mm"];
    if ([[endDate earlierDate:startDate] isEqualToDate:endDate]) {
        [MBProgressHUD showText:@"结束时间不能早于开始时间"];
    }
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
        _viewModel.infoModel = self.model;
    }
    return _viewModel;
}

@end
