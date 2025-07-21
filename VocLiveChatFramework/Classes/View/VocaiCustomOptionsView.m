//
//  CustomOptionsView.m
//  abc
//
//  Created by 刘志康 on 2025/2/26.
//
#import "VocaiCustomOptionsView.h"
#import "VocaiLanguageTool.h"
// 定义屏幕宽度宏
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
// 定义屏幕高度宏
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
@interface CustomOptionsView ()

@property (nonatomic, strong) NSArray *optionTitles;  // 存储选项标题的数组
@property (nonatomic, strong) UIButton *videoButton;
@property (nonatomic, strong) UIButton *galleryButton;
@property (nonatomic, strong) UIButton *fileButton;
@property (nonatomic, strong) UIButton *takePicButton;
@property (nonatomic, strong) UIView *whiteBgView;
@property (nonatomic, strong) UIView *firstLineView;
@property (nonatomic, strong) UIButton *cancelButton;

// 声明背景视图属性
@property (nonatomic, strong) UIView *bgView;


@end

@implementation CustomOptionsView

- (instancetype)initWithFrame:(CGRect)frame language:(NSString *)language {
    self = [super initWithFrame:frame];
    if (self) {
        self.language = language;
        self.whiteBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        self.whiteBgView.backgroundColor = [UIColor whiteColor];
        [self addSubview: self.whiteBgView];
        NSString *videoString = [VocaiLanguageTool getStringForKey:@"key_take_video" withLanguage:self.language];
        NSString *galleryString = [VocaiLanguageTool getStringForKey:@"key_choose_from_gallery" withLanguage:self.language];
        NSString *fileString = [VocaiLanguageTool getStringForKey:@"key_choose_from_file" withLanguage:self.language];
        NSString *takePhotoString = [VocaiLanguageTool getStringForKey:@"key_take_photo" withLanguage:self.language];
        NSString *cancelString = [VocaiLanguageTool getStringForKey:@"key_cancel" withLanguage:self.language];
        
        self.optionTitles = @[videoString, galleryString, fileString, takePhotoString];
        
        self.cancelButton = [UIButton buttonWithType: UIButtonTypeCustom];
        [self.cancelButton setTitle:cancelString forState: UIControlStateNormal];
        self.cancelButton.frame = CGRectMake(0, 0, kScreenWidth, 56);
        [self.cancelButton setTitleColor: [UIColor blackColor] forState: UIControlStateNormal];
        [self.cancelButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
            // 将按钮添加到视图上
        [self.whiteBgView addSubview:self.cancelButton];
        
        self.firstLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 12)];
        self.firstLineView.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1];
        [self.whiteBgView addSubview: self.firstLineView];
        
        self.videoButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 56)];
        self.videoButton.backgroundColor = [UIColor whiteColor];
        [self.videoButton setTitleColor: [UIColor blackColor] forState: UIControlStateNormal];
        [self.videoButton setTitle:self.optionTitles[0] forState:UIControlStateNormal];
        [self.videoButton addTarget:self action:@selector(handleOptionTap:) forControlEvents:UIControlEventTouchUpInside];
        [self.whiteBgView addSubview:self.videoButton];
        
        
        self.galleryButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 56)];
        self.galleryButton.backgroundColor = [UIColor whiteColor];
        [self.galleryButton setTitleColor: [UIColor blackColor] forState: UIControlStateNormal];
        [self.galleryButton setTitle:self.optionTitles[1] forState:UIControlStateNormal];
        [self.galleryButton addTarget:self action:@selector(handleOptionTap:) forControlEvents:UIControlEventTouchUpInside];
        [self.whiteBgView addSubview:self.galleryButton];
    
        self.fileButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 56)];
        self.fileButton.backgroundColor = [UIColor whiteColor];
        [self.fileButton setTitleColor: [UIColor blackColor] forState: UIControlStateNormal];
        [self.fileButton setTitle:self.optionTitles[2] forState:UIControlStateNormal];
        [self.fileButton addTarget:self action:@selector(handleOptionTap:) forControlEvents:UIControlEventTouchUpInside];
        [self.whiteBgView addSubview:self.fileButton];
        
        
        self.takePicButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 56)];
        self.takePicButton.backgroundColor = [UIColor whiteColor];
        [self.takePicButton setTitleColor: [UIColor blackColor] forState: UIControlStateNormal];
        [self.takePicButton setTitle:self.optionTitles[3] forState:UIControlStateNormal];
        [self.takePicButton addTarget:self action:@selector(handleOptionTap:) forControlEvents:UIControlEventTouchUpInside];
        [self.whiteBgView addSubview:self.takePicButton];
        
        [self setupButtonConstraints];
        
        [self setTopRoundedCornersForView: self.whiteBgView radius:15.0];
        
    }
    return self;
}

//设置约束
- (void)setupButtonConstraints {
    self.videoButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.galleryButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.fileButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.takePicButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.whiteBgView.translatesAutoresizingMaskIntoConstraints = NO;
    self.cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.firstLineView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSArray *constraints = @[
        // 水平居中
        [self.videoButton.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        [self.galleryButton.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        [self.fileButton.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        [self.takePicButton.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        [self.firstLineView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        
        // 垂直间距
        [self.cancelButton.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-30],
        [self.firstLineView.bottomAnchor constraintEqualToAnchor:self.cancelButton.topAnchor],
        [self.fileButton.bottomAnchor constraintEqualToAnchor: self.firstLineView.topAnchor],
        [self.galleryButton.bottomAnchor constraintEqualToAnchor:self.fileButton.topAnchor],
        [self.videoButton.bottomAnchor constraintEqualToAnchor:self.galleryButton.topAnchor],
        [self.takePicButton.bottomAnchor constraintEqualToAnchor:self.videoButton.topAnchor],
        
        // 等宽等高
        [self.videoButton.widthAnchor constraintEqualToAnchor:self.widthAnchor multiplier:1],
        [self.galleryButton.widthAnchor constraintEqualToAnchor:self.videoButton.widthAnchor],
        [self.fileButton.widthAnchor constraintEqualToAnchor:self.videoButton.widthAnchor],
        [self.takePicButton.widthAnchor constraintEqualToAnchor:self.videoButton.widthAnchor],
        [self.videoButton.heightAnchor constraintEqualToConstant:56],
        [self.galleryButton.heightAnchor constraintEqualToAnchor:self.videoButton.heightAnchor],
        [self.fileButton.heightAnchor constraintEqualToAnchor:self.videoButton.heightAnchor],
        [self.takePicButton.heightAnchor constraintEqualToAnchor:self.videoButton.heightAnchor],
        [self.cancelButton.heightAnchor constraintEqualToAnchor:self.videoButton.heightAnchor],
        [self.cancelButton.widthAnchor constraintEqualToAnchor:self.videoButton.widthAnchor],
        [self.firstLineView.heightAnchor constraintEqualToConstant: 12],
        [self.firstLineView.widthAnchor constraintEqualToAnchor:self.videoButton.widthAnchor],
        
        [self.whiteBgView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        [self.whiteBgView.widthAnchor constraintEqualToAnchor:self.widthAnchor multiplier:1],
        [self.whiteBgView.heightAnchor constraintEqualToConstant: 56*5 + 45],
        [self.whiteBgView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
    ];
    
    [NSLayoutConstraint activateConstraints:constraints];
    
    [self addGrayLineBelowButton: self.videoButton];
//    [self addGrayLineBelowButton: self.fileButton];
    [self addGrayLineBelowButton: self.takePicButton];
    [self addGrayLineBelowButton: self.galleryButton];
    
}
//处理按钮点击事件
- (void)handleOptionTap:(UIButton *)sender {
    NSString *selectedOption = sender.titleLabel.text;
    if (self.optionSelectedBlock) {
        self.optionSelectedBlock(selectedOption);
        [self close];
    }
}

// 显示视图的方法
- (void)showInWindow {
    // 获取当前应用的主窗口
    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    if (!window) {
        // 如果 keyWindow 为空，尝试获取 windows 数组中的第一个窗口
        window = [UIApplication.sharedApplication.windows firstObject];
    }

    self.bgView = [[UIView alloc] init];
    // 设置背景视图的背景颜色为半透明黑色
    self.bgView.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.5];

    self.bgView.userInteractionEnabled = true;
    // 创建点击手势识别器，并指定目标和动作
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close)];
    // 将点击手势识别器添加到背景视图上
    [self addGestureRecognizer:tapGesture];
    
    UITapGestureRecognizer *noActionTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(noAction)];
    // 将点击手势识别器添加到背景视图上
    [self.whiteBgView addGestureRecognizer:noActionTapGesture];

    // 设置背景视图的 frame 为屏幕的边界
    self.bgView.frame = [UIScreen mainScreen].bounds;
    

    // 将背景视图添加到主窗口上
    [window addSubview:self.bgView];
    // 将当前视图添加到主窗口上
    [window addSubview:self];
    
    self.whiteBgView.frame = CGRectMake(0, 56*5+45, kScreenWidth, 56*5+45);
    [UIView animateWithDuration:0.3
                          delay:0
         usingSpringWithDamping:0.8
          initialSpringVelocity:0.5
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        // 恢复视图的 transform 到原始状态
        self.whiteBgView.frame = CGRectMake(0, 0, kScreenWidth, 56*5+45);
    } completion:nil];
    
}

// 关闭视图的方法
- (void)close {
    // 从父视图中移除背景视图
    [self.bgView removeFromSuperview];
    // 从父视图中移除当前视图
    [self removeFromSuperview];
}

- (void)noAction {
    
}

- (void)setTopRoundedCornersForView:(UIView *)view radius:(CGFloat)radius {
    // 创建一个 UIBezierPath，设置上半边圆角
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds
                                               byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight)
                                                     cornerRadii:CGSizeMake(radius, radius)];
    
    // 创建一个 CAShapeLayer
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = view.bounds;
    maskLayer.path = maskPath.CGPath;
    
    // 设置 UIView 的遮罩层
    view.layer.mask = maskLayer;
}

- (void)addGrayLineBelowButton: (UIView *)view {
    CALayer *lineLayer = [CALayer layer];
    lineLayer.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.1].CGColor;
    lineLayer.frame = CGRectMake(10, 55, kScreenWidth-20, 1);
    [view.layer addSublayer:lineLayer];
}

@end
