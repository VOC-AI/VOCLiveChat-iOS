//
//  VocaiSdkBuilder.m
//  abc
//
//  Created by 刘志康 on 2025/3/6.
//

#import "VocaiSdkBuilder.h"
#import "ChatWebViewController.h"
@implementation VocaiSdkBuilder
+ (UIViewController *)buildSdkWithParams: (VocaiChatModel *)params {
    return [[ChatWebViewController alloc] initWithParameter:params];
}
@end
