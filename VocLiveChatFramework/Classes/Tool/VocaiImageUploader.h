//
//  ImageUploader.h
//  abc
//
//  Created by 刘志康 on 2025/2/25.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// Define upload completion callback block
typedef void(^VocaiImageUploadCompletionBlock)(BOOL success, NSString * _Nullable message, NSDictionary * _Nullable response);

// Define upload progress callback block
typedef void(^VocaiImageUploadProgressBlock)(NSProgress *uploadProgress);

@interface VocaiImageUploader : NSObject

// Singleton method
+ (instancetype)sharedUploader;

/**
 上传图片的方法

 @param image 要上传的图片
 @param urlString 上传的 URL 字符串
 @param params 可选的参数
 @param progressBlock 上传进度回调
 @param completionBlock 上传完成回调
 */
- (void)uploadFile:(NSData *)fileData
          fileName:(NSString *)fileName
          fileType: (NSString *)fileType
            toURL:(NSString *)urlString
         withParams:(NSDictionary *)params
           progress:(VocaiImageUploadProgressBlock)progressBlock
        completion:(VocaiImageUploadCompletionBlock)completionBlock;

@end
