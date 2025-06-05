//
//  MessageCenter.m
//  Pods
//
//  Created by Boyuan Gao on 2025/5/27.
//

#import "VocaiMessageCenter.h"
#import "VocaiApiTool.h"
#import "VocaiNetworkTool.h"
#import "VocaiChatModel.h"
#import "VocaiNetworkTool.h"
#import <objc/runtime.h>
#import <objc/message.h>

@interface VocaiMessageCenter ()

@property (nonatomic, strong) NSHashTable<id<VocaiMessageCenterDelegate>> *observers;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *unreadCountCache;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSTimer *> *refreshTimers;
@property (nonatomic, strong) VocaiChatModel* params;
@property (nonatomic, strong) VocaiApiTool* apiTool;

@end

@implementation VocaiMessageCenter


-(void) setParams: (VocaiChatModel*) model {
    _params = [model copy];
    self.apiTool = [[VocaiApiTool alloc] initWithParams: model];
}

+ (instancetype)sharedInstance {
    static VocaiMessageCenter *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(NSTimeInterval) refreshInterval {
    if (self.params.messageCountFetchInterval) {
        return self.params.messageCountFetchInterval;
    }
    return 10.0;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _observers = [NSHashTable weakObjectsHashTable];
        _unreadCountCache = [NSMutableDictionary dictionary];
        _refreshTimers = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)setApiTool:(id)apiTool {
    _apiTool = apiTool;
}

- (void)addObserver:(id<VocaiMessageCenterDelegate>)observer {
    if (observer && ![self.observers containsObject:observer]) {
        [self.observers addObject:observer];
    }
}

- (void)removeObserver:(id<VocaiMessageCenterDelegate>)observer {
    if (observer) {
        [self.observers removeObject:observer];
    }
}

- (void)fetchUnreadCountForChatId:(NSString *)chatId {
    NSString* formatUrl = [NSString stringWithFormat:@"/api_v2/intelli/livechat/%@/unread",self.params.botId];
    NSString* url = [self.apiTool getApiWithPathname:formatUrl];
    
    // 获取单例实例
    VocaiNetworkTool* networkTool = [VocaiNetworkTool sharedInstance];

    NSString* cId = chatId;
    if(!chatId) {
        cId = @"0";
    }
    NSDictionary* params = @{@"userId": self.params.userId};
    [networkTool requestWithMethod:VocaiRequestMethodPOST URLString:url parameters:params
     success:^(id responseObject) {
        BOOL hasNewMessage = [self parseUnreadCountFromResponse:responseObject];
        if ((self.unreadCountCache[cId] && [self.unreadCountCache[cId] boolValue] != hasNewMessage) || !self.unreadCountCache[cId]) {
            [self notifyObserversWithUnreadStatus:hasNewMessage forChatId:chatId];
            [self.unreadCountCache setObject:@(hasNewMessage) forKey:cId];
        }
    } failure:^(NSError *error) {
//        [self notifyFailureForChatId:chatId error:error];
    }];
}


- (NSInteger)parseUnreadCountFromResponse:(id)responseObject {
//    if ([responseObject isKindOfClass:[NSDictionary class]]) {
//        id countValue = [responseObject objectForKey:@"count"];
//        if ([countValue isKindOfClass:[NSNumber class]]) {
//            return [countValue integerValue];
//        } else if ([countValue isKindOfClass:[NSString class]]) {
//            return [countValue integerValue];
//        }
//    }
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
        id countValue = [responseObject objectForKey:@"hasUnread"];
        if ([countValue isKindOfClass:[NSNumber class]]) {
            return [countValue boolValue];
        } else if ([countValue isKindOfClass:[NSString class]]) {
            return [countValue boolValue];
        }
    }
    return 0;
}

- (void)notifyObserversWithUnreadStatus:(BOOL)hasNewMessage forChatId:(NSString *)chatId {
    for (id<VocaiMessageCenterDelegate> observer in self.observers) {
        if ([observer respondsToSelector:@selector(messageCenter:didHaveNewMessage:forChatId:)]) {
            [observer messageCenter:self didHaveNewMessage:hasNewMessage forChatId:chatId];
        }
    }
}

//- (void)notifyFailureForChatId:(NSString *)chatId error:(NSError *)error {
//    for (id<VocaiMessageCenterDelegate> observer in self.observers) {
//        if ([observer respondsToSelector:@selector(messageCenter:failedToFetchUnreadCountForChatId:withError:)]) {
//            [observer messageCenter:self failedToFetchUnreadCountForChatId:chatId withError:error];
//        }
//    }
//}

- (void)postUnreadStatus:(BOOL)hasNewMessage forChatId:(NSString *)chatId {
    NSString* key = chatId;
    if (!chatId) {
        key = @"0";
    }
    [self.unreadCountCache setObject:@(hasNewMessage) forKey:key];
    [self notifyObserversWithUnreadStatus:hasNewMessage forChatId:chatId];
}

#pragma mark - 自动刷新

-(void) startAutoRefresh {
    [self startAutoRefreshForChatId:nil];
}

- (void)startAutoRefreshForChatId:(nullable NSString *) chatId {
    NSString* key = chatId;
    if(!key) {
        key = @"0";
    }
    if (self.refreshTimers[key]) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:self.refreshInterval repeats:YES block:^(NSTimer * _Nonnull timer) {
        [weakSelf fetchUnreadCountForChatId:chatId];
    }];
    
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    self.refreshTimers[key] = timer;
    
    // 立即触发一次
    [self fetchUnreadCountForChatId:chatId];
}

- (void)stopAutoRefreshForChatId:(nullable NSString *)chatId {
    NSString* key = chatId;
    if(!key) {
        key = @"0";
    }
    NSTimer *timer = self.refreshTimers[key];
    if (timer) {
        [timer invalidate];
        [self.refreshTimers removeObjectForKey:key];
    }
}

- (void)stopAllAutoRefresh {
    [self.refreshTimers.allValues enumerateObjectsUsingBlock:^(__kindof NSTimer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj invalidate];
    }];
    [self.refreshTimers removeAllObjects];
}

- (void)dealloc {
    [self stopAllAutoRefresh];
}

@end
