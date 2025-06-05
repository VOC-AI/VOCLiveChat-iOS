//
//  VocaiLogger.h
//  Pods
//
//  Created by Boyuan Gao on 2025/5/27.
//

#import <Foundation/Foundation.h>
#import "VocaiChatModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface VocaiLogger:NSObject

-(instancetype) initWithParams:(VocaiChatModel*)params;

-(void) log:(NSString*)format, ...;

@end

NS_ASSUME_NONNULL_END
