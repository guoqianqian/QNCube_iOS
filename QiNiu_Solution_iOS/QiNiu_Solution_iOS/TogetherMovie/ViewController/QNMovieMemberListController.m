//
//  QNMovieMemberListController.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/12/8.
//

#import "QNMovieMemberListController.h"
#import "QNMovieMemberListCell.h"
#import "QNRoomDetailModel.h"

@interface QNMovieMemberListController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray <QNUserInfo *> *ListModel;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) QNUserInfo *selectedItemModel;
@end

@implementation QNMovieMemberListController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    _label = [[UILabel alloc]initWithFrame:CGRectMake(20, 15, 100, 20)];
    _label.text = @"好友列表";
    _label.textColor = [UIColor whiteColor];
    [self.view addSubview:_label];
    
    UIButton *button = [[UIButton alloc]init];
    [button setImage:[UIImage imageNamed:@"Close_round"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(dismissController) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-20);
        make.centerY.equalTo(self.label);
    }];

    [self tableView];
    [self button];

}

- (void)dismissController {
    [self removeFromParentViewController];
    [self.view removeFromSuperview];
}

- (void)setAllUserList:(NSArray<QNUserInfo *> *)allUserList {
    self.ListModel = allUserList;
    self.label.text = [NSString stringWithFormat:@"好友列表(%ld)",self.ListModel.count];
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.ListModel.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        
    QNMovieMemberListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QNMovieMemberListCell" forIndexPath:indexPath];
    cell.itemModel = self.ListModel[indexPath.row];
    __weak typeof(self)weakSelf = self;
    cell.listClickedBlock = ^(QNUserInfo * _Nonnull itemModel) {
        weakSelf.selectedItemModel = itemModel;
    };
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    if (self.listClickedBlock) {
//        self.listClickedBlock();
//    }
    [self removeFromParentViewController];
    [self.view removeFromSuperview];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor blackColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:_tableView];
        [self.view bringSubviewToFront:_button];
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.view);
            make.top.equalTo(self.label.mas_bottom).offset(10);
        }];
        
        [_tableView registerClass:[QNMovieMemberListCell class] forCellReuseIdentifier:@"QNMovieMemberListCell"];
        
    }
    return _tableView;
}

- (UIButton *)button {
    if (!_button) {
        _button = [[UIButton alloc]init];
        [_button setTitle:@"确认" forState:UIControlStateNormal];
        [_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _button.titleLabel.font = [UIFont systemFontOfSize:15];
        [_button addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_button];
        [self.view bringSubviewToFront:_button];
        [_button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.view);
            make.height.mas_equalTo(65);
        }];
    }
    return _button;
}

- (void)buttonClicked {
    [self removeFromParentViewController];
    [self.view removeFromSuperview];
    if (self.invitationClickedBlock) {
        self.invitationClickedBlock(self.selectedItemModel);
    }
    
}

@end
