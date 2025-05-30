//
//  VOCAIViewController.m
//  VocLiveChatFramework
//
//  Created by 6587734 on 05/21/2025.
//  Copyright (c) 2025 6587734. All rights reserved.
//

#import "VOCAIViewController.h"
#import <VocLiveChatFramework/VocaiMessageCenter.h>
#import <VocLiveChatFramework/VocaiChatModel.h>
#import <VocLiveChatFramework/VocaiSdkBuilder.h>

@interface VOCAIViewController ()<VocaiMessageCenterDelegate>

@end

@implementation VOCAIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    NSString* str = [NSLocale preferredLanguages][0];
    NSLog(@"%@", str);
    NSDictionary *exampleOtherDict = nil;
    VocaiChatModel *vocaiModel = [[VocaiChatModel alloc] initWithBotId:@"17188" token:@"66CDB326E4B03648C0BDF94E" email:@"anti2moron@gmail.com" language:str otherParams:nil];
    vocaiModel.userId = @"123123";
    vocaiModel.uploadFileTypes = @[@"public.data"];
//    vocaiModel.env = VOCLiveChatEnvStaging;
    VocaiSdkBuilder *builder = [[VocaiSdkBuilder alloc] init];
//    VocaiMessageCenter *center = [VocaiMessageCenter sharedInstance];
//    [center addObserver:self];
//    [center setParams:vocaiModel];
    UIViewController *viewController = [builder buildSdkWithParams: vocaiModel];
    [self.view addSubview:viewController.view];
    viewController.view.frame = self.view.frame;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



// 实现代理方法
- (void)messageCenter:(id)center didReceiveUnreadCount:(NSInteger)count forChatId:(NSString *)chatId {
    // 更新UI或执行其他操作
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString* log = [NSString stringWithFormat:@"未读消息: %ld", (long)count];
        NSLog(@"%@", log);
    });
}

- (void)messageCenter:(id)center failedToFetchUnreadCountForChatId:(NSString *)chatId withError:(NSError *)error {
    // 处理错误
    NSLog(@"获取未读消息数失败 - ChatID: %@, 错误: %@", chatId, error.localizedDescription);
}

- (void)dealloc {
    // 移除观察者
    [[VocaiMessageCenter sharedInstance] removeObserver:self];
    
    // 停止自动刷新（如果之前启动过）
    [[VocaiMessageCenter sharedInstance] stopAutoRefreshForChatId:@""];
}

@end
