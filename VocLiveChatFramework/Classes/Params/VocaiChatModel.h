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
    VOCLiveChatSystemLangChinese = 1,
    VOCLiveChatSystemLangJapanese = 2,
    VOCLiveChatSystemLangFrench = 3,
    VOCLiveChatSystemLangGerman = 4,
    VOCLiveChatSystemLangSpanish = 5,
    VOCLiveChatSystemLangPortuguese = 6,
    VOCLiveChatSystemLangArabic = 7,
    VOCLiveChatSystemLangPhilippines = 8,
    VOCLiveChatSystemLangIndonesian = 9
} NS_SWIFT_NAME(VOCLiveChatSystemLang);

// VOCLiveChatSystemLang 枚举
typedef NS_ENUM(NSUInteger, VOCLiveChatEnv) {
    VOCLiveChatEnvProd = 0,
    VOCLiveChatEnvStaging = 1,
} NS_SWIFT_NAME(VOCLiveChatEnv);

// 定义一个方法将枚举值转换为对应的字符串
NSString *NSStringFromVOCLiveChatSystemLang(VOCLiveChatSystemLang lang);

// VOCLiveChatParams 类
@interface VocaiChatModel : NSObject

- (instancetype)initWithBotId:(NSString *)botId token:(NSString *)token otherParams:(NSDictionary *)otherParams;
- (instancetype)initWithBotId:(NSString *)botId token:(NSString *)token language:(NSString*)language otherParams:(NSDictionary *)otherParams;

- (instancetype)initWithBotId:(NSString *)botId token:(NSString *)token  email:(NSString *)email language:(NSString*)language otherParams:(NSDictionary *)otherParams;

- (instancetype)initWithBotId:(NSString *)botId chatId:(NSString *)chatId token:(NSString *)token email:(NSString *)email language:(NSString*)language otherParams:(NSDictionary *)otherParams;

- (instancetype)initWithBotId:(NSString *)botId token:(NSString *)token  email:(NSString *)email language:(NSString*)language userId:(NSString*)userId otherParams:(NSDictionary *)otherParams;

@property (nonatomic, strong) NSString *chatId;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, copy, nullable) NSString *email;
@property (nonatomic, copy, nullable) NSString *brand;
@property (nonatomic, copy) NSString *botId;
@property (nonatomic, copy, nullable) NSString *country;
@property (nonatomic, copy, nullable) NSString *language;
@property (nonatomic, assign) BOOL noHeader;
@property (nonatomic, assign) BOOL noBrand;
@property (nonatomic, assign) BOOL encrypt;
@property (nonatomic, assign) BOOL isTest;
@property (nonatomic, assign) NSTimeInterval messageCountFetchInterval;
@property (nonatomic, assign) NSUInteger maxUploadFileSize;
@property (nonatomic, assign) VOCLiveChatLinkOpenType openLinkType;
@property (nonatomic, strong) NSString *skill_id;
@property (nonatomic, strong) NSString *channelid;
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *otherParams;
@property (nonatomic, strong) NSArray<NSString *> * uploadFileTypes;
@property (nonatomic, assign) VOCLiveChatEnv env;
@property (nonatomic, copy, nullable) NSString *userId;
@property (nonatomic, assign) BOOL enableLog;
@end

NS_ASSUME_NONNULL_END
