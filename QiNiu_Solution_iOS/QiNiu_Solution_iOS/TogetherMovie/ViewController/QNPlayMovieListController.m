//
//  QNPlayMovieListController.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/12/7.
//

#import "QNPlayMovieListController.h"
#import "QNMovieListModel.h"
#import "QNPlayingMovieCell.h"
#import "QNMovieChooseController.h"

@interface QNPlayMovieListController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray <QNMovieListModel *> *listModel;
@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIImageView *addImageViewBG;
@property (nonatomic, strong) UIButton *button;

@end

@implementation QNPlayMovieListController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];

    _label = [[UILabel alloc]initWithFrame:CGRectMake(20, 15, 100, 20)];
    _label.text = @"播放列表";
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
    [self addImageViewBG];
    [self button];

}

- (void)viewWillAppear:(BOOL)animated {
    [self requestData];
}

- (void)dismissController {
    [self removeFromParentViewController];
    [self.view removeFromSuperview];
}

- (void)requestData {
    
    NSMutableDictionary *requestParams = [NSMutableDictionary dictionary];
    requestParams[@"roomId"] = self.roomId;
    requestParams[@"pageNum"] = @(1);
    requestParams[@"pageSize"] = @(20);
    
    [QNNetworkUtil getRequestWithAction:@"watchMoviesTogether/selectedMovieList" params:requestParams success:^(NSDictionary *responseData) {
            
        self.listModel = [QNMovieListModel mj_objectArrayWithKeyValuesArray:responseData[@"list"]];
                
        NSMutableArray *arr = [NSMutableArray array];
        for (QNMovieListModel *model in self.listModel) {
            if (model.isPlaying) {
                [arr addObject:model];
            }
        }
        if (arr.count == 0) {
            self.listModel.firstObject.isPlaying = YES;
        }
        
        [self.tableView reloadData];
        self.label.text = [NSString stringWithFormat:@"播放列表(%ld)",self.listModel.count];
        
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
    return 120;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        
    QNPlayingMovieCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QNPlayingMovieCell" forIndexPath:indexPath];
    QNMovieListModel *model = self.listModel[indexPath.row];
    cell.itemModel = model;
    
    __weak typeof(self)weakSelf = self;
    cell.selectBlock = ^(QNMovieListModel * _Nonnull model) {
        [weakSelf.listModel enumerateObjectsUsingBlock:^(QNMovieListModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.isPlaying = NO;
        }];
        
        QNMovieListModel *movie = weakSelf.listModel[indexPath.row];
        movie.isPlaying = YES;
        
        [weakSelf.tableView reloadData];
        
        if (weakSelf.listClickedBlock) {
            weakSelf.listClickedBlock(movie);
        }
    };
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;;
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//
//    if (self.listClickedBlock) {
//        self.listClickedBlock();
//    }
//}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor blackColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:_tableView];
        [self.view bringSubviewToFront:_addImageViewBG];
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.view);
            make.top.equalTo(self.label.mas_bottom).offset(10);
        }];
        
        [_tableView registerClass:[QNPlayingMovieCell class] forCellReuseIdentifier:@"QNPlayingMovieCell"];
        
    }
    return _tableView;
}

- (UIButton *)button {
    if (!_button) {
        _button = [[UIButton alloc]init];
        [_button setImage:[UIImage imageNamed:@"addMovieButton_icon"] forState:UIControlStateNormal];
        [_button addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.addImageViewBG addSubview:_button];
        [_button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.addImageViewBG);
            make.top.equalTo(self.addImageViewBG).offset(5);
        }];
    }
    return _button;
}

- (UIImageView *)addImageViewBG {
    if (!_addImageViewBG) {
        _addImageViewBG = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"addMovie_bg"]];
        _addImageViewBG.userInteractionEnabled = YES;
        [self.view addSubview:_addImageViewBG];
        [_addImageViewBG mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-20);
        }];
    }
    return _addImageViewBG;
}

//跳转到视频选择页面
- (void)buttonClicked {
    
    QNMovieChooseController *vc = [QNMovieChooseController new];
    vc.roomId = self.roomId;
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    
    __weak typeof(self)weakSelf = self;
    [self presentViewController:vc animated:YES completion:^{            
        [weakSelf requestData];
    }];
}

@end
