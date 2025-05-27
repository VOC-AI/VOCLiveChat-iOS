//
//  RandomStringGenerator.m
//  abc
//
//  Created by 刘志康 on 2025/3/1.
//

#import "VocaiRandomStringGenerator.h"

@implementation VocaiRandomStringGenerator

+ (NSString *)randomStringWithLength:(NSUInteger)length {
    NSString *letters = @"0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity:length];
    
    for (NSUInteger i = 0; i < length; i++) {
        // 生成随机索引
        u_int32_t randomIndex = arc4random_uniform((u_int32_t)[letters length]);
        // 从字符集中取出对应字符添加到随机字符串中
        unichar randomChar = [letters characterAtIndex:randomIndex];
        [randomString appendFormat:@"%C", randomChar];
    }
    
    return randomString;
}
@end
