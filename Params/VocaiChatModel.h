//
//  VocalParams.h
//  abc
//
//  Created by 刘志康 on 2025/3/2.
//
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// VOCLiveChatLinkOpenType 枚举
typedef NS_ENUM(NSUInteger, VOCLiveChatLinkOpenType) {
    VOCLiveChatLinkOpenTypeOpenWithBrowser = 0,
};

// 定义一个方法将枚举值转换为对应的字符串
NSString *NSStringFromVOCLiveChatLinkOpenType(VOCLiveChatLinkOpenType type);

// VOCLiveChatSystemLang 枚举
typedef NS_ENUM(NSUInteger, VOCLiveChatSystemLang) {
    VOCLiveChatSystemLangEnglish = 0,
    VOCLiveChatSystemLangChinese,
    VOCLiveChatSystemLangJapanese,
    VOCLiveChatSystemLangFrench,
    VOCLiveChatSystemLangGerman,
    VOCLiveChatSystemLangSpanish,
    VOCLiveChatSystemLangPortuguese,
    VOCLiveChatSystemLangArabic,
    VOCLiveChatSystemLangPhilippines,
    VOCLiveChatSystemLangIndonesian
};

// 定义一个方法将枚举值转换为对应的字符串
NSString *NSStringFromVOCLiveChatSystemLang(VOCLiveChatSystemLang lang);

// VOCLiveChatParams 类
@interface VocaiChatModel : NSObject

// 初始化方法
// 初始化方法
- (instancetype)initWithId:(NSString *)chatId token:(NSString *)token webViewAddress:(NSString *)webViewAddress uploadUrl:(NSString *)uploadUrl email:(NSString *)email botId:(NSString *)botId language:(NSString*)language otherParams:(NSDictionary *)otherParams;

// 属性
@property (nonatomic, strong) NSString *chatId;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong, nullable) NSString *email;
@property (nonatomic, strong, nullable) NSString *brand;
@property (nonatomic, strong) NSString *botId;
@property (nonatomic, strong, nullable) NSString *country;
@property (nonatomic, strong, nullable) NSString *webViewAddress;
@property (nonatomic, strong, nullable) NSString *uploadUrl;
@property (nonatomic, strong, nullable) NSString *language;
//@property (nonatomic, assign, nullable) VOCLiveChatSystemLang lang;
@property (nonatomic, assign) BOOL noHeader;
@property (nonatomic, assign) BOOL noBrand;
@property (nonatomic, assign) BOOL encrypt;
@property (nonatomic, assign) BOOL isTest;
@property (nonatomic, assign) VOCLiveChatLinkOpenType openLinkType;
@property (nonatomic, strong) NSString *skill_id;
@property (nonatomic, strong) NSString *channelid;
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *otherParams;

@end

NS_ASSUME_NONNULL_END
