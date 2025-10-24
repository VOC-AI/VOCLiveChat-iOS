//
//  ImageUploader.m
//  abc
//
//  Created by VOC.AI on 2025/2/25.
//

#import "VocaiImageUploader.h"

@interface VocaiImageUploader ()

@end

@implementation VocaiImageUploader

// Singleton implementation
+ (instancetype)sharedUploader {
    static VocaiImageUploader *sharedInstance = nil;
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
           progress:(VocaiImageUploadProgressBlock)progressBlock
         completion:(VocaiImageUploadCompletionBlock)completionBlock {
    // Validate URL string
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) {
        if (completionBlock) {
            completionBlock(NO, @"Invalid URL", nil);
        }
        return;
    }
    
    // Create request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    // Set request headers
    // Use a unique boundary per request to avoid collisions and intermediate proxies mistaking multipart data.
    // Do not include leading dashes here; the body builder emits the required "--" prefix.
    NSString *boundary = [NSString stringWithFormat:@"VocaiBoundary-%@", [[NSUUID UUID] UUIDString]];
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    // Build request body
    NSMutableData *body = [NSMutableData data];
    
    // Add optional parameters
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
    // Include the content type for the uploaded file part so the server can detect the media type
    [body appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n", fileType] dataUsingEncoding:NSUTF8StringEncoding]];
    // It's common to set binary transfer for file parts
    [body appendData:[@"Content-Transfer-Encoding: binary\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:fileData];
//    image/jpeg。application/pdf
//    video/x-msvideo
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:body];
    
    // Create session
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request fromData:body completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // Build debug info: HTTP status and raw response string
        NSInteger statusCode = 0;
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = ((NSHTTPURLResponse *)response).statusCode;
        }
        NSString *rawResponse = nil;
        if (data && data.length > 0) {
            rawResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if (!rawResponse) {
                rawResponse = [NSString stringWithFormat:@"<non-utf8 data, %lu bytes>", (unsigned long)data.length];
            }
        } else {
            rawResponse = @"";
        }

        if (completionBlock) {
            if (error) {
                // include status and rawResponse to help debugging
                NSDictionary *errInfo = @{@"status": @(statusCode), @"raw": rawResponse};
                completionBlock(NO, [error localizedDescription], errInfo);
            } else {
                NSError *jsonError = nil;
                NSDictionary *responseDict = nil;
                if (data && data.length > 0) {
                    responseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
                }
                // If JSON parse failed, still return raw response for inspection
                if (jsonError || !responseDict) {
                    NSDictionary *info = @{@"status": @(statusCode), @"raw": rawResponse};
                    completionBlock(NO, @"解析响应数据失败", info);
                } else {
                    // augment parsed JSON with status and raw for completeness
                    NSMutableDictionary *aug = [responseDict mutableCopy] ?: [NSMutableDictionary dictionary];
                    aug[@"status"] = @(statusCode);
                    aug[@"raw"] = rawResponse ?: @"";
                    completionBlock(YES, @"Upload successful", [aug copy]);
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
