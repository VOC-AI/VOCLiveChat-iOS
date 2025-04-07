//
//  ViewController.m
//  PodDemoApp
//
//  Created by 刘志康 on 2025/4/3.
//

#import "ViewController.h"
#import "VocalWebcomponent/VocaiChatModel.h"
#import "VocalWebcomponent/VocaiSdkBuilder.h"
#import "CustomNavigationController.h"

@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
        // 创建按钮
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(100, 200, 200, 50);
    [button setTitle:@"点击跳转" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
        
        // 将按钮添加到视图上
    [self.view addSubview:button];
//    self.navigationItem.title = @"导航栏1";
}



- (void)buttonClicked {
     
    NSDictionary *exampleOtherDict = nil;
    VocaiChatModel *vocaiModel = [[VocaiChatModel alloc] initWithBotId:@"19365" token:@"6731F71BE4B0187458389512" email:@"zhikang@163.com" language:@"cn" otherParams:nil];
    VocaiSdkBuilder *builder = [[VocaiSdkBuilder alloc] init];
    UIViewController *viewController = [builder buildSdkWithParams: vocaiModel];
    CustomNavigationController * customNav = [[CustomNavigationController alloc] initWithRootViewController:viewController];
    builder.sdkViewWillAppearDelegate = self;
    viewController.navigationItem.title = @"导航栏2";
    self.navigationController.navigationBar.backgroundColor = [UIColor grayColor];
    [self.navigationController pushViewController:viewController animated:true];
}

@end
