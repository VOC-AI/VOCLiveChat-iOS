//
//  PollingRequestTool.h
//  abc
//
//  Created by 刘志康 on 2025/3/2.
//

#import <Foundation/Foundation.h>

// 定义请求成功和失败的回调块
typedef void (^PollingSuccessBlock)(NSData * _Nullable data, NSDictionary * _Nullable response);
typedef void (^PollingFailureBlock)(NSError * _Nullable error);

@interface VocaiPollingRequestTool : NSObject

// 启动轮询请求
- (void)startPollingWithURL:(NSURL *)url interval:(NSTimeInterval)interval success:(PollingSuccessBlock)success failure:(PollingFailureBlock)failure;

// 停止轮询请求
- (void)stopPolling;

@end
