//
//  RandomStringGenerator.m
//  abc
//
//  Created by VOC.AI on 2025/3/1.
//

#import "VocaiRandomStringGenerator.h"

@implementation VocaiRandomStringGenerator

+ (NSString *)randomStringWithLength:(NSUInteger)length {
    NSString *letters = @"0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity:length];
    
    for (NSUInteger i = 0; i < length; i++) {
        // 生成随机索引
        u_int32_t randomIndex = arc4random_uniform((u_int32_t)[letters length]);
        // Get character from set and append to random string
        unichar randomChar = [letters characterAtIndex:randomIndex];
        [randomString appendFormat:@"%C", randomChar];
    }
    
    return randomString;
}
@end
