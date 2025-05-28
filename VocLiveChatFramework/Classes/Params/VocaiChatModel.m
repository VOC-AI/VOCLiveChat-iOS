//
//  VocalParams.m
//  abc
//
//  Created by 刘志康 on 2025/3/2.
//


#import "VocaiChatModel.h"
#import "VocaiLanguageTool.h"

// VOCLiveChatLinkOpenType 枚举转换为字符串的实现
NSString *NSStringFromVOCLiveChatLinkOpenType(VOCLiveChatLinkOpenType type) {
    switch (type) {
        case VOCLiveChatLinkOpenTypeOpenWithBrowser:
            return @"browser";
        default:
            return @"";
    }
}

NSString *fixLang(NSString* str) {
    NSDictionary *correctionMap = @{
        @"ko": @"ko-KR",
        @"zh-Hans": @"zh-CN",
        @"zh-Hant-HK":@"zh-HK",
        @"zh-Hant-TW":@"zh-TW",
    };
    if ([correctionMap objectForKey:str]) {
        return [correctionMap objectForKey:str];
    }
    return nil;
}

NSString *fullyNormalizeLanguageCode(NSString *languageCode) {
    
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:languageCode];
    NSString *standardized = [locale localeIdentifier];
    if(!standardized) {
        standardized = languageCode;
    }
    
    standardized = [standardized stringByReplacingOccurrencesOfString:@"_" withString:@"-"];
    NSString* fixed = fixLang(standardized);
    if(fixed) {
        return fixed;
    }
    NSString *firstComponent = nil;
    if (standardized != nil && [standardized length] > 0) {
        NSArray *components = [standardized componentsSeparatedByString:@"-"];
        if ([components count] > 0) {
            firstComponent = [components objectAtIndex:0];
        }
    }
    if(firstComponent) {
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:firstComponent];
        NSString *standardized2 = [locale localeIdentifier];
        NSString *fix2 = fixLang(standardized2);
        if(fix2) {
            return fix2;
        }
        return standardized2;
    }
    return standardized;
}


// VOCLiveChatSystemLang 枚举转换为字符串的实现
NSString *NSStringFromVOCLiveChatSystemLang(VOCLiveChatSystemLang lang) {
    switch (lang) {
        case VOCLiveChatSystemLangEnglish:
            return @"en-US";
        case VOCLiveChatSystemLangChinese:
            return @"zh-CN";
        case VOCLiveChatSystemLangJapanese:
            return @"ja-JP";
        case VOCLiveChatSystemLangFrench:
            return @"fr-FR";
        case VOCLiveChatSystemLangGerman:
            return @"de-DE";
        case VOCLiveChatSystemLangSpanish:
            return @"es-ES";
        case VOCLiveChatSystemLangPortuguese:
            return @"pt-PT";
        case VOCLiveChatSystemLangArabic:
            return @"ar";
        case VOCLiveChatSystemLangPhilippines:
            return @"fl";
        case VOCLiveChatSystemLangIndonesian:
            return @"in";
        default:
            return @"";
    }
}

@implementation VocaiChatModel

// 初始化方法
- (instancetype)initWithBotId:(NSString *)botId token:(NSString *)token otherParams:(NSDictionary *)otherParams {
    self = [super init];
    if (self) {
        self.token = token;
        self.botId = botId;
        self.language = [self normalizeLanguage: [VocaiLanguageTool defaultLang]];
        self.otherParams = otherParams;
    }
    return self;
}

// 初始化方法
- (instancetype)initWithBotId:(NSString *)botId token:(NSString *)token language:(NSString*)language otherParams:(NSDictionary *)otherParams {
    self = [super init];
    if (self) {
        self.token = token;
        self.botId = botId;
        if(language) {
            self.language = [self normalizeLanguage: language];
        } else {
            self.language = [self normalizeLanguage: [VocaiLanguageTool defaultLang]];
        }
        self.otherParams = otherParams;
    }
    return self;
}

// 初始化方法
- (instancetype)initWithBotId:(NSString *)botId chatId:(NSString *)chatId token:(NSString *)token email:(NSString *)email language:(NSString*)language otherParams:(NSDictionary *)otherParams {
    self = [super init];
    if (self) {
        self.chatId = chatId;
        self.token = token;
        self.email = email;
        self.botId = botId;
        if(language) {
            self.language = [self normalizeLanguage: language];
        } else {
            self.language = [self normalizeLanguage: [VocaiLanguageTool defaultLang]];
        }
        self.otherParams = otherParams;
    }
    return self;
}

// 初始化方法
- (instancetype)initWithBotId:(NSString *)botId token:(NSString *)token  email:(NSString *)email language:(NSString*)language otherParams:(NSDictionary *)otherParams {
    self = [super init];
    if (self) {
        self.token = token;
        self.email = email;
        self.botId = botId;
        if(language) {
            self.language = [self normalizeLanguage: language];
        } else {
            self.language = [self normalizeLanguage: [VocaiLanguageTool defaultLang]];
        }
        self.otherParams = otherParams;
    }
    return self;
}


- (instancetype)copyWithZone:(NSZone *)zone {
    VocaiChatModel *copy = [[[self class] allocWithZone:zone] init];
    copy.noHeader = self.noHeader;
    copy.noBrand = self.noBrand;
    copy.encrypt = self.encrypt;
    copy.isTest = self.isTest;
    copy.env = self.env;
    copy.chatId = [self.chatId copyWithZone:zone];
    copy.token = [self.token copyWithZone:zone];
    copy.email = [self.email copyWithZone:zone];
    copy.brand = [self.brand copyWithZone:zone];
    copy.botId = [self.botId copyWithZone:zone];
    copy.country = [self.country copyWithZone:zone];
    copy.language = [self.language copyWithZone:zone];
    copy.maxUploadFileSize = self.maxUploadFileSize;
    copy.openLinkType = self.openLinkType;
    copy.skill_id = [self.skill_id copyWithZone:zone];
    copy.channelid = [self.channelid copyWithZone:zone];
    copy.otherParams = [self.otherParams copyWithZone:zone];
    copy.userId = [self.userId copyWithZone:zone];
    copy.uploadFileTypes = [self.uploadFileTypes copyWithZone:zone];
    return copy;
}

-(NSString*) normalizeLanguage:(NSString*) language {
    return fullyNormalizeLanguageCode(language);
}

@end
