//
//  ChatWebViewController.h
//  abc
//
//  Created by 刘志康 on 2025/2/25.
//

#import <UIKit/UIKit.h>
#import "VocaiChatModel.h"

@protocol VocalViewControllerLifecycleDelegate <NSObject>
@optional
- (void)vocalViewControllerWillAppear:(UIViewController *)viewController animated:(BOOL)animated;
@end

// 在视图控制器的头文件中声明 WKWebView 属性
@interface ChatWebViewController : UIViewController
@property (nonatomic, weak) id<VocalViewControllerLifecycleDelegate> viewDelegate;
- (instancetype)initWithParameter:(VocaiChatModel *)parameter;
@end
