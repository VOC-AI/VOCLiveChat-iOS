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
    NSString* defaultLang = [self normalizeForSDK:[self defaultLang]];
    NSBundle *frameworkBundle = [NSBundle bundleForClass:[self class]];
    NSString* normalizedLang = [self normalizeForSDK:language];
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
    
    NSLog(@"No matching language found for %@. Using system default '%@'", language, defaultLang);
    
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
    
    NSLog(@"No matching language found for %@. Using system default 'en'", language);
    
    for (NSDictionary *entity in entities) {
        NSString *entityLanguage = entity[@"language"];
        if ([entityLanguage isEqualToString:@"en"]) {
            NSDictionary *strings = entity[@"strings"];
            if (strings) {
                return strings[key];
            }
            break;
        }
    }
    return nil;
}

+(NSString*) defaultLang {
    // 获取应用首选语言（与界面显示语言一致）
    NSArray *preferredLanguages = [NSBundle mainBundle].preferredLocalizations;
    if (preferredLanguages.count > 0) {
        return [preferredLanguages firstObject];
    }
    
    // 回退到系统语言
    NSString* systemLang = [[NSLocale preferredLanguages] firstObject];
    if (!systemLang) {
        return @"en-US";
    }
    return systemLang;
}


+(NSString*) normalizeForSDK:(NSString*)lang {
    static NSDictionary* dict;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dict = @{
            @"en-US": @"en",
            @"zh-CN":@"cn",
            @"ja-JP":@"ja",
            @"fr-FR":@"fr",
            @"de-DE":@"de",
            @"pt-PT":@"pt",
            @"es-ES":@"es",
            @"ko-KR":@"ko",
            @"it-IT":@"it",
            @"zh": @"cn",
            @"zh-Hant":@"zh-hk",
            @"zh-Hant-HK":@"zh-hk",
            @"zh-Hant-TW":@"zh-hk",
            @"jp":@"ja",
            @"ar":@"ar",
        };
    });
    NSString* tar = dict[lang];
    if (!tar) {
        return lang;
    }
    return tar;
}

@end
