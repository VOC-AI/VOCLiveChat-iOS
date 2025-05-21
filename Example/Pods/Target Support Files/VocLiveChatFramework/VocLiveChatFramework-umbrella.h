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
#import "WebCallBackModel.h"
#import "VocaiChatModel.h"
#import "ImageUploader.h"
#import "LanguageTool.h"
#import "PollingRequestTool.h"
#import "RandomStringGenerator.h"
#import "AVCaptureViewController.h"
#import "ChatWebViewController.h"
#import "CustomOptionsView.h"
#import "NetworkTool.h"
#import "PDFDisplayView.h"
#import "VocaiSdkBuilder.h"

FOUNDATION_EXPORT double VocLiveChatFrameworkVersionNumber;
FOUNDATION_EXPORT const unsigned char VocLiveChatFrameworkVersionString[];

