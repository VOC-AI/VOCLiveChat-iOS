//
//  RandomStringGenerator.h
//  abc
//
//  Created by 刘志康 on 2025/3/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VocaiRandomStringGenerator : NSObject
+ (NSString *)randomStringWithLength:(NSUInteger)length;
@end

NS_ASSUME_NONNULL_END
