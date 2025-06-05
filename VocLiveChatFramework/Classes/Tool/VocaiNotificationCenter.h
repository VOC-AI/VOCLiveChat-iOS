//
//  VocaiNotificationCenter.h
//  Pods
//
//  Created by Boyuan Gao on 2025/6/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol VocaiNotificationCenterDelegate <NSObject>

@optional

/**
 * 收到推送通知时调用
 * @param notification 推送内容字典
 * @param isForeground 是否在前台收到
 */
- (void)pushSDKDidReceiveNotification:(NSDictionary *)notification
                           fromForeground:(BOOL)isForeground;

/**
 * 控制前台是否显示系统通知弹窗
 * @return YES 显示系统弹窗，NO 静默处理
 */
- (BOOL)pushSDKShouldShowAlertInForeground;

/**
 * 用户点击通知时调用
 * @param notification 推送内容字典
 * @param launchOptions 启动选项
 */
- (void)pushSDKDidTapNotification:(NSDictionary *)notification
                    launchOptions:(nullable NSDictionary<UIApplicationLaunchOptionsKey, id> *)launchOptions;


@end

@interface VocaiNotificationCenter : NSObject

@property (nonatomic, weak, nullable) id<ANPushSDKDelegate> delegate;

+ (instancetype)shared;

/**
 * 初始化SDK
 * @param appKey 应用标识
 * @param secret 应用密钥
 * @param delegate 代理对象
 */
- (void)setupWithAppKey:(NSString *)appKey
                 secret:(NSString *)secret
               delegate:(nullable id<ANPushSDKDelegate>)delegate;

/**
 * 上传设备Token到服务器
 * @param deviceToken 设备Token数据
 */
- (void)uploadDeviceToken:(NSData *)deviceToken;

/**
 * 处理接收到的远程通知
 * @param userInfo 通知内容字典
 * @param isForeground 是否前台接收
 * @param completion 完成回调
 */
- (void)handleRemoteNotification:(NSDictionary *)userInfo
                   isForeground:(BOOL)isForeground
                   completion:(nullable void(^)(UIBackgroundFetchResult result))completion;

/**
 * 处理通知点击事件
 * @param userInfo 通知内容字典
 * @param launchOptions 启动选项
 */
- (void)handleNotificationTap:(NSDictionary *)userInfo
                launchOptions:(nullable NSDictionary<UIApplicationLaunchOptionsKey, id> *)launchOptions;

@end

NS_ASSUME_NONNULL_END
