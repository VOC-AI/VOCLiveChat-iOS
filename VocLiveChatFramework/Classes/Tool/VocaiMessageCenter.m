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
    self.params = [model copy];
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
    if (!chatId || !self.apiTool) {
        NSError *error = [NSError errorWithDomain:@"MessageCenterErrorDomain" code:1001 userInfo:@{NSLocalizedDescriptionKey: @"Invalid chatId or apiTool"}];
        [self notifyFailureForChatId:chatId error:error];
        return;
    }
    
    NSString* url = [self.apiTool getApiWithPathname:@"/livechat/unread"];
    Class networkToolClass = NSClassFromString(@"VocaiNetworkTool");
    
    if (!networkToolClass) {
        NSError *error = [NSError errorWithDomain:@"MessageCenterErrorDomain" code:1002 userInfo:@{NSLocalizedDescriptionKey: @"VocaiNetworkTool not found"}];
        [self notifyFailureForChatId:chatId error:error];
        return;
    }
    
    // 获取单例实例
    SEL sharedInstanceSelector = NSSelectorFromString(@"sharedInstance");
    id networkTool = ((id (*)(id, SEL))objc_msgSend)(networkToolClass, sharedInstanceSelector);
    
    if (!networkTool) {
        NSError *error = [NSError errorWithDomain:@"MessageCenterErrorDomain" code:1003 userInfo:@{NSLocalizedDescriptionKey: @"Failed to get VocaiNetworkTool instance"}];
        [self notifyFailureForChatId:chatId error:error];
        return;
    }
    
    SEL requestSelector = NSSelectorFromString(@"requestWithMethod:URLString:parameters:success:failure:");
    NSInteger method = 1; // VocaiRequestMethodPOST
    
    // 定义闭包类型
    typedef void (^SuccessBlock)(id responseObject);
    typedef void (^FailureBlock)(NSError *error);
    
    // 创建请求闭包
    SuccessBlock successBlock = ^(id responseObject) {
        NSInteger count = [self parseUnreadCountFromResponse:responseObject];
        [self.unreadCountCache setObject:@(count) forKey:chatId];
        [self notifyObserversWithCount:count forChatId:chatId];
    };
    
    FailureBlock failureBlock = ^(NSError *error) {
        [self notifyFailureForChatId:chatId error:error];
    };
    
    // 使用显式类型转换调用消息
    ((void (*)(id, SEL, NSInteger, NSString *, NSDictionary *, SuccessBlock, FailureBlock))objc_msgSend)(
        networkTool,
        requestSelector,
        method,
        url,
        @{@"chatId": chatId},
        successBlock,
        failureBlock
    );
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
    [self.unreadCountCache setObject:@(count) forKey:chatId];
    [self notifyObserversWithCount:count forChatId:chatId];
}

#pragma mark - 自动刷新

- (void)startAutoRefreshForChatId:(NSString *)chatId {
    if (!chatId || self.refreshTimers[chatId]) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:self.refreshInterval repeats:YES block:^(NSTimer * _Nonnull timer) {
        [weakSelf fetchUnreadCountForChatId:chatId];
    }];
    
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    self.refreshTimers[chatId] = timer;
    
    // 立即触发一次
    [self fetchUnreadCountForChatId:chatId];
}

- (void)stopAutoRefreshForChatId:(NSString *)chatId {
    NSTimer *timer = self.refreshTimers[chatId];
    if (timer) {
        [timer invalidate];
        [self.refreshTimers removeObjectForKey:chatId];
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
