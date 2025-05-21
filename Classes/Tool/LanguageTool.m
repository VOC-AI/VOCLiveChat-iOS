//
//  LanguageTool.m
//  abc
//
//  Created by 刘志康 on 2025/3/4.
//

#import "LanguageTool.h"

@implementation LanguageTool

+ (NSString *)getStringForKey:(NSString *)key withLanguage:(NSString *)language {
    // 读取JSON文件
    // 获取当前 framework 的 bundle
    NSBundle *frameworkBundle = [NSBundle bundleForClass:[self class]];

    NSString *filePath = [frameworkBundle pathForResource:@"Localizable" ofType:@"json"];
    NSString* defaultLang = @"en";
    if (!filePath) {
        NSLog(@"未找到语言包JSON文件, [[NSBundle mainBundle] pathForResource:@\"language\" ofType:@\"json\"]");
        return nil;
    }
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    if (!data) {
        NSLog(@"Failed to read JSON file.");
        return nil;
    }
    
    NSError *error;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (error) {
        NSLog(@"Failed to parse JSON: %@", error.localizedDescription);
        return nil;
    }
    
    // 获取 entities 数组
    NSArray *entities = jsonDict[@"entities"];
    if (!entities) {
        NSLog(@"No 'entities' array found in JSON.");
        return nil;
    }
    
    // 遍历 entities 数组，查找匹配的语言
    for (NSDictionary *entity in entities) {
        NSString *entityLanguage = entity[@"language"];
        if ([entityLanguage isEqualToString:language]) {
            NSDictionary *strings = entity[@"strings"];
            if (strings) {
                return strings[key];
            }
            break;
        }
    }
    
    NSLog(@"No matching language found for %@. Using 'en'", language);
    
    for (NSDictionary *entity in entities) {
        NSString *entityLanguage = entity[@"language"];
        if ([entityLanguage isEqualToString:defaultLang]) {
            NSDictionary *strings = entity[@"strings"];
            if (strings) {
                return strings[key];
            }
            break;
        }
    }
    
    return nil;
}
@end
