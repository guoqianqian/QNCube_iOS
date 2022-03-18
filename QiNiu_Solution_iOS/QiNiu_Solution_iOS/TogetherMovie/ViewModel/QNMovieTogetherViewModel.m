//
//  QNMovieTogetherViewModel.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/12/14.
//

#import "QNMovieTogetherViewModel.h"
#import <AFNetworking/AFNetworking.h>
#import "QNLoginViewController.h"

@implementation QNMovieTogetherViewModel

//建立转推任务

+ (void)requestCreateTrackWithParams:(NSDictionary *)params success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure {
    
    AFHTTPSessionManager *manager = [QNNetworkUtil manager];
    
    NSString *requestUrl = [[NSString alloc]initWithFormat:@"https://rtc.qiniuapi.com/v3/apps/%@/rooms/%@/pub?token=%@",[QNMovieTogetherViewModel getAppIdWithToken:params[@"roomToken"]],params[@"roomId"],params[@"roomToken"]];
    [manager POST:requestUrl parameters:params headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
        NSLog(@"\n POST \n action : %@ \n HTTPRequestHeaders:%@ \n params:%@ \n responseObject = %@",requestUrl,manager.requestSerializer.HTTPRequestHeaders,params,responseObject);
            success(responseObject ?: nil);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            failure(error);
            NSLog(@"\n POST \n action : %@ \n HTTPRequestHeaders:%@ \n params:%@ \n responseObject = %@",requestUrl,manager.requestSerializer.HTTPRequestHeaders,params,error);
        }];
}

+ (NSString *)getAppIdWithToken:(NSString *)token {
    
    NSArray *arr = [token componentsSeparatedByString:@":"];
    NSString *tokenDataStr = arr.lastObject;
    
    NSData *data = [[NSData alloc]initWithBase64EncodedString:tokenDataStr options:0];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    NSString *appId = dic[@"appId"];
    
    return appId;
}


//列出转推任务
+ (void)requestGetTrackWithParams:(NSDictionary *)params success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure {
    
    AFHTTPSessionManager *manager = [QNNetworkUtil manager];
    
    NSString *requestUrl = [[NSString alloc]initWithFormat:@"https://rtc.qiniuapi.com/v3/apps/%@/rooms/%@/pub?token=%@",[QNMovieTogetherViewModel getAppIdWithToken:params[@"roomToken"]],params[@"roomId"],params[@"roomToken"]];
    [manager GET:requestUrl parameters:params headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
        NSLog(@"\n GET \n action : %@ \n HTTPRequestHeaders:%@ \n params:%@ \n responseObject = %@",requestUrl,manager.requestSerializer.HTTPRequestHeaders,params,responseObject);
        
            success(responseObject ?: nil);
        
        
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            failure(error);
            NSLog(@"\n POST \n action : %@ \n HTTPRequestHeaders:%@ \n params:%@ \n responseObject = %@",requestUrl,manager.requestSerializer.HTTPRequestHeaders,params,error);
        }];
}

//删除转推任务
+ (void)requestDeleteTrackWithParams:(NSDictionary *)params success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure {
    
    AFHTTPSessionManager *manager = [QNNetworkUtil manager];
    
    NSString *requestUrl = [[NSString alloc]initWithFormat:@"https://rtc.qiniuapi.com/v3/apps/%@/rooms/%@/pub/%@?token=%@",[QNMovieTogetherViewModel getAppIdWithToken:params[@"roomToken"]],params[@"roomId"],params[@"taskID"],params[@"roomToken"]];
    
    [manager DELETE:requestUrl parameters:params headers:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"\n DELETE \n action : %@ \n HTTPRequestHeaders:%@ \n params:%@ \n responseObject = %@",requestUrl,manager.requestSerializer.HTTPRequestHeaders,params,responseObject);
            success(responseObject ?: nil);
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
        NSLog(@"\n POST \n action : %@ \n HTTPRequestHeaders:%@ \n params:%@ \n responseObject = %@",requestUrl,manager.requestSerializer.HTTPRequestHeaders,params,error);
    }];
}

//开始转推
+ (void)requestStartTrackWithParams:(NSDictionary *)params success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure {
    
    AFHTTPSessionManager *manager = [QNNetworkUtil manager];
    
    NSString *requestUrl = [[NSString alloc]initWithFormat:@"https://rtc.qiniuapi.com/v3/apps/%@/rooms/%@/pub/%@/start?token=%@",[QNMovieTogetherViewModel getAppIdWithToken:params[@"roomToken"]],params[@"roomId"],params[@"taskID"],params[@"roomToken"]];
    
    [manager POST:requestUrl parameters:params headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"\n POST \n action : %@ \n HTTPRequestHeaders:%@ \n params:%@ \n responseObject = %@",requestUrl,manager.requestSerializer.HTTPRequestHeaders,params,responseObject);
            success(responseObject ?: nil);
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
        NSLog(@"\n POST \n action : %@ \n HTTPRequestHeaders:%@ \n params:%@ \n responseObject = %@",requestUrl,manager.requestSerializer.HTTPRequestHeaders,params,error);
    }];
}

//停止转推
+ (void)requestStopTrackWithParams:(NSDictionary *)params success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure {
    
    AFHTTPSessionManager *manager = [QNNetworkUtil manager];
    
    NSString *requestUrl = [[NSString alloc]initWithFormat:@"https://rtc.qiniuapi.com/v3/apps/%@/rooms/%@/pub/%@/stop?token=%@",[QNMovieTogetherViewModel getAppIdWithToken:params[@"roomToken"]],params[@"roomId"],params[@"taskID"],params[@"roomToken"]];
    
    [manager POST:requestUrl parameters:params headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"\n POST \n action : %@ \n HTTPRequestHeaders:%@ \n params:%@ \n responseObject = %@",requestUrl,manager.requestSerializer.HTTPRequestHeaders,params,responseObject);
            success(responseObject ?: nil);
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
        NSLog(@"\n POST \n action : %@ \n HTTPRequestHeaders:%@ \n params:%@ \n responseObject = %@",requestUrl,manager.requestSerializer.HTTPRequestHeaders,params,error);
    }];
}

//设置Seek
+ (void)requestSeekWithParams:(NSDictionary *)params success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure {
    
    AFHTTPSessionManager *manager = [QNNetworkUtil manager];
    
    NSString *requestUrl = [[NSString alloc]initWithFormat:@"https://rtc.qiniuapi.com/v3/apps/%@/rooms/%@/pub/%@/seek?token=%@",[QNMovieTogetherViewModel getAppIdWithToken:params[@"roomToken"]],params[@"roomId"],params[@"taskID"],params[@"roomToken"]];
    
    [manager POST:requestUrl parameters:params headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"\n POST \n action : %@ \n HTTPRequestHeaders:%@ \n params:%@ \n responseObject = %@",requestUrl,manager.requestSerializer.HTTPRequestHeaders,params,responseObject);
            success(responseObject ?: nil);
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
        NSLog(@"\n POST \n action : %@ \n HTTPRequestHeaders:%@ \n params:%@ \n responseObject = %@",requestUrl,manager.requestSerializer.HTTPRequestHeaders,params,error);
    }];
}
@end
