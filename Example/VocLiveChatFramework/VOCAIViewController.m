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
#import <WebKit/WebKit.h>
#import <VocLiveChatFramework/VocaiLanguageTool.h>

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

-(void) customizeLocalization {
    NSBundle* bundle = [NSBundle mainBundle];
    NSString* filePath = [bundle pathForResource:@"Localization" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    if (!data) {
        NSLog(@"Failed to read JSON file.");
        return ;
    }
    
    NSError *error;
    NSDictionary *table = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (error) {
        NSLog(@"Failed to parse JSON: %@", error.localizedDescription);
        return ;
    }
    [VocaiLanguageTool registerLocalizedTable:table];
}

-(VocaiChatModel*)createModel {
    NSString* str = [NSLocale preferredLanguages][0];
    NSLog(@"%@", str);
    
    [self customizeLocalization];
    VocaiChatModel *vocaiModel = [[VocaiChatModel alloc] initWithBotId:@"23029" token:@"684958ECE4B0FDB1BCAF63DE" email:@"anti2moron@gmail.com" language:str otherParams:nil];
    vocaiModel.enableLog = YES;
    vocaiModel.uploadFileTypes = @[@"public.data"];
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
    self.model.otherParams = @{@"Test": @"abc"};
    ChatWebViewController *viewController = [builder buildSdkWithParams: self.model];
    viewController.viewDelegate = self;
    viewController.title = @"Support Center";
    [self.navigationController pushViewController:viewController animated:YES];
}


- (IBAction)presentViewController:(id)sender {
    VocaiSdkBuilder *builder = VocaiSdkBuilder.sharedInstance;
    self.model.showBackButton = YES;
    self.model.otherParams = @{@"Test": @"abc"};
    self.model.enableLog = YES;
    ChatWebViewController *viewController = [builder buildSdkWithParams: self.model];
    viewController.viewDelegate = self;
    viewController.title = @"Support Center";
    [self.navigationController presentViewController:viewController animated:YES completion:^{
        
    }];
}

- (IBAction)pushViewController:(id)sender {
    VocaiSdkBuilder *builder = VocaiSdkBuilder.sharedInstance;
    self.model.showBackButton = YES;
    self.model.otherParams = @{@"Test": @"abc"};
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



// Implement delegate methods
- (void)messageCenter:(id)center didHaveNewMessage:(BOOL)hasNewMessage forChatId:(nonnull NSString *)chatId {
    // Update UI or perform other operations
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString* text = [NSString stringWithFormat:@"%@ -- %@", @"Has Message?", @(hasNewMessage)];
        NSLog(@"%@", text);
        self.displayLabel.text = text;
    });
}

- (void)dealloc {
    // Remove observer
    [[VocaiMessageCenter sharedInstance] removeObserver:self];
    
    // Stop auto-refresh (if started previously)
    [[VocaiMessageCenter sharedInstance] stopAllAutoRefresh];
}

-(void) changeUser {
    
}


- (BOOL) voaiShouldOpenURL:(NSURL*) url {
    return YES;
}

- (void) voaiNeedToOpenURLAction:(NSURL*) url {
    NSLog(@"Opening URL:\n%@", url);
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL status){
        NSLog(@"Done.");
    }];
}

@end
