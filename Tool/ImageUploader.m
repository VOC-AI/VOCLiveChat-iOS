//
//  ImageUploader.m
//  abc
//
//  Created by 刘志康 on 2025/2/25.
//

#import "ImageUploader.h"

@interface ImageUploader ()

@end

@implementation ImageUploader

// 单例实现
+ (instancetype)sharedUploader {
    static ImageUploader *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)uploadFile:(NSData *)fileData
          fileName:(NSString *)fileName
          fileType: (NSString *)fileType
            toURL:(NSString *)urlString
         withParams:(NSDictionary * _Nullable)params
           progress:(UploadProgressBlock)progressBlock
         completion:(UploadCompletionBlock)completionBlock {
    // 检查 URL 字符串是否有效
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) {
        if (completionBlock) {
            completionBlock(NO, @"无效的 URL", nil);
        }
        return;
    }
    
    // 创建请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    // 设置请求头
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    // 构建请求体
    NSMutableData *body = [NSMutableData data];
    
    // 添加可选参数
    if (params) {
        for (NSString *key in params) {
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[params[key] description] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@\"\r\n", fileName] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", fileType] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:fileData];
//    image/jpeg。application/pdf
//    video/x-msvideo
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:body];
    
    // 创建会话
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request fromData:body completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (completionBlock) {
            if (error) {
                completionBlock(NO, [error localizedDescription], nil);
            } else {
                NSError *jsonError;
                NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
                if (jsonError) {
                    completionBlock(NO, @"解析响应数据失败", nil);
                } else {
                    completionBlock(YES, @"上传成功", responseDict);
                }
            }
        }
    }];
    
    // 设置上传进度回调
//    if (progressBlock) {
//        [uploadTask setTaskDescription:@"Image Upload Task"];
//        [uploadTask observeValueForKeyPath:@"progress" ofObject:uploadTask options:NSKeyValueObservingOptionNew context:NULL];
//        [uploadTask resume];
//        uploadTask.progress.completionHandler = ^(BOOL completed, NSError * _Nullable error) {
//            if (completed) {
//                [uploadTask removeObserver:self forKeyPath:@"progress"];
//            }
//        };
//        uploadTask.progress.cancellationHandler = ^{
//            [uploadTask removeObserver:self forKeyPath:@"progress"];
//        };
//        uploadTask.progress.pausingHandler = ^{
//            [uploadTask removeObserver:self forKeyPath:@"progress"];
//        };
//    } else {
        [uploadTask resume];
//    }
}

@end
