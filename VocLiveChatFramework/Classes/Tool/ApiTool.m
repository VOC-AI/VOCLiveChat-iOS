//
//  ApiTool.m
//  Pods
//
//  Created by Boyuan Gao on 2025/5/27.
//

#import "ApiTool.h"
#import <VocLiveChatFramework/VocaiChatModel.h>

@interface VocaiApiTool()

@property (nonatomic, copy) VocaiChatModel* params;

@end

@implementation VocaiApiTool

-(instancetype) initWithParams: (VocaiChatModel*)model {
    self = [super init];
    if (self) {
        self.params = [model copy];
    }
    return self;
}

-(NSString*) apiHost {
    VOCLiveChatEnv env = self.params.env;
    if(env == VOCLiveChatEnvStaging) {
        return @"https://apps-staging.voc.ai";
    }
    return @"https://apps.voc.ai";
}

-(NSString*) getApiWithPathname:pathname {
    return [NSString stringWithFormat:@"%@%@", self.apiHost,pathname];
}

@end

