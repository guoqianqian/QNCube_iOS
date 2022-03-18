//
//  QNFunnyListController.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/11/2.
//

#import "QNFunnyListController.h"
#import <YYCategories/YYCategories.h>
#import "QNFunnyListCell.h"
#import "QNAddShowRoomController.h"
#import "QNShowRoomController.h"
#import "QNRoomDetailModel.h"
#import "QNNetworkUtil.h"
#import "QNRoomDetailModel.h"
#import <MJExtension/MJExtension.h>


@interface QNFunnyListController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) QNRoomDetailModel *model;

@property (nonatomic, strong) NSArray <QNRoomInfo *> *rooms;

@end

@implementation QNFunnyListController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
//    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"房间列表";
    [self collectionView];
    [self requestData];
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_increase"] style:UIBarButtonItemStyleDone target:self action:@selector(addShowRoom)];
    self.navigationItem.rightBarButtonItem = addButton;
}

- (void)requestData {
        
    NSMutableDictionary *requestParams = [NSMutableDictionary dictionary];

    requestParams[@"type"] = @"show";
    
    [QNNetworkUtil getRequestWithAction:@"base/listRoom" params:requestParams success:^(NSDictionary *responseData) {
            
        self.rooms = [QNRoomInfo mj_objectArrayWithKeyValuesArray:responseData[@"list"]];
        [self.collectionView reloadData];
        
        } failure:^(NSError *error) {
            
        }];
}

- (void)addShowRoom {
    
    QNAddShowRoomController *vc = [QNAddShowRoomController new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.rooms.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    QNFunnyListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"QNFunnyListCell" forIndexPath:indexPath];
    [cell updateWithModel:self.rooms[indexPath.item]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    QNRoomDetailModel *model = [QNRoomDetailModel new];
    
    QNShowRoomController *vc = [QNShowRoomController new];
    vc.model = model;
    vc.model.roomInfo = self.rooms[indexPath.item];
    QNUserInfo *userInfo = [QNUserInfo new];
    userInfo.role = @"roomAudience";
    vc.model.userInfo = userInfo;
    [self.navigationController pushViewController:vc animated:YES];
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.minimumLineSpacing = 10;
        layout.minimumInteritemSpacing = 10;
        layout.itemSize = CGSizeMake((kScreenWidth - 15)/2, (kScreenWidth - 15)/2);
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;

        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth - 5, self.view.frame.size.height) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[QNFunnyListCell class] forCellWithReuseIdentifier:@"QNFunnyListCell"];
        [self.view addSubview:_collectionView];
    }
    return _collectionView;
}

@end
