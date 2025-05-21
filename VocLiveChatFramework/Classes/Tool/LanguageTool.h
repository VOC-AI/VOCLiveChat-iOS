//
//  LanguageTool.h
//  abc
//
//  Created by 刘志康 on 2025/3/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LanguageTool : NSObject
+ (NSString *)getStringForKey:(NSString *)key withLanguage:(NSString *)language;
@end

NS_ASSUME_NONNULL_END
