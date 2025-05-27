//
//  VocalParams.m
//  abc
//
//  Created by 刘志康 on 2025/3/2.
//


#import "VocaiChatModel.h"

// VOCLiveChatLinkOpenType 枚举转换为字符串的实现
NSString *NSStringFromVOCLiveChatLinkOpenType(VOCLiveChatLinkOpenType type) {
    switch (type) {
        case VOCLiveChatLinkOpenTypeOpenWithBrowser:
            return @"browser";
        default:
            return @"";
    }
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
        self.language = @"en-US";
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
        self.language = language;
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
        self.language = language;
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
        self.language = language;
        self.otherParams = otherParams;
    }
    return self;
}


- (instancetype)copyWithZone:(NSZone *)zone {
    // 创建新实例（使用与原对象相同的类，支持子类）
    VocaiChatModel *copy = [[[self class] allocWithZone:zone] init];
    
    // 复制属性值（深拷贝 vs 浅拷贝需根据需求选择）
    copy.chatId = [self.chatId copyWithZone:zone];
    copy.token = [self.token copyWithZone:zone];
    copy.email = [self.email copyWithZone:zone];
    copy.brand = [self.brand copyWithZone:zone];
    copy.botId = [self.botId copyWithZone:zone];
    copy.country = [self.country copyWithZone:zone];
    copy.language = [self.language copyWithZone:zone];
    copy.noHeader = self.noHeader;
    copy.noBrand = self.noBrand;
    copy.encrypt = self.encrypt;
    copy.isTest = self.isTest;
    copy.maxUploadFileSize = self.maxUploadFileSize;
    copy.openLinkType = self.openLinkType;
    copy.skill_id = [self.skill_id copyWithZone:zone];
    copy.channelid = [self.channelid copyWithZone:zone];
    copy.otherParams = [self.otherParams copyWithZone:zone];
    copy.env = self.env;
    return copy;
}

@end
