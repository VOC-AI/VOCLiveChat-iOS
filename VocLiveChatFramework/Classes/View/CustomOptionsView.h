//
//  CustomOptionsView.h
//  abc
//
//  Created by 刘志康 on 2025/2/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomOptionsView : UIView

// 定义一个block，用于处理选项点击事件
@property (nonatomic, copy) void(^optionSelectedBlock)(NSString *selectedOption);
@property(nonatomic, strong)NSString *language;
// 声明显示视图的方法
- (void)showInWindow;
- (instancetype)initWithFrame:(CGRect)frame language:(NSString *)language;
// 声明关闭视图的方法
- (void)close;
@end

NS_ASSUME_NONNULL_END
