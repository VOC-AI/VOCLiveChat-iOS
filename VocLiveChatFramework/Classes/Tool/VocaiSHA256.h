//
//  VocaiSHA256.h
//  Pods
//
//  Created by Boyuan Gao on 2025/6/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VocaiSHA256 : NSObject

// 计算字符串的SHA256哈希值
+ (NSString *)hashString:(NSString *)string;

// 计算NSData的SHA256哈希值
+ (NSString *)hashData:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
