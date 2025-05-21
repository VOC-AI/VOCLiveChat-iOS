//
//  RootModel.h
//  abc
//
//  Created by 刘志康 on 2025/2/26.
//

// RootModel.h
#import <Foundation/Foundation.h>
#import "UserModel.h"

@interface WebCallBackModel : NSObject

@property (nonatomic, strong) UserModel *data;
@property (nonatomic, copy) NSString *type;

@end

