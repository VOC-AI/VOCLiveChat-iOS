//
//  VocaiNotificationRouter.h
//  Pods
//
//  Created by Boyuan Gao on 2025/6/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol VocaiNotificationPushRouter <NSObject>

/**
 * 根据路由路径和参数执行跳转
 * @param path 路由路径
 * @param params 路由参数
 * @return 是否成功跳转
 */
- (BOOL)routeToPath:(NSString *)path withParams:(nullable NSDictionary *)params;

@end

NS_ASSUME_NONNULL_END
