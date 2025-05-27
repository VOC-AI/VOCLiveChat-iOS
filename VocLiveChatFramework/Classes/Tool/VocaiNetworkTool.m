//
//  NetworkTool.m
//  abc
//
//  Created by 刘志康 on 2025/2/24.
//

#import "VocaiNetworkTool.h"

@implementation VocaiNetworkTool

// 单例实现
+ (instancetype)sharedInstance {
    static VocaiNetworkTool *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

// 发起网络请求的方法实现
- (void)requestWithMethod:(RequestMethod)method
                  URLString:(NSString *)URLString
                 parameters:(NSDictionary *)parameters
                    success:(VocaiNetworkSuccessBlock)success
                    failure:(VocaiNetworkFailureBlock)failure {
    // 创建URL对象
    NSURL *url = [NSURL URLWithString:URLString];
    // 创建可变的请求对象
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];

    // 根据请求方法设置HTTP方法和处理参数
    if (method == VocaiRequestMethodGET) {
        request.HTTPMethod = @"GET";
        // 处理GET请求的参数
        if (parameters.count > 0) {
            NSMutableString *paramString = [NSMutableString string];
            [parameters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                if (paramString.length > 0) {
                    [paramString appendString:@"&"];
                }
                [paramString appendFormat:@"%@=%@", key, obj];
            }];
            NSString *fullURLString = [NSString stringWithFormat:@"%@?%@", URLString, paramString];
            request.URL = [NSURL URLWithString:fullURLString];
        }
    } else if (method == VocaiRequestMethodPOST) {
        request.HTTPMethod = @"POST";
        // 处理POST请求的参数
        if (parameters.count > 0) {
            NSError *error;
            NSData *postData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:&error];
            if (!error) {
                request.HTTPBody = postData;
                [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            } else {
                if (failure) {
                    failure(error);
                }
                return;
            }
        }
    }

    // 创建会话
    NSURLSession *session = [NSURLSession sharedSession];
    // 创建数据任务
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            if (failure) {
                failure(error);
            }
        } else {
            NSError *parseError;
            id responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&parseError];
            if (parseError) {
                if (failure) {
                    failure(parseError);
                }
            } else {
                if (success) {
                    success(responseObject);
                }
            }
        }
    }];
    // 启动任务
    [dataTask resume];
}

@end
