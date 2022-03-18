//
//  QNAlertViewController.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2022/3/16.
//

#import "QNAlertViewController.h"

@implementation QNAlertViewController

+ (void)showBaseAlertWithTitle:(NSString *)title content:(NSString *)content handler:(void (^ __nullable)(UIAlertAction *action))handler {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:content preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertController addAction:cancelBtn];
    
    UIAlertAction *changeBtn = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        handler(action);
    }];
    [alertController addAction:changeBtn];
    
    [[QNAlertViewController topViewController] presentViewController:alertController animated:YES completion:nil];
}



+ (UIViewController * )topViewController {
    UIViewController *resultVC;
    resultVC = [QNAlertViewController recursiveTopViewController:[[UIApplication sharedApplication].windows.firstObject rootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [QNAlertViewController recursiveTopViewController:resultVC.presentedViewController];
    }
    return resultVC;
}

+ (UIViewController * )recursiveTopViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [QNAlertViewController recursiveTopViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [QNAlertViewController recursiveTopViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
        return vc;
    }
    return nil;
}

@end
