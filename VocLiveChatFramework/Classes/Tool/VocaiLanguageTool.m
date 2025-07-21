//
//  LanguageTool.m
//  abc
//
//  Created by VOC.AI on 2025/3/4.
//

#import "VocaiLanguageTool.h"

@interface VocaiLanguageTool()

@property(nonatomic, copy) NSDictionary<NSString*, NSDictionary<NSString*, NSString*>*>* i18nTable;

+(instancetype) sharedInstance;

@end

@implementation VocaiLanguageTool

- (NSDictionary*) getDefaultTable {
    NSBundle *frameworkBundle = [NSBundle bundleForClass:[self class]];
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
    
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    for (NSDictionary *entity in entities) {
        NSString *language = entity[@"language"];
        NSDictionary *strings = entity[@"strings"];
        
        if ([language isKindOfClass:[NSString class]] &&
            [strings isKindOfClass:[NSDictionary class]]) {
            result[language] = strings;
        } else {
            NSLog(@"Invalid entity format: missing 'language' or 'strings'");
        }
    }
    return [result copy];
}

+ (NSString *)getStringForKey:(NSString *)key withLanguage:(NSString *)language {
    return [[VocaiLanguageTool sharedInstance] getStringForKey:key withLanguage:language];
}

- (NSString *)getStringForKey:(NSString *)key withLanguage:(NSString *)language {
    // Read JSON file
    // Get current framework bundle
    NSString* defaultLang = [VocaiLanguageTool normalizeForSDK:[VocaiLanguageTool defaultLang]];
    NSString* normalizedLang = [VocaiLanguageTool normalizeForSDK:language];
    if(!normalizedLang) {
        normalizedLang = language;
    }
    
    NSDictionary *strings = self.i18nTable [normalizedLang];
    if (strings[key]) {
        return strings[key];
    }
    NSLog(@"No matching language found for %@. Using system default '%@'", language, defaultLang);
    strings = self.i18nTable[defaultLang];
    if (strings[key]) {
        return strings[key];
    }
    
    NSLog(@"No matching language found for %@. Using system default 'en'", language);
    strings = [VocaiLanguageTool sharedInstance].i18nTable[@"en"];
    if (strings[key]) {
        return strings[key];
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


+ (NSDictionary *)mergeLocalizationTable:(NSDictionary *)originalTable
                              withNewTable:(NSDictionary *)newTable {
    if (![originalTable isKindOfClass:[NSDictionary class]] || originalTable.count == 0) {
        return [newTable copy];
    }
    
    NSMutableDictionary *mergedTable = [originalTable mutableCopy];
    
    for (NSString *language in newTable.allKeys) {
        if (![language isKindOfClass:[NSString class]]) continue;
        
        NSDictionary *newStrings = newTable[language];
        if (![newStrings isKindOfClass:[NSDictionary class]]) continue;
        
        NSMutableDictionary *originalStrings = [mergedTable[language] mutableCopy];
        
        if (!originalStrings) {
            mergedTable[language] = [newStrings copy];
            continue;
        }
        
        [newStrings enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if ([key isKindOfClass:[NSString class]] && obj) {
                originalStrings[key] = obj;
            }
        }];
        
        mergedTable[language] = [originalStrings copy];
    }
    
    return [mergedTable copy];
}


+ (void)registerLocalizedTable:(nonnull NSDictionary<NSString *,NSDictionary<NSString *,NSString *> *> *)table {
    NSDictionary* originalTable = [VocaiLanguageTool sharedInstance].i18nTable.copy;
    [VocaiLanguageTool sharedInstance].i18nTable = [self mergeLocalizationTable:originalTable withNewTable:table];
}

+ (instancetype)sharedInstance {
    static VocaiLanguageTool *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        instance.i18nTable = [instance getDefaultTable];
    });
    return instance;
}

@end
