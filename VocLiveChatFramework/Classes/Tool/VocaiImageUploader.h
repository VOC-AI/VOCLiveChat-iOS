//
//  ImageUploader.h
//  abc
//
//  Created by VOC.AI on 2025/2/25.
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
  Upload file method

 @param fileData File data to upload
 @param fileName Name of the file
 @param fileType Type of the file
 @param urlString Upload URL string
 @param params Optional parameters
 @param progressBlock Upload progress callback
 @param completionBlock Upload completion callback
 */
- (void)uploadFile:(NSData *)fileData
          fileName:(NSString *)fileName
          fileType: (NSString *)fileType
            toURL:(NSString *)urlString
         withParams:(NSDictionary *)params
           progress:(VocaiImageUploadProgressBlock)progressBlock
        completion:(VocaiImageUploadCompletionBlock)completionBlock;

@end
