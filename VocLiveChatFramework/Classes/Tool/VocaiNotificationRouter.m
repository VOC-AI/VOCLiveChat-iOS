//
//  VocaiNotificationRouter.m
//  Pods
//
//  Created by Boyuan Gao on 2025/6/4.
//

#import "AppDelegate.h"
#import "VocaiNotificationRouter.h"
#import "MyRouter.h" // 自定义路由实现

@interface AppDelegate () <UIApplicationDelegate, ANPushSDKDelegate, UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(nullable NSDictionary<UIApplicationLaunchOptionsKey, id> *)launchOptions {
    
    // 初始化推送SDK
    [[ANPushSDK shared] setupWithAppKey:@"YOUR_APP_KEY"
                                 secret:@"YOUR_SECRET"
                               delegate:self];
    
    // 设置路由处理器
    [[ANPushSDK shared] setRouter:[[MyRouter alloc] init]];
    
    // 处理冷启动时的推送点击
    if (launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) {
        NSDictionary *userInfo = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
        [[ANPushSDK shared] handleNotificationTap:userInfo launchOptions:launchOptions];
    }
    
    return YES;
}

#pragma mark - UNUserNotificationCenterDelegate (iOS 10+)

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    
    [[ANPushSDK shared] handleRemoteNotification:notification.request.content.userInfo
                                     isForeground:YES
                                     completion:^(UIBackgroundFetchResult result) {
        // 根据处理结果决定展示方式
        completionHandler(UNNotificationPresentationOptionAlert);
    }];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)(void))completionHandler {
    
    [[ANPushSDK shared] handleNotificationTap:response.notification.request.content.userInfo
                                  launchOptions:nil];
    completionHandler();
}

#pragma mark - UIApplicationDelegate

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[ANPushSDK shared] uploadDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application
didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"注册推送失败: %@", error.localizedDescription);
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    
    [[ANPushSDK shared] handleRemoteNotification:userInfo
                                     isForeground:(application.applicationState == UIApplicationStateActive)
                                     completion:completionHandler];
}

#pragma mark - ANPushSDKDelegate

- (void)pushSDKDidReceiveNotification:(NSDictionary *)notification
                           fromForeground:(BOOL)isForeground {
    NSLog(@"收到推送: %@ (前台: %@)", notification, isForeground ? @"YES" : @"NO");
    
    if (isForeground) {
        // 前台收到推送，自定义处理
        [self showInAppNotification:notification];
    }
}

- (BOOL)pushSDKShouldShowAlertInForeground {
    // 根据业务逻辑决定是否显示系统弹窗
    return NO;
}

- (void)pushSDKDidTapNotification:(NSDictionary *)notification
                    launchOptions:(nullable NSDictionary<UIApplicationLaunchOptionsKey, id> *)launchOptions {
    NSLog(@"点击推送: %@", notification);
}

#pragma mark - Private Methods

- (void)showInAppNotification:(NSDictionary *)notification {
    // 自定义应用内通知UI
    // ...
}

@end
