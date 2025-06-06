//
//  ChatWebViewController.m
//  abc
//
//  Created by 刘志康 on 2025/2/25.
//

#import "ChatWebViewController.h"
#import <WebKit/WebKit.h>
#import "UserModel.h"
#import "WebCallBackModel.h"
#import "VocaiAVCaptureViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "VocaiRandomStringGenerator.h"
#import "VocaiPollingRequestTool.h"
#import "VocaiChatModel.h"
#import "VocaiLanguageTool.h"
#import "PDFDisplayView.h"
#import "VocaiApiTool.h"
#import "VocaiLogger.h"
#import "VocaiChatView.h"
#import "VocaiMessageCenter.h"

// 定义屏幕宽度宏
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
// 定义屏幕高度宏
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface ChatWebViewController ()

@property(nonatomic, strong) VocaiChatView* chatView;

@end

@implementation ChatWebViewController

-(void) initChatView {
    if(self.chatView) {
        return;
    }
    self.view.backgroundColor = UIColor.redColor;
    self.chatView = [[VocaiChatView alloc] initWithFrame:self.view.bounds];
    self.chatView.viewController = self;
    [self.view addSubview:self.chatView];
}


- (instancetype)initWithParameter:(VocaiChatModel *)parameter {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        [self initChatView];
        [self.chatView setParameter:parameter];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor: [UIColor whiteColor]];
    self.automaticallyAdjustsScrollViewInsets = YES;
    [self initChatView];
    [self setWebViewAnchor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    VocaiMessageCenter* center = [VocaiMessageCenter sharedInstance];
    if (center) {
        [center postUnreadStatus:NO forChatId:nil];
        [center fetchUnreadCountForChatId:nil];
    }
    if (self.viewDelegate != nil && [self.viewDelegate respondsToSelector:@selector(vocaiViewControllerWillAppear:animated:)]) {
        [self.viewDelegate vocaiViewControllerWillAppear:self animated:animated];
    }
}

- (void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    VocaiMessageCenter* center = [VocaiMessageCenter sharedInstance];
    if (center) {
        [center postUnreadStatus:NO forChatId:nil];
        [center fetchUnreadCountForChatId:nil];
    }
    if (self.viewDelegate != nil && [self.viewDelegate respondsToSelector:@selector(vocaiViewControllerWillDisappear:animated:)]) {
        [self.viewDelegate vocaiViewControllerWillDisappear:self animated:animated];
    }
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.viewDelegate != nil && [self.viewDelegate respondsToSelector:@selector(vocaiViewControllerDidAppear:animated:)]) {
        [self.viewDelegate vocaiViewControllerDidAppear:self animated:animated];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.viewDelegate != nil && [self.viewDelegate respondsToSelector:@selector(vocaiViewControllerDidDisappear:animated:)]) {
        [self.viewDelegate vocaiViewControllerDidDisappear:self animated:animated];
    }
}

- (void)setParameter:(VocaiChatModel *)parameter {
    [self.chatView setParameter:parameter];
}

- (void)switchUser:(NSString *)userId {
    [self.chatView switchUser:userId];
}

- (void)setWebViewAnchor {
    [self initChatView];
    self.chatView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *topConstraint, *leadingConstraint, *trailingConstraint, *bottomConstraint;
    id guide = nil;
    if (@available(iOS 11.0, *)) {
        guide = self.view.safeAreaLayoutGuide;
    } else {
        guide = self.view;
    }
    topConstraint = [NSLayoutConstraint constraintWithItem:self.chatView
                                                  attribute:NSLayoutAttributeTop
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:guide
                                                  attribute:NSLayoutAttributeTop
                                                 multiplier:1.0
                                                   constant:0];

    leadingConstraint = [NSLayoutConstraint constraintWithItem:self.chatView
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:guide
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1.0
                                                      constant:0];

    trailingConstraint = [NSLayoutConstraint constraintWithItem:self.chatView
                                                      attribute:NSLayoutAttributeTrailing
                                                      relatedBy:NSLayoutRelationEqual
                                                         toItem:guide
                                                      attribute:NSLayoutAttributeTrailing
                                                     multiplier:1.0
                                                       constant:0];

    bottomConstraint = [NSLayoutConstraint constraintWithItem:self.chatView
                                                        attribute:NSLayoutAttributeBottom
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:guide
                                                        attribute:NSLayoutAttributeBottom
                                                       multiplier:1.0
                                                         constant:0];
   [NSLayoutConstraint activateConstraints:@[
    topConstraint, leadingConstraint,
    trailingConstraint, bottomConstraint,
   ]];
}

@end
