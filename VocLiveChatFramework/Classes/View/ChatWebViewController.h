//
//  ChatWebViewController.h
//  abc
//
//  Created by 刘志康 on 2025/2/25.
//

#import <UIKit/UIKit.h>
#import "VocaiChatModel.h"

@protocol VocaiViewControllerLifecycleDelegate <NSObject>
@optional
- (void)vocaiViewControllerWillAppear:(UIViewController *)viewController animated:(BOOL)animated;

@optional
- (void)vocaiViewControllerDidAppear:(UIViewController *)viewController animated:(BOOL)animated;

@optional
- (void)vocaiViewControllerWillDisappear:(UIViewController *)viewController animated:(BOOL)animated;
@optional
- (void)vocaiViewControllerDidDisappear:(UIViewController *)viewController animated:(BOOL)animated;

@optional
- (BOOL) voaiShouldOpenURL:(NSURL*) url;

@optional
- (void) voaiNeedToOpenURLAction:(NSURL*) url;

@optional
- (void)vocalViewControllerWillAppear:(UIViewController *)viewController animated:(BOOL)animated __attribute__((deprecated("Use vocaiViewControllerWillAppear: instead")))
NS_DEPRECATED_IOS(1.0.0, 0.0.0, "vocaiViewControllerWillAppear:", "This method name has a typo. Use vocaiViewControllerWillAppear: instead");
@end

@protocol VocalViewControllerLifecycleDelegate <VocaiViewControllerLifecycleDelegate>
@end

// 在视图控制器的头文件中声明 WKWebView 属性
@interface ChatWebViewController : UIViewController
@property (nonatomic, weak) id<VocaiViewControllerLifecycleDelegate> viewDelegate;
- (instancetype)initWithParameter:(VocaiChatModel *)parameter;
- (void) setParameter: (VocaiChatModel*)parameter;
- (void) switchUser:(NSString*) userId;

@end
