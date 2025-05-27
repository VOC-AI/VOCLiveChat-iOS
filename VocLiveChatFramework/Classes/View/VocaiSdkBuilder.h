//
//  VocaiSdkBuilder.h
//  abc
//
//  Created by 刘志康 on 2025/3/6.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <VocLiveChatFramework/VocaiChatModel.h>
#import <VocLiveChatFramework/ChatWebViewController.h>

NS_ASSUME_NONNULL_BEGIN


@protocol VocaiSdkBuilderViewControllerLifecycleDelegate <NSObject>

@optional
- (void)vocalSdkViewControllerWillAppear:(UIViewController *)viewController animated:(BOOL)animated __attribute__((deprecated("Use vocaiSdkViewControllerWillAppear: instead")))
NS_DEPRECATED_IOS(1.0.0, 0.0.0, "vocaiViewControllerWillAppear:", "This method name has a typo. Use vocaiSdkViewControllerWillAppear: instead");

@optional
- (void)vocaiSdkViewControllerWillAppear:(UIViewController *)viewController animated:(BOOL)animated;

@end

@interface VocaiSdkBuilder : NSObject <VocalViewControllerLifecycleDelegate>
@property (nonatomic, weak) id<VocaiSdkBuilderViewControllerLifecycleDelegate> sdkViewWillAppearDelegate;

- (void)sdkViewWillAppear:(UIViewController *)viewController animated:(BOOL)animated;

- (UIViewController *)buildSdkWithParams: (VocaiChatModel *)params;
- (UINavigationController *)buildSdkNavigationControllerWithParams: (VocaiChatModel *)params navigationColor: (UIColor *)navigationColor title:(NSString *)title;

@end

NS_ASSUME_NONNULL_END
