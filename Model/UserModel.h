//
//  DataModel.h
//  abc
//
//  Created by 刘志康 on 2025/2/26.
//

// DataModel.h
#import <Foundation/Foundation.h>

@interface UserModel : NSObject

@property (nonatomic, assign) NSInteger botId;
@property (nonatomic, copy) NSString *chatId;
@property (nonatomic, copy) NSString *contact;
@property (nonatomic, copy) NSString *url;
@end
