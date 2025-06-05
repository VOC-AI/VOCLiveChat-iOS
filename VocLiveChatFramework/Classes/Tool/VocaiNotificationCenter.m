//
//  VocaiNotificationCenter.m
//  Pods
//
//  Created by Boyuan Gao on 2025/6/4.
//

#import "VocaiNotificationCenter.h"


@interface VocaiNotificationCenter ()

@property (nonatomic, strong, nullable) id<ANPushRouter> router;

@end

@implementation VocaiNotificationCenter

+ (instancetype)shared {
    static VocaiNotificationCenter *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)setupWithAppKey:(NSString *)appKey
                 secret:(NSString *)secret
               delegate:(nullable id<VocaiNotificationCenterDelegate>)delegate {
    self.delegate = delegate;
    
    [self registerForRemoteNotifications];
}

- (void)uploadDeviceToken:(NSData *)deviceToken {
    // 转换Token为字符串
    NSMutableString *tokenString = [NSMutableString string];
    const unsigned char *tokenBytes = [deviceToken bytes];
    for (NSInteger i = 0; i < [deviceToken length]; i++) {
        [tokenString appendFormat:@"%02x", tokenBytes[i]];
    }
    
    // 发送到服务器
    // [APIService uploadDeviceToken:tokenString];
    NSLog(@"上传设备Token: %@", tokenString);
}

- (void)handleRemoteNotification:(NSDictionary *)userInfo
                   isForeground:(BOOL)isForeground
                   completion:(nullable void(^)(UIBackgroundFetchResult result))completion {
    // 解析通知内容
    NSDictionary *notification = [self parseNotification:userInfo];
    
    // 应用在前台时，根据代理决定是否显示弹窗
    BOOL shouldShowAlert = YES;
    if ([self.delegate respondsToSelector:@selector(pushSDKShouldShowAlertInForeground)]) {
        shouldShowAlert = [self.delegate pushSDKShouldShowAlertInForeground];
    }
    
    if (isForeground && !shouldShowAlert) {
        // 前台静默处理
        if ([self.delegate respondsToSelector:@selector(pushSDKDidReceiveNotification:fromForeground:)]) {
            [self.delegate pushSDKDidReceiveNotification:notification fromForeground:YES];
        }
        if (completion) completion(UIBackgroundFetchResultNoData);
        return;
    }
    
    // 后台或需要显示弹窗的情况
    if (!isForeground && [self.delegate respondsToSelector:@selector(pushSDKDidReceiveNotification:fromForeground:)]) {
        [self.delegate pushSDKDidReceiveNotification:notification fromForeground:NO];
    }
    
    if (completion) completion(UIBackgroundFetchResultNewData);
}

- (void)handleNotificationTap:(NSDictionary *)userInfo
                launchOptions:(nullable NSDictionary<UIApplicationLaunchOptionsKey, id> *)launchOptions {
    // 解析通知内容
    NSDictionary *notification = [self parseNotification:userInfo];
    
    // 通知代理
    if ([self.delegate respondsToSelector:@selector(pushSDKDidTapNotification:launchOptions:)]) {
        [self.delegate pushSDKDidTapNotification:notification launchOptions:launchOptions];
    }
    
    // 执行路由跳转
    [self navigateFromNotification:notification];
}

#pragma mark - Private Methods

- (void)registerForRemoteNotifications {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = (id<UNUserNotificationCenterDelegate>)self.delegate;
    
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionSound | UNAuthorizationOptionBadge)
                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                [[UIApplication sharedApplication] registerForRemoteNotifications];
            } else {
                NSLog(@"推送权限被拒绝: %@", error.localizedDescription);
            }
        });
    }];
}

- (NSDictionary *)parseNotification:(NSDictionary *)userInfo {
    // 解析推送内容，兼容APNs标准格式和自定义格式
    return userInfo;
}

- (void)navigateFromNotification:(NSDictionary *)notification {
    if (!self.router) return;
    
    NSString *routePath = notification[@"routePath"];
    NSDictionary *routeParams = notification[@"routeParams"];
    
    if (routePath && [self.router respondsToSelector:@selector(routeToPath:withParams:)]) {
        [self.router routeToPath:routePath withParams:routeParams];
    }
}

@end
