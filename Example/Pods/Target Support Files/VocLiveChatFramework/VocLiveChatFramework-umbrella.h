#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "InitialModel.h"
#import "UserModel.h"
#import "VocaiChatModel.h"
#import "ChatWebViewController.h"
#import "VocaiSdkBuilder.h"

FOUNDATION_EXPORT double VocLiveChatFrameworkVersionNumber;
FOUNDATION_EXPORT const unsigned char VocLiveChatFrameworkVersionString[];

