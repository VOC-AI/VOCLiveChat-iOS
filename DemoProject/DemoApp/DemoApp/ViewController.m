//
//  ViewController.m
//  DemoApp
//
//  Created by 刘志康 on 2025/4/2.
//

#import "ViewController.h"

#import "VocalWebcomponent/VocaiChatModel.h"
#import "VocalWebcomponent/VocaiSdkBuilder.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (void)buttonClicked {
     
    NSDictionary *exampleOtherDict = nil;
    VocaiChatModel *vocaiModel = [[VocaiChatModel alloc] initWithBotId:@"19365" token:@"6731F71BE4B0187458389512" email:@"zhikang@163.com" language:@"cn" otherParams:nil];
    VocaiSdkBuilder *builder = [[VocaiSdkBuilder alloc] init];
    UIViewController *viewController = [builder buildSdkWithParams: vocaiModel];
    
    viewController.navigationItem.title = @"标题2";
    [self.navigationController pushViewController:viewController animated:true];
}

@end
