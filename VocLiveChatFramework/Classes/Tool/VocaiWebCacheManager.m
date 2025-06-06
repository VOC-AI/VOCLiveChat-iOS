//
//  VocaiWebCacheManager.m
//  Pods
//
//  Created by Boyuan Gao on 2025/6/6.
//

#import "VocaiWebCacheManager.h"
#import "VocaiSHA256.h"

#define kLiveChatPathComponent @"live-chat"
#define kShulexCDNDomain1 @"cdn.shulex-voc.com"
#define kShulexCDNDomain2 @"cdn.shulex-tech.com"

#define SHA256_DIGEST_LENGTH 32

@interface VocaiWebCacheManager ()

@property (nonatomic, strong) NSCache *memoryCache;
@property (nonatomic, strong) NSURL *cacheDirectory;

@end

@implementation VocaiWebCacheManager

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static VocaiWebCacheManager *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _memoryCache = [[NSCache alloc] init];
        _memoryCache.countLimit = 100; // 限制缓存数量
        
        // 设置磁盘缓存目录
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *cachesDirectory = [fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask].firstObject;
        _cacheDirectory = [cachesDirectory URLByAppendingPathComponent:@"VocaiWebCache" isDirectory:YES];
        
        // 创建缓存目录（如果不存在）
        NSError *error;
        if (![fileManager fileExistsAtPath:[_cacheDirectory path]]) {
            [fileManager createDirectoryAtURL:_cacheDirectory withIntermediateDirectories:YES attributes:nil error:&error];
            if (error) {
                NSLog(@"创建缓存目录失败: %@", error.localizedDescription);
            }
        }
        
        // 配置WKWebViewConfiguration
        _configuration = [[WKWebViewConfiguration alloc] init];
        if (@available(iOS 11.0, *)) {
            [_configuration setURLSchemeHandler:self forURLScheme:@"vocai-cache"];
        } else {
        }
        
        // 设置自定义资源加载器
        WKProcessPool *processPool = [[WKProcessPool alloc] init];
        _configuration.processPool = processPool;
    }
    return self;
}

#pragma mark - 文件操作

- (NSURL *)fileURLForPath:(NSString *)path {
    NSString *fileName = [self fileNameForPath:path];
    return [self.cacheDirectory URLByAppendingPathComponent:fileName];
}

- (NSString *)fileNameForPath:(NSString *)path {
    // 使用SHA-256哈希作为文件名，避免特殊字符问题
    return [VocaiSHA256 hashString:path];
}

- (void)saveData:(NSData *)data forPath:(NSString *)path {
    // 保存到内存缓存
    [self.memoryCache setObject:data forKey:path];
    
    // 保存到磁盘缓存
    NSURL *fileURL = [self fileURLForPath:path];
    NSError *error;
    [data writeToURL:fileURL options:NSDataWritingAtomic error:&error];
    if (error) {
        NSLog(@"保存缓存失败: %@, Path: %@", error.localizedDescription, path);
    }
}

#pragma mark - 公共方法

- (void)clearAllCaches {
    // 清空内存缓存
    [self.memoryCache removeAllObjects];
    
    // 清空磁盘缓存
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    if ([fileManager fileExistsAtPath:[self.cacheDirectory path]]) {
        [fileManager removeItemAtURL:self.cacheDirectory error:&error];
        if (error) {
            NSLog(@"清空缓存失败: %@", error.localizedDescription);
        } else {
            // 重新创建目录
            [fileManager createDirectoryAtURL:self.cacheDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
}

- (BOOL)hasCacheForPath:(NSString *)path {
    // 先检查内存缓存
    if ([self.memoryCache objectForKey:path]) {
        return YES;
    }
    
    // 再检查磁盘缓存
    NSURL *fileURL = [self fileURLForPath:path];
    return [[NSFileManager defaultManager] fileExistsAtPath:[fileURL path]];
}

- (nullable NSData *)cachedDataForPath:(NSString *)path {
    // 先从内存缓存获取
    NSData *data = [self.memoryCache objectForKey:path];
    if (data) {
        return data;
    }
    
    // 再从磁盘缓存获取
    NSURL *fileURL = [self fileURLForPath:path];
    NSError *error;
    data = [NSData dataWithContentsOfURL:fileURL options:0 error:&error];
    if (data) {
        // 同时存入内存缓存
        [self.memoryCache setObject:data forKey:path];
    } else if (error) {
        NSLog(@"读取缓存失败: %@, Path: %@", error.localizedDescription, path);
    }
    return data;
}

#pragma mark - WKURLSchemeHandler

- (void)webView:(WKWebView *)webView startURLSchemeTask:(id<WKURLSchemeTask>)urlSchemeTask {
    NSURL *url = urlSchemeTask.request.URL;
    NSString *originalURLString = [url absoluteString];
    // 移除自定义协议前缀，获取原始URL
    originalURLString = [originalURLString stringByReplacingOccurrencesOfString:@"vocai-cache://" withString:@""];
    NSURL *originalURL = [NSURL URLWithString:originalURLString];
    
    // 检查是否有缓存
    NSString *path = originalURL.path;
    if ([self hasCacheForPath:path]) {
        NSData *data = [self cachedDataForPath:path];
        if (data) {
            // 使用缓存数据响应
            NSURLResponse *response = [[NSURLResponse alloc] initWithURL:url
                                                                  MIMEType:[self mimeTypeForPath:path]
                                                     expectedContentLength:data.length
                                                          textEncodingName:nil];
            [urlSchemeTask didReceiveResponse:response];
            [urlSchemeTask didReceiveData:data];
            [urlSchemeTask didFinish];
            
            // 同时发起刷新请求
            [self refreshCacheForURL:originalURL];
            return;
        }
    }
    
    // 没有缓存或缓存获取失败，直接请求原始URL
    [self forwardRequest:urlSchemeTask originalURL:originalURL];
}

- (void)webView:(WKWebView *)webView stopURLSchemeTask:(id<WKURLSchemeTask>)urlSchemeTask {
    // 停止任务，无需实现具体逻辑
}

#pragma mark - 请求处理

- (void)forwardRequest:(id<WKURLSchemeTask>)urlSchemeTask originalURL:(NSURL *)originalURL {
    NSURLRequest *request = [NSURLRequest requestWithURL:originalURL];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            [urlSchemeTask didFailWithError:error];
            return;
        }
        
        if (data && response) {
            // 缓存特定资源
            [self cacheResponseData:data forURL:originalURL response:response];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [urlSchemeTask didReceiveResponse:response];
                [urlSchemeTask didReceiveData:data];
                [urlSchemeTask didFinish];
            });
        }
    }];
    [task resume];
}

- (void)refreshCacheForURL:(NSURL *)url {
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data && response && !error) {
            [self cacheResponseData:data forURL:url response:response];
        }
    }];
    [task resume];
}

#pragma mark - 缓存管理

- (void)cacheResponseData:(NSData *)data forURL:(NSURL *)url response:(NSURLResponse *)response {
    // 只缓存特定路径和域名的资源
    if ([self shouldCacheURL:url]) {
        NSString *path = url.path;
        [self saveData:data forPath:path];
    }
}

- (BOOL)shouldCacheURL:(NSURL *)url {
    if (!url) return NO;
    
    // 缓存包含"live-chat"的路径
    if ([url.path containsString:kLiveChatPathComponent]) {
        return YES;
    }
    
    // 缓存特定CDN域名的资源
    NSString *host = url.host;
    if ([host containsString:kShulexCDNDomain1] || [host containsString:kShulexCDNDomain2]) {
        return YES;
    }
    
    return NO;
}

- (NSString *)mimeTypeForPath:(NSString *)path {
    if ([path hasSuffix:@".html"] || [path hasSuffix:@".htm"]) {
        return @"text/html";
    } else if ([path hasSuffix:@".js"]) {
        return @"application/javascript";
    } else if ([path hasSuffix:@".css"]) {
        return @"text/css";
    } else if ([path hasSuffix:@".png"]) {
        return @"image/png";
    } else if ([path hasSuffix:@".jpg"] || [path hasSuffix:@".jpeg"]) {
        return @"image/jpeg";
    } else if ([path hasSuffix:@".json"]) {
        return @"application/json";
    }
    return @"application/octet-stream";
}

@end
