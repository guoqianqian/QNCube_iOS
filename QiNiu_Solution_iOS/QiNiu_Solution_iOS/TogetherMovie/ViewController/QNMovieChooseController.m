//
//  QNMovieChooseController.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/12/12.
//

#import "QNMovieChooseController.h"
#import "QNMovieListModel.h"
#import "QNChooseMovieListCell.h"

@interface QNMovieChooseController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSArray <QNMovieListModel *> *listModel;

@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) UILabel *numLabel;

@property (nonatomic, strong) UIButton *confirmButton;

@property (nonatomic, strong) UIImageView *addImageViewBG;

@property (nonatomic, assign) NSInteger selectNum;


@end

@implementation QNMovieChooseController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.selectNum = 0;
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(20, 40 , 20, 20)];
    [button setImage:[UIImage imageNamed:@"icon_return"] forState:(UIControlStateNormal)];
    [button addTarget:self action:@selector(conference) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:button];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(kScreenWidth / 2 - 40, 40, 80, 20)];
    label.text = @"选择视频";
    label.textColor = [UIColor whiteColor];
    [self.view addSubview:label];
    
    [self collectionView];
    [self requestData];
    
    [self bottomView];
    [self numLabel];
    [self addImageViewBG];
    [self confirmButton];

}

- (void)requestData {
    
    NSMutableDictionary *requestParams = [NSMutableDictionary dictionary];

    requestParams[@"pageNum"] = @(1);
    requestParams[@"pageSize"] = @(20);
    
    [QNNetworkUtil getRequestWithAction:@"watchMoviesTogether/movieList" params:requestParams success:^(NSDictionary *responseData) {
            
        self.listModel = [QNMovieListModel mj_objectArrayWithKeyValuesArray:responseData[@"list"]];
        
        [self.collectionView reloadData];
        
        } failure:^(NSError *error) {
            
    }];
    
}



- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.listModel.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    QNChooseMovieListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"QNChooseMovieListCell" forIndexPath:indexPath];    
    [cell updateWithModel:self.listModel[indexPath.item]];
    cell.roomId = self.roomId;
    __weak typeof(self)weakSelf = self;
    cell.selectBlock = ^(QNMovieListModel * _Nonnull model) {
        if (model.isSelected) {
            weakSelf.selectNum  = weakSelf.selectNum + 1;
            weakSelf.numLabel.text = [NSString stringWithFormat:@"已选择（%@）",@(weakSelf.selectNum)];
        } else {
            weakSelf.selectNum = weakSelf.selectNum - 1;
            weakSelf.numLabel.text = [NSString stringWithFormat:@"已选择（%@）",@(weakSelf.selectNum)];
        }
        
    };
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.minimumLineSpacing = 10;
        layout.minimumInteritemSpacing = 10;
        layout.itemSize = CGSizeMake((kScreenWidth - 15)/2, (kScreenWidth - 15)/2);
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;

        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 80, kScreenWidth - 5, self.view.frame.size.height - 140) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor blackColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[QNChooseMovieListCell class] forCellWithReuseIdentifier:@"QNChooseMovieListCell"];
        [self.view addSubview:_collectionView];
    }
    return _collectionView;
}

- (void)conference {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc]init];
        _bottomView.backgroundColor = [UIColor blackColor];
        [self.view addSubview:_bottomView];
        [self.view bringSubviewToFront:_bottomView];
        [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.view);
            make.height.mas_equalTo(60);
        }];
    }
    return _bottomView;
}

- (UILabel *)numLabel {
    if (!_numLabel) {
        _numLabel = [[UILabel alloc]init];
        _numLabel.text = @"已选择（0）";
        _numLabel.textColor = [UIColor whiteColor];
        _numLabel.font = [UIFont systemFontOfSize:14];
        [self.bottomView addSubview:_numLabel];
        
        [_numLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.bottomView).offset(15);
            make.bottom.equalTo(self.bottomView).offset(-20);
        }];
    }
    return _numLabel;
}

- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [[UIButton alloc]init];
        [_confirmButton setTitle:@"添加" forState:UIControlStateNormal];
        _confirmButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_confirmButton addTarget:self action:@selector(conference) forControlEvents:UIControlEventTouchUpInside];
        [_confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.bottomView addSubview:_confirmButton];
        [_confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.addImageViewBG);
            make.top.equalTo(self.addImageViewBG).offset(5);
        }];
    }
    return _confirmButton;
}

- (UIImageView *)addImageViewBG {
    if (!_addImageViewBG) {
        _addImageViewBG = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"addMovie_bg"]];
        _addImageViewBG.userInteractionEnabled = YES;
        [self.bottomView addSubview:_addImageViewBG];
        [_addImageViewBG mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.bottomView).offset(-20);
            make.centerY.equalTo(self.numLabel);
        }];
    }
    return _addImageViewBG;
}
@end
