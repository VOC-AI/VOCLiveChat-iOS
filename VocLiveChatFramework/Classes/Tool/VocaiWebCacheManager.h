//
//  VocaiWebCacheManager.h
//  Pods
//
//  Created by Boyuan Gao on 2025/6/6.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VocaiWebCacheManager : NSObject <WKURLSchemeHandler>

@property (nonatomic, strong, readonly) WKWebViewConfiguration *configuration;

+ (instancetype)sharedManager;

/// 清空所有缓存
- (void)clearAllCaches;

/// 检查是否存在特定路径的缓存
- (BOOL)hasCacheForPath:(NSString *)path;

/// 获取特定路径的缓存数据
- (nullable NSData *)cachedDataForPath:(NSString *)path;

@end

NS_ASSUME_NONNULL_END    
