//
//  MessageCenter.h
//  Pods
//
//  Created by Boyuan Gao on 2025/5/27.
//
#import <Foundation/Foundation.h>
#import "VocaiChatModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^SuccessBlock)(NSNumber* count);

@interface VocaiMessageCenter : NSObject

-(instancetype) initWithParams: (VocaiChatModel*) model;

-(void) getUnreadMessageCountWithCallback:(SuccessBlock)callback;

@end

NS_ASSUME_NONNULL_END
