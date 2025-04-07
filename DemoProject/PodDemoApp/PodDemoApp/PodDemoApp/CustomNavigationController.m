//
//  CustomNavigationBar.m
//  PodDemoApp
//
//  Created by 刘志康 on 2025/4/7.
//

// CustomNavigationController.m
#import "CustomNavigationController.h"

@interface CustomNavigationController ()

@end

@implementation CustomNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 统一设置导航栏的背景颜色
    self.navigationBar.backgroundColor = [UIColor colorWithRed:0.1 green:0.2 blue:0.3 alpha:1.0];
    self.navigationItem.title = @"标题";
    // 统一设置导航栏标题的样式
    NSMutableDictionary *titleTextAttributes = [NSMutableDictionary dictionary];
    titleTextAttributes[NSForegroundColorAttributeName] = [UIColor whiteColor];
    titleTextAttributes[NSFontAttributeName] = [UIFont boldSystemFontOfSize:18];
    self.navigationBar.titleTextAttributes = titleTextAttributes;
    
    // 统一设置返回按钮的样式
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
    backButton.title = @"返回";
    self.navigationItem.leftBarButtonItem = backButton;
}

- (void)updateStyle {
    self.navigationBar.backgroundColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1.0];
}

// 可以添加一些通用的方法，例如快速push到某个特定的ViewController
- (void)pushToSpecificViewController {
    // 这里实例化你想要push的ViewController
    UIViewController *specificVC = [[UIViewController alloc] init];
    [self pushViewController:specificVC animated:YES];
}



@end
