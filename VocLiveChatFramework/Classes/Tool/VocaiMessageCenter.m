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

@interface VocaiMessageCenter()

@property (nonatomic, copy) VocaiChatModel* params;
@property (nonatomic, strong) VocaiApiTool* apiTool;
@property (nonatomic, copy) NSNumber* messageCount;
@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic, strong) NSURL *requestURL;

@property (nonatomic, copy) SuccessBlock successBlock;

@end


@implementation VocaiMessageCenter

-(instancetype) initWithParams: (VocaiChatModel*) model {
    self = [super init];
    if (self) {
        self.params = [model copy];
        self.apiTool = [[VocaiApiTool alloc] initWithParams: model];
        self.messageCount = @0;
    }
    return self;
}

-(void) getUnreadMessageCountWithChatId:(NSString*)chatId withCallback:(SuccessBlock)callback {
    NSString* url = [self.apiTool getApiWithPathname:@"/livechat/unread"];
    [[VocaiNetworkTool sharedInstance] requestWithMethod:VocaiRequestMethodPOST URLString:url parameters:@{@"chatId":chatId} success:^(id responseObject) {
        NSLog(responseObject);
    } failure:^(NSError *error) {
        // ignore
    }];
}

- (void)startPollingWithURL:(NSURL *)url interval:(NSTimeInterval)interval success:(SuccessBlock)success {
    self.requestURL = url;
    self.successBlock = success;
    
    // 创建 GCD 定时器
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    dispatch_source_set_timer(self.timer, dispatch_time(DISPATCH_TIME_NOW, 0), interval * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    
    // 设置定时器回调
    __weak typeof(self) weakSelf = self;
    dispatch_source_set_event_handler(self.timer, ^{
//        [weakSelf getUnreadMessageCountWithChatId];
    });
    
    // 启动定时器
    dispatch_resume(self.timer);
}

- (void)stopPolling {
    if (self.timer) {
        dispatch_source_cancel(self.timer);
        self.timer = nil;
    }
}

@end
