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
- (instancetype)initWithId:(NSString *)chatId token:(NSString *)token webViewAddress:(NSString *)webViewAddress uploadUrl:(NSString *)uploadUrl email:(NSString *)email botId:(NSString *)botId language:(NSString*)language otherParams:(NSDictionary *)otherParams {
    self = [super init];
    if (self) {
        self.chatId = chatId;
        self.token = token;
        self.email = email;
        self.webViewAddress = webViewAddress;
        self.uploadUrl = uploadUrl;
        self.botId = botId;
        self.language = language;
        self.otherParams = otherParams;
    }
    return self;
}

@end
