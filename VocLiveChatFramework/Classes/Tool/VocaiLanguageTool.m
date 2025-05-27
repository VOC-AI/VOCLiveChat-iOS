//
//  LanguageTool.m
//  abc
//
//  Created by 刘志康 on 2025/3/4.
//

#import "VocaiLanguageTool.h"

@implementation VocaiLanguageTool

+ (NSString *)getStringForKey:(NSString *)key withLanguage:(NSString *)language {
    // 读取JSON文件
    // 获取当前 framework 的 bundle
    NSString* defaultLang = @"en";
    NSBundle *frameworkBundle = [NSBundle bundleForClass:[self class]];
    NSDictionary* dict = @{
        @"en-US": @"en",
        @"zh-CN":@"cn",
        @"ja-JP":@"ja",
        @"fr-FR":@"fr",
        @"de-DE":@"de",
        @"pt-PT":@"pt",
        @"es-ES":@"es",
        @"jp":@"ja",
        @"ar":@"ar",
    };
    NSString* normalizedLang = dict[language];
    if(!normalizedLang) {
        normalizedLang = language;
    }
    
    NSString *filePath = [frameworkBundle pathForResource:@"Localizable" ofType:@"json"];

    if(!filePath) {
        NSString *bundlePath = [frameworkBundle pathForResource:@"VocLiveChatFramework" ofType:@"bundle"];
        NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
        filePath = [bundle pathForResource:@"Localizable" ofType:@"json"];
    }

    if (!filePath) {
        NSLog(@"Localizable.json file not found.");
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
        if ([entityLanguage isEqualToString:normalizedLang]) {
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
