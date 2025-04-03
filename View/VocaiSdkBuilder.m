//
//  VocaiSdkBuilder.m
//  abc
//
//  Created by 刘志康 on 2025/3/6.
//

#import "VocaiSdkBuilder.h"
#import "ChatWebViewController.h"
@implementation VocaiSdkBuilder

- (UIViewController *)buildSdkWithParams: (VocaiChatModel *)params {
    ChatWebViewController *webVC = [[ChatWebViewController alloc] initWithParameter:params];
    webVC.viewDelegate = self;
    return  webVC;
}

- (void)vocalViewControllerWillAppear:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.sdkViewWillAppearDelegate != nil) {
        [self.sdkViewWillAppearDelegate vocalSdkViewControllerWillAppear:viewController animated:animated];
    }
}

- (void)sdkViewWillAppear:(nonnull UIViewController *)viewController animated:(BOOL)animated {
    
}

@end
