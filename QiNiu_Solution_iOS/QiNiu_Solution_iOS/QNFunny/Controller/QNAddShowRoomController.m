//
//  QNAddShowRoomController.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/11/3.
//

#import "QNAddShowRoomController.h"
#import <Masonry/Masonry.h>
#import <YYCategories/YYCategories.h>
#import "QNNetworkUtil.h"
#import <MJExtension/MJExtension.h>
#import "QNRoomDetailModel.h"
#import "QNShowRoomController.h"

@interface QNAddShowRoomController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (nonatomic, strong) UIImageView *imageview;

@property (nonatomic, strong) UILabel *label;

@property (nonatomic, strong) UILabel *nameTitleLabel;

@property (nonatomic, strong) UITextField *nameTf;

@property (nonatomic, strong) UILabel *commendLabel;

@property (nonatomic, strong) UITextField *commendTf;

@property (nonatomic, strong) UIButton *button;

@property (nonatomic, strong) NSString *imageStr;

@end

@implementation QNAddShowRoomController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    [self setupUI];
}

- (void)setupUI {
    
    [self imageview];
    
    [self label];
    
    [self nameTitleLabel];
    
    [self nameTf];
    
    [self commendLabel];
    
    [self commendTf];
    
    [self button];
}

- (void)createRoom {
    
    NSMutableDictionary *requestParams = [NSMutableDictionary dictionary];
    requestParams[@"title"] = self.nameTf.text;
    requestParams[@"desc"] = self.commendTf.text;
    requestParams[@"type"] = @"show";
//    requestParams[@"image"] = self.imageStr;
    
    
    [QNNetworkUtil postRequestWithAction:@"base/createRoom" params:requestParams success:^(NSDictionary *responseData) {
        
        QNRoomDetailModel *model = [QNRoomDetailModel mj_objectWithKeyValues:responseData];
        
        QNShowRoomController *vc = [QNShowRoomController new];
        vc.model = model;
        vc.model.userInfo.role = @"roomHost";
        [self.navigationController pushViewController:vc animated:YES];
            
        } failure:^(NSError *error) {
            
            QNShowRoomController *vc = [QNShowRoomController new];
            vc.model = [QNRoomDetailModel new];
            QNUserInfo *userInfo = [QNUserInfo new];
            userInfo.role = @"roomHost";
            vc.model.userInfo = userInfo;
            vc.modalPresentationStyle = UIModalPresentationFullScreen;
            [self.navigationController pushViewController:vc animated:YES];
            
        }];
}

- (void)selectImage {
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"上传" message:@"选择图片的方式" preferredStyle:UIAlertControllerStyleActionSheet];
        [alertVC addAction:[UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UIImagePickerController *pickVC = [[UIImagePickerController alloc] init];
            pickVC.delegate = self;
            pickVC.allowsEditing = YES;
            pickVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:pickVC animated:YES completion:nil];
        }]];
        [alertVC addAction:[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            UIImagePickerController *pickVC = [[UIImagePickerController alloc] init];
            pickVC.delegate = self;
            pickVC.allowsEditing = YES;
            pickVC.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:pickVC animated:YES completion:nil];
        }]];
        [alertVC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alertVC animated:YES completion:nil];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    self.imageview.image = image;
    self.imageStr = [self base64StringByImage:image scaleWidth:200];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (UIImage*)compressImage:(UIImage*)sourceImage toTargetWidth:(CGFloat)targetWidth {
    //获取原图片的大小尺寸
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    //根据目标图片的宽度计算目标图片的高度
    CGFloat targetHeight = (targetWidth / width) * height;
    //开启图片上下文
    UIGraphicsBeginImageContext(CGSizeMake(targetWidth, targetHeight));
    //绘制图片
    [sourceImage drawInRect:CGRectMake(0,0, targetWidth, targetHeight)];
    //从上下文中获取绘制好的图片
    UIImage*newImage = UIGraphicsGetImageFromCurrentImageContext();
    //关闭图片上下文
    UIGraphicsEndImageContext();
    
    return newImage;
}

/// 图片转base64编码
/// @param image 图片
- (NSString *)base64StringByImage:(UIImage *)image scaleWidth:(NSInteger)scaleWidth{
    UIImage *resultImage = [self compressImage:image toTargetWidth:scaleWidth];
    NSData *data = UIImageJPEGRepresentation(resultImage, 0.000001);
    NSString *encodedImageStr = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return encodedImageStr;
}

- (UIImageView *)imageview {
    if (!_imageview) {
        _imageview = [[UIImageView alloc]init];
        _imageview.backgroundColor = [UIColor lightGrayColor];
        _imageview.clipsToBounds = YES;
        _imageview.layer.cornerRadius = 60;
        [self.view addSubview:_imageview];
        
        _imageview.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selectImage)];
        [_imageview addGestureRecognizer:tap];
        
        [_imageview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.width.height.mas_equalTo(120);
            make.top.equalTo(self.view).offset(100);
        }];
    }
    return _imageview;
}

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc]init];
        _label.text = @"点击上传封面";
        _label.textColor = [UIColor lightGrayColor];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.font = [UIFont systemFontOfSize:14];
        [self.view addSubview:_label];
        
        [_label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.imageview);
            make.top.equalTo(self.imageview.mas_bottom).offset(10);
        }];
    }
    return _label;
}

- (UILabel *)nameTitleLabel {
    if (!_nameTitleLabel) {
        _nameTitleLabel = [[UILabel alloc]init];
        _nameTitleLabel.text = @"房间名称";
        [self.view addSubview:_nameTitleLabel];
        
        [_nameTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.label.mas_bottom).offset(30);
            make.left.equalTo(self.view).offset(40);
        }];
    }
    return _nameTitleLabel;
}

- (UITextField *)nameTf {
    if (!_nameTf) {
        _nameTf = [[UITextField alloc]init];
        _nameTf.placeholder = @"给你的房间取个好听的名字";
        [self.view addSubview:_nameTf];
        
        [_nameTf mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.nameTitleLabel);
            make.top.equalTo(self.nameTitleLabel.mas_bottom).offset(20);
            make.right.equalTo(self.view).offset(-40);
            make.height.mas_equalTo(35);
        }];
    }
    return _nameTf;
}

- (UILabel *)commendLabel {
    if (!_commendLabel) {
        _commendLabel = [[UILabel alloc]init];
        _commendLabel.text = @"房间公告";
        [self.view addSubview:_commendLabel];
        
        [_commendLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.nameTf.mas_bottom).offset(20);
            make.left.equalTo(self.view).offset(40);
        }];
    }
    return _commendLabel;
}

- (UITextField *)commendTf {
    if (!_commendTf) {
        _commendTf = [[UITextField alloc]init];
        _commendTf.placeholder = @"给你的房间取个好听的公告";
        [self.view addSubview:_commendTf];
        
        [_commendTf mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.commendLabel);
            make.top.equalTo(self.commendLabel.mas_bottom).offset(20);
            make.right.equalTo(self.view).offset(-40);
            make.height.mas_equalTo(35);
        }];
    }
    return _commendTf;
}

- (UIButton *)button {
    if (!_button) {
        _button = [[UIButton alloc]init];
        [_button setTitle:@"创建房间" forState:UIControlStateNormal];
        [_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _button.titleLabel.font = [UIFont systemFontOfSize:16];
        _button.backgroundColor = [UIColor colorWithHexString:@"007AFF"];
        _button.layer.cornerRadius = 8;
        _button.clipsToBounds = YES;
        [self.view addSubview:_button];
        [_button addTarget:self action:@selector(createRoom) forControlEvents:UIControlEventTouchUpInside];
        
        [_button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.left.equalTo(self.view).offset(40);
            make.top.equalTo(self.commendTf.mas_bottom).offset(50);
            make.height.mas_equalTo(45);
        }];
    }
    return _button;
}

@end
