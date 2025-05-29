//
//  MessageCenter.h
//  Pods
//
//  Created by Boyuan Gao on 2025/5/27.
//
#import <Foundation/Foundation.h>
#import <VocLiveChatFramework/VocaiChatModel.h>

NS_ASSUME_NONNULL_BEGIN



@protocol VocaiMessageCenterDelegate <NSObject>
@optional
- (void)messageCenter:(id)center didReceiveUnreadCount:(NSInteger)count forChatId:(NSString *)chatId;
- (void)messageCenter:(id)center failedToFetchUnreadCountForChatId:(NSString *)chatId withError:(NSError *)error;
@end


typedef void(^SuccessBlock)(NSNumber* count);


/**
 * VocaiMessageCenter
 */
@interface VocaiMessageCenter : NSObject


+ (instancetype)sharedInstance;

- (void) setParams: (VocaiChatModel*) model;

// 注册/注销观察者
- (void)addObserver:(id<VocaiMessageCenterDelegate>)observer;
- (void)removeObserver:(id<VocaiMessageCenterDelegate>)observer;

// 获取未读消息数
- (void)fetchUnreadCountForChatId:(NSString *)chatId;

// 主动推送未读消息数更新
- (void)postUnreadCount:(NSInteger)count forChatId:(NSString *)chatId;

// 管理自动刷新
- (void)startAutoRefreshForChatId:(NSString *)chatId;
- (void)stopAutoRefreshForChatId:(NSString *)chatId;
- (void)stopAllAutoRefresh;

@end

NS_ASSUME_NONNULL_END
