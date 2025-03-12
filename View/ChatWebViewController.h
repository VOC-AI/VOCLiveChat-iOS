//
//  ChatWebViewController.h
//  abc
//
//  Created by 刘志康 on 2025/2/25.
//

#import <UIKit/UIKit.h>
#import "VocaiChatModel.h"

// 在视图控制器的头文件中声明 WKWebView 属性
@interface ChatWebViewController : UIViewController
- (instancetype)initWithParameter:(VocaiChatModel *)parameter;
@end
