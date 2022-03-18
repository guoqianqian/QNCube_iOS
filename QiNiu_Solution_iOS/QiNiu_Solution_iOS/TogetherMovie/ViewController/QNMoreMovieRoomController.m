//
//  QNMoreMovieRoomController.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/12/3.
//

#import "QNMoreMovieRoomController.h"
#import <YYCategories/YYCategories.h>
#import "QNNetworkUtil.h"
#import "QNRoomDetailModel.h"
#import <MJExtension/MJExtension.h>
#import "QNMovieRoomListCell.h"
#import "QNTogetherMovieController.h"
#import "QNMovieLiveController.h"

@interface QNMoreMovieRoomController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSArray <QNRoomInfo *> *rooms;

@end

@implementation QNMoreMovieRoomController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(20, 40 , 20, 20)];
    [button setImage:[UIImage imageNamed:@"icon_return"] forState:(UIControlStateNormal)];
    [button addTarget:self action:@selector(conference) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:button];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(kScreenWidth / 2 - 40, 40, 80, 20)];
    label.text = @"房间广场";
    label.textColor = [UIColor whiteColor];
    [self.view addSubview:label];
    
    [self collectionView];
    [self requestData];

}

- (void)requestData {
        
    NSMutableDictionary *requestParams = [NSMutableDictionary dictionary];

    requestParams[@"type"] = @"movie";
    
    [QNNetworkUtil getRequestWithAction:@"base/listRoom" params:requestParams success:^(NSDictionary *responseData) {
            
        self.rooms = [QNRoomInfo mj_objectArrayWithKeyValuesArray:responseData[@"list"]];
        [self.collectionView reloadData];
        
        } failure:^(NSError *error) {
            
        }];
}



- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.rooms.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    QNMovieRoomListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"QNMovieRoomListCell" forIndexPath:indexPath];
    [cell updateWithModel:self.rooms[indexPath.item]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    QNRoomDetailModel *model = [QNRoomDetailModel new];
    
    QNTogetherMovieController *vc = [QNTogetherMovieController new];
    vc.model = model;
    vc.model.roomInfo = self.rooms[indexPath.item];
    QNUserInfo *userInfo = [QNUserInfo new];
    userInfo.role = @"roomAudience";
    vc.model.userInfo = userInfo;
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    vc.listModel = self.listModel;
    [self presentViewController:vc animated:YES completion:nil];
    
//    QNMovieLiveController *vc = [QNMovieLiveController new];
//    vc.model = model;
//    vc.model.roomInfo = self.rooms[indexPath.item];
//    QNUserInfo *userInfo = [QNUserInfo new];
//    userInfo.role = @"roomAudience";
//    vc.model.userInfo = userInfo;
//    vc.modalPresentationStyle = UIModalPresentationFullScreen;
//    [self presentViewController:vc animated:YES completion:nil];
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.minimumLineSpacing = 10;
        layout.minimumInteritemSpacing = 10;
        layout.itemSize = CGSizeMake((kScreenWidth - 15)/2, (kScreenWidth - 15)/2);
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;

        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 80, kScreenWidth - 5, self.view.frame.size.height - 60) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor blackColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[QNMovieRoomListCell class] forCellWithReuseIdentifier:@"QNMovieRoomListCell"];
        [self.view addSubview:_collectionView];
    }
    return _collectionView;
}

- (void)conference {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
