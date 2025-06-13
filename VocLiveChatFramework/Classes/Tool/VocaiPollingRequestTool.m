//
//  PollingRequestTool.m
//  abc
//
//  Created by 刘志康 on 2025/3/2.
//

#import "VocaiPollingRequestTool.h"

@interface VocaiPollingRequestTool ()

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic, strong) NSURL *requestURL;
@property (nonatomic, copy) PollingSuccessBlock successBlock;
@property (nonatomic, copy) PollingFailureBlock failureBlock;

@end

@implementation VocaiPollingRequestTool

- (instancetype)init {
    self = [super init];
    if (self) {
        self.session = [NSURLSession sharedSession];
    }
    return self;
}

- (void)startPollingWithURL:(NSURL *)url interval:(NSTimeInterval)interval success:(PollingSuccessBlock)success failure:(PollingFailureBlock)failure {
    self.requestURL = url;
    self.successBlock = success;
    self.failureBlock = failure;
    
    // Create GCD timer
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    dispatch_source_set_timer(self.timer, dispatch_time(DISPATCH_TIME_NOW, 0), interval * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    
    // Set timer callback
    __weak typeof(self) weakSelf = self;
    dispatch_source_set_event_handler(self.timer, ^{
        [weakSelf sendRequest];
    });
    
    // Start timer
    dispatch_resume(self.timer);
}

- (void)stopPolling {
    if (self.timer) {
        dispatch_source_cancel(self.timer);
        self.timer = nil;
    }
}

- (void)sendRequest {
    NSURLRequest *request = [NSURLRequest requestWithURL:self.requestURL];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            if (self.failureBlock) {
                self.failureBlock(error);
            }
        } else {
            NSError *jsonError;
            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
            if (jsonError) {
                if (self.failureBlock) {
                    self.failureBlock(error);
                }
            } else {
                if (self.successBlock) {
                    self.successBlock(data, responseDict);
                }
            }
        }
    }];
    [task resume];
}



@end

