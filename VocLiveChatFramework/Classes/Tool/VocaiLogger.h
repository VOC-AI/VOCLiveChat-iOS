//
//  VocaiLogger.h
//  Pods
//
//  Created by Boyuan Gao on 2025/5/27.
//

#import <Foundation/Foundation.h>
#import "VocaiChatModel.h"

@interface VocaiLogger:NSObject

-(instancetype) initWithParams:(VocaiChatModel*)params;

-(void) log:(NSString*)format, ...;

@end
