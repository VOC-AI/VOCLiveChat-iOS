//
//  LanguageTool.m
//  abc
//
//  Created by VOC.AI on 2025/3/4.
//

#import "VocaiLanguageTool.h"

@implementation VocaiLanguageTool

+ (NSString *)getStringForKey:(NSString *)key withLanguage:(NSString *)language {
    // Read JSON file
    // Get current framework bundle
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
    
    // Get entities array
    NSArray *entities = jsonDict[@"entities"];
    if (!entities) {
        NSLog(@"No 'entities' array found in JSON.");
        return nil;
    }
    
    // Traverse entities array to find matching language
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
    // Get app preferred language (matches UI display language)
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
