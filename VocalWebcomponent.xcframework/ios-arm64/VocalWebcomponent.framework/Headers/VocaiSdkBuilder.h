//
//  VocaiSdkBuilder.h
//  abc
//
//  Created by 刘志康 on 2025/3/6.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "VocaiChatModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface VocaiSdkBuilder : NSObject
+ (UIViewController *)buildSdkWithParams: (VocaiChatModel *)params;
@end

NS_ASSUME_NONNULL_END
