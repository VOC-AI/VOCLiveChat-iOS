//
//  NetworkTool.h
//  abc
//
//  Created by 刘志康 on 2025/2/24.
//
#import <Foundation/Foundation.h>

// 定义请求方法枚举
typedef NS_ENUM(NSUInteger, RequestMethod) {
    VocaiRequestMethodGET,
    VocaiRequestMethodPOST
};

// 定义请求成功回调
typedef void(^VocaiNetworkSuccessBlock)(id responseObject);
// 定义请求失败回调
typedef void(^VocaiNetworkFailureBlock)(NSError *error);

@interface VocaiNetworkTool : NSObject

// 单例方法
+ (instancetype)sharedInstance;

// 发起网络请求的方法
- (void)requestWithMethod:(RequestMethod)method
                  URLString:(NSString *)URLString
                 parameters:(NSDictionary *)parameters
                    success:(VocaiNetworkSuccessBlock)success
                    failure:(VocaiNetworkFailureBlock)failure;

@end
