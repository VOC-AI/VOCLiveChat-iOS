//
//  VocaiLogger.m
//  Pods
//
//  Created by Boyuan Gao on 2025/5/27.
//

#import "VocaiLogger.h"

@interface VocaiLogger()

@property (nonatomic, copy) VocaiChatModel* model;

@end

@implementation VocaiLogger

-(instancetype) initWithParams:(VocaiChatModel *)params {
    self = [super init];
    if(self) {
        self.model = [params copy];
    }
    return self;
}


-(void) log:(NSString*)format, ... {
    va_list args;
    va_start(args, format);
    if(!self.model.enableLog) {
        return;
    }
    NSString *logString = [[NSString alloc] initWithFormat:[NSString stringWithFormat:@"[VOC.AI] %@", format] arguments:args];
    NSLog(@"%@", logString);
}

@end
