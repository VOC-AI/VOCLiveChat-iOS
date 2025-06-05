//
//  ApiTool.h
//  Pods
//
//  Created by Boyuan Gao on 2025/5/27.
//
#import <Foundation/Foundation.h>
#import <VocLiveChatFramework/VocaiChatModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface VocaiApiTool : NSObject

-(instancetype) initWithParams: (VocaiChatModel*)model;
+(NSArray<NSString*>*) availableHosts;
-(NSString*) apiHost;
-(NSString*) getApiWithPathname:pathname;

@end

NS_ASSUME_NONNULL_END
