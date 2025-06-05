//
//  VocaiSdkBuilder.m
//  abc
//
//  Created by 刘志康 on 2025/3/6.
//

#import "VocaiSdkBuilder.h"
#import "ChatWebViewController.h"
@implementation VocaiSdkBuilder

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
