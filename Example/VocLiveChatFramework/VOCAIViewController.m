//
//  VOCAIViewController.m
//  VocLiveChatFramework
//
//  Created by 6587734 on 05/21/2025.
//  Copyright (c) 2025 6587734. All rights reserved.
//

#import "VOCAIViewController.h"
#import <VocLiveChatFramework/VocaiChatModel.h>
#import <VocLiveChatFramework/VocaiSdkBuilder.h>

@interface VOCAIViewController ()

@end

@implementation VOCAIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSDictionary *exampleOtherDict = nil;
    VocaiChatModel *vocaiModel = [[VocaiChatModel alloc] initWithBotId:@"19365" token:@"6731F71BE4B0187458389512"  otherParams:nil];
    VocaiSdkBuilder *builder = [[VocaiSdkBuilder alloc] init];
    UIViewController *viewController = [builder buildSdkWithParams: vocaiModel];
    [self.view addSubview:viewController.view];
    viewController.view.frame = self.view.frame;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
