//
//  VocaiJSBridge.m
//  Pods
//
//  Created by Boyuan Gao on 2025/6/5.
//

#import "VocaiJSBridge.h"

@interface VocaiJSBridge()

@property(nullable, weak) WKWebView* webview;

@end

@implementation VocaiJSBridge

- (instancetype)initWithWebview:(WKWebView *)webview {
    self = [super init];
    if(self) {
        self.webview = webview;
    }
    return self;
}

- (void) invokeJavascript:(NSString*)script {
    [self invokeJavascript:script onSuccess:^(id  _Nullable response) {
    } onFailure:^(NSError * _Nullable error) {
    }];
}

- (void) invokeJavascript:(NSString*)script onSuccess:(VocaiJSBridgeSuccess)onSuccess onFailure:(VocaiJSBridgeFailure)onFailure {
    [self.webview evaluateJavaScript:script completionHandler:^(id result, NSError * _Nullable error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                onFailure(error);
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                onSuccess(result);
            });
        }
    }];
}

- (void) getCurrentChatId:(VocaiJSBridgeGetChatId)callback {
    [self invokeJavascript:@"typeof getChatId === 'function' ? getChatId() : undefined" onSuccess:^(id  _Nullable response) {
        callback(response);
        NSLog(@"%@", response);
    } onFailure:^(NSError * _Nullable error) {
        NSLog(@"%@", error);
    }];
}

- (void)clearChats {
    [self invokeJavascript:@"if(typeof clearChatIds === 'function'){clearChatIds();}"];
}

- (void) switchUserId:(NSString*)userId {
    NSString* script = [NSString stringWithFormat:@"if(typeof setUserId === 'function'){setUserId(%@);}",userId];
    [self invokeJavascript:script];
}

@end
