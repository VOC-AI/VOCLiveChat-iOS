//
//  VocaiChatView.h
//  Pods
//
//  Created by Boyuan Gao on 2025/6/6.
//

#import <UIKit/UIKit.h>
#import "VocaiChatModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol VocaiViewDelegate <NSObject>
@optional
- (void)vocaiViewControllerWillAppear:(UIViewController *)viewController animated:(BOOL)animated;

@optional
- (void)vocaiViewControllerDidAppear:(UIViewController *)viewController animated:(BOOL)animated;

@optional
- (void)vocaiViewControllerWillDisappear:(UIViewController *)viewController animated:(BOOL)animated;
@optional
- (void)vocaiViewControllerDidDisappear:(UIViewController *)viewController animated:(BOOL)animated;

@end


@interface VocaiChatView : UIView

@property (nonatomic, weak) id<VocaiViewDelegate> viewDelegate;
@property (nonatomic, weak) UIViewController* viewController;

- (instancetype)init;
- (instancetype)initWithParameter:(VocaiChatModel *)parameter;

- (void) setParameter: (VocaiChatModel*)parameter;
- (void) switchUser:(NSString*) userId;

@end

NS_ASSUME_NONNULL_END
