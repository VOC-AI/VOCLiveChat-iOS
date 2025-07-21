//
//  LanguageTool.h
//  abc
//
//  Created by 刘志康 on 2025/3/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VocaiLanguageTool : NSObject
+ (NSString *)getStringForKey:(NSString *)key withLanguage:(NSString *)language;
+ (NSString *)defaultLang;
/**
 * @brief Register customized localization.
 * format: json
 * @example
 * {
     "en": {
         "key_take_photo": "Take Photo",
         "key_take_video": "Video",
         "key_choose_from_gallery": "Gallery",
         "key_choose_from_file": "File",
         "key_cancel": "Cancel",
         "key_settings": "Settings",
         "key_setting_desc": "Please grant the app permission to access the photo library in Settings.",
         "key_premission_request": "Permission Request",
         "key_nocamera_permission": "No camera permission. Please go to the Settings Center to enable it.",
         "key_media_limit_exceed": "Maximum file size(%@) exceeded."
*         }
 * }
 * Available langs: ['en', 'ko', 'cn', 'zh-HK', 'jp', 'fr', 'de', 'pt', 'es', 'ja', 'ar', 'id', 'fi', 'it', 'pl']
 * Available keys: As shown in the example
 */
+ (void)registerLocalizedTable:(NSDictionary<NSString *, NSDictionary<NSString *, NSString *> *> *)table;

@end

NS_ASSUME_NONNULL_END
