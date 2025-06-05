//
//  VocaiJSBridge.h
//  Pods
//
//  Created by Boyuan Gao on 2025/6/5.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "VocaiChatModel.h"
#import <WebKit/WebKit.h>


NS_ASSUME_NONNULL_BEGIN


typedef void(^VocaiJSBridgeGetChatId)(NSString* _Nullable chatId);
typedef void(^VocaiJSBridgeSuccess)(id _Nullable response);

typedef void(^VocaiJSBridgeFailure)(NSError* _Nullable error);

@interface VocaiJSBridge:NSObject

- (instancetype) initWithWebview:(WKWebView*)webview;
- (void) invokeJavascript:(NSString*)script;
- (void) invokeJavascript:(NSString*)script onSuccess:(VocaiJSBridgeSuccess)onSuccess onFailure:(VocaiJSBridgeFailure)onFailure;
- (void) getCurrentChatId:(VocaiJSBridgeGetChatId)callback;
- (void) clearChats;
- (void) switchUserId:(NSString*)userId;
@end

NS_ASSUME_NONNULL_END
