//
//  VocaiSdkBuilder.m
//  abc
//
//  Created by 刘志康 on 2025/3/6.
//

#import "VocaiSdkBuilder.h"
#import "ChatWebViewController.h"
#import "VocaiApiTool.h"

@implementation VocaiSdkBuilder

+ (instancetype) sharedInstance {
    static dispatch_once_t onceToken;
    static VocaiSdkBuilder* inst;
    dispatch_once(&onceToken, ^{
        inst = [[VocaiSdkBuilder alloc] init];
    });
    return inst;
}

- (void)deleteCookieWithDomain:(NSString *)domain key:(NSString *)key {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        NSArray<NSHTTPCookie *> *cookies = [storage cookies];
        
        for (NSHTTPCookie *cookie in cookies) {
            // 检查域名和 key 是否匹配
            if ([cookie.domain containsString:domain] && [cookie.name isEqualToString:key]) {
                [storage deleteCookie:cookie];
            }
        }
    });
}

- (void) clearChatsForModel:(VocaiChatModel*)model {
    NSArray<NSString*>* hosts = [VocaiApiTool availableHosts];
    NSString* chatCookieKey = [NSString stringWithFormat:@"shulex_chatbot_list_%@",model.botId];
    for(NSInteger i = 0; i < hosts.count; i++) {
        NSString* host = [hosts objectAtIndex:i];
        [self deleteCookieWithDomain:host key:chatCookieKey];
    }
}

- (ChatWebViewController *)buildSdkWithParams: (VocaiChatModel *)params {
    ChatWebViewController *webVC = [[ChatWebViewController alloc] initWithParameter:params];
    webVC.viewDelegate = self;
    return webVC;
}

- (UINavigationController *)buildSdkNavigationControllerWithParams: (VocaiChatModel *)params navigationColor: (UIColor *)navigationColor title:(NSString *)title{
    ChatWebViewController *webVC = [[ChatWebViewController alloc] initWithParameter:params];
    webVC.viewDelegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController: webVC];
    webVC.navigationItem.title = title;
    nav.navigationBar.backgroundColor = navigationColor;
    return nav;
}

- (void)vocaiViewControllerWillAppear:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.sdkViewWillAppearDelegate != nil) {
        [self.sdkViewWillAppearDelegate vocaiSdkViewControllerWillAppear:viewController animated:animated];
    }
}

- (void)sdkViewWillAppear:(nonnull UIViewController *)viewController animated:(BOOL)animated {
    
}

@end
