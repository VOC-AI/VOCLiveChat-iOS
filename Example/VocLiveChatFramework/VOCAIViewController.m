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

@interface VOCAIViewController ()<VocaiMessageCenterDelegate, VocaiViewControllerLifecycleDelegate>

@property(nonatomic, copy) VocaiChatModel* model;

@end

@implementation VOCAIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    VocaiMessageCenter *center = [VocaiMessageCenter sharedInstance];
    VocaiChatModel* model = [self createModel];
    self.model = model;
    [center setParams:model];
    [center addObserver:self];
    [center startAutoRefresh];
}

-(VocaiChatModel*)createModel {
    NSString* str = [NSLocale preferredLanguages][0];
    NSLog(@"%@", str);
    VocaiChatModel *vocaiModel = [[VocaiChatModel alloc] initWithBotId:@"499" token:@"66D806CAE4B05062935CCFD0" email:@"anti2moron@gmail.com" language:str otherParams:nil];
    vocaiModel.enableLog = YES;
    vocaiModel.uploadFileTypes = @[@"public.data"];
    vocaiModel.env = VOCLiveChatEnvStaging;
    return vocaiModel;
}

- (void)setModel:(VocaiChatModel *)model {
    _model = [model copy];
    [VocaiMessageCenter.sharedInstance setParams:_model];
}

- (IBAction)popNoneLoginWithDeviceID:(id)sender {
    VocaiSdkBuilder *builder = VocaiSdkBuilder.sharedInstance;
    NSString *deviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSLog(@"Device ID: %@", deviceId);
    self.model.userId = deviceId;
    ChatWebViewController *viewController = [builder buildSdkWithParams: self.model];
    viewController.viewDelegate = self;
    viewController.title = @"Support Center";
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)popLoginWithUserID:(id)sender {
    VocaiSdkBuilder *builder = VocaiSdkBuilder.sharedInstance;
    self.model.userId = @"Some userId in your system";
    ChatWebViewController *viewController = [builder buildSdkWithParams: self.model];
    viewController.viewDelegate = self;
    viewController.title = @"Support Center";
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)logoutAndClearChats:(id)sender {
    VocaiChatModel* model = [self createModel];
    [VocaiSdkBuilder.sharedInstance clearChatsForModel:model];
}

-(void)vocaiViewControllerWillAppear:(UIViewController *)viewController animated:(BOOL)animated {
    NSLog(@"View will Appear");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



// 实现代理方法
- (void)messageCenter:(id)center didHaveNewMessage:(BOOL)hasNewMessage forChatId:(nonnull NSString *)chatId {
    // 更新UI或执行其他操作
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString* text = [NSString stringWithFormat:@"%@ -- %@", @"Has Message?", @(hasNewMessage)];
        NSLog(@"%@", text);
        self.displayLabel.text = text;
    });
}

- (void)dealloc {
    // 移除观察者
    [[VocaiMessageCenter sharedInstance] removeObserver:self];
    
    // 停止自动刷新（如果之前启动过）
    [[VocaiMessageCenter sharedInstance] stopAllAutoRefresh];
}

-(void) changeUser {
    
}

@end
