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
    return 30.0;
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
    NSDictionary* params = chatId ? @{@"chatId": chatId} : @{@"chatId":@""};
    [networkTool requestWithMethod:VocaiRequestMethodPOST URLString:url parameters:params
     success:^(id responseObject) {
        NSInteger count = [self parseUnreadCountFromResponse:responseObject];
        [self.unreadCountCache setObject:@(count) forKey:cId];
        if ([self.unreadCountCache[cId] integerValue] != count) {
            [self notifyObserversWithCount:count forChatId:chatId];
        }
    } failure:^(NSError *error) {
        [self notifyFailureForChatId:chatId error:error];
    }];
}


- (NSInteger)parseUnreadCountFromResponse:(id)responseObject {
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
        id countValue = [responseObject objectForKey:@"count"];
        if ([countValue isKindOfClass:[NSNumber class]]) {
            return [countValue integerValue];
        } else if ([countValue isKindOfClass:[NSString class]]) {
            return [countValue integerValue];
        }
    }
    return 0;
}

- (void)notifyObserversWithCount:(NSInteger)count forChatId:(NSString *)chatId {
    for (id<VocaiMessageCenterDelegate> observer in self.observers) {
        if ([observer respondsToSelector:@selector(messageCenter:didReceiveUnreadCount:forChatId:)]) {
            [observer messageCenter:self didReceiveUnreadCount:count forChatId:chatId];
        }
    }
}

- (void)notifyFailureForChatId:(NSString *)chatId error:(NSError *)error {
    for (id<VocaiMessageCenterDelegate> observer in self.observers) {
        if ([observer respondsToSelector:@selector(messageCenter:failedToFetchUnreadCountForChatId:withError:)]) {
            [observer messageCenter:self failedToFetchUnreadCountForChatId:chatId withError:error];
        }
    }
}

- (void)postUnreadCount:(NSInteger)count forChatId:(NSString *)chatId {
    NSNumber* n = @(count);
    NSString* key = chatId;
    if (!chatId) {
        chatId = @"0";
    }
    [self.unreadCountCache setObject:n forKey:key];
    [self notifyObserversWithCount:count forChatId:chatId];
}

#pragma mark - 自动刷新

-(void) startAutoRefresh {
    [self startAutoRefreshForChatId:nil];
}

- (void)startAutoRefreshForChatId:(NSString *) chatId {
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

- (void)stopAutoRefreshForChatId:(NSString *)chatId {
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
