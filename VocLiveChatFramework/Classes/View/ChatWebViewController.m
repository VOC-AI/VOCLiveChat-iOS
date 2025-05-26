//
//  ChatWebViewController.m
//  abc
//
//  Created by 刘志康 on 2025/2/25.
//

#import "ChatWebViewController.h"
#import <WebKit/WebKit.h>
#import "CustomOptionsView.h"
#import "ImageUploader.h"
#import "UserModel.h"
#import "WebCallBackModel.h"
#import "AVCaptureViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "RandomStringGenerator.h"
#import "PollingRequestTool.h"
#import "VocaiChatModel.h"
#import "LanguageTool.h"
#import "PDFDisplayView.h"
#import <AVFoundation/AVFoundation.h>
#import <objc/runtime.h>

// 定义文件上传类型
typedef NS_ENUM(NSInteger, UploaFileType) {
    UploadFileTypePic = 0,
    UploadFileTypeFile = 1,
    UploadFileTypeVideo = 2,
} NS_SWIFT_NAME(UploadFileType);
// 定义屏幕宽度宏
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
// 定义屏幕高度宏
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface ChatWebViewController ()<WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIDocumentPickerDelegate, PDFDisplayViewDelegate>
@property (nonatomic, strong) VocaiChatModel *vocaiChatParams;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) UIDocumentPickerViewController *documentPicker;
@property (nonatomic, copy) NSString *randomNumber; // 用于让前端展示loading以及移除loading
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, strong) PollingRequestTool *pollingTool;
@property (nonatomic, assign) UploaFileType uploaFileType; ///  只用于上传失败的时候记录上传文件类型
@property (nonatomic, strong) PDFDisplayView *pdfDisplayView;
@property (nonatomic, copy) NSString *uploadFileMeta;

@end

// 在视图控制器的实现文件中初始化 WKWebView
@implementation ChatWebViewController

- (instancetype)initWithParameter:(VocaiChatModel *)parameter {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.vocaiChatParams = parameter;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor: [UIColor whiteColor]];
    self.automaticallyAdjustsScrollViewInsets = YES;
    // 创建 WKWebView 的配置对象
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    [configuration.userContentController addScriptMessageHandler:self name:@"VOCLivechatMessageHandler"];
    
    // 创建 WKWebView 实例
    
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) configuration:configuration];
    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
    
    // 将 WKWebView 添加到视图中
    [self.view addSubview:self.webView];
    [self setWebViewAnchor];
    // 设置要加载的URL   这里的ID是botId
    
    NSString *urlString = [NSString stringWithFormat:
                           @"https://apps.voc.ai/live-chat?id=%@&token=%@&disableFileInputModal=true&lang=%@&email=%@&",
                           self.vocaiChatParams.botId,
                           self.vocaiChatParams.token,
                           self.vocaiChatParams.language,
                           self.vocaiChatParams.email];
    NSString *componentUrlString = [urlString stringByAppendingString: [self dictionaryToQueryString:self.vocaiChatParams.otherParams]];
    NSURL *url = [NSURL URLWithString: componentUrlString];
      NSURLRequest *request = [NSURLRequest requestWithURL: url];
     // 添加消息处理脚本，这里的 @"messageHandler" 是前端调用的标识
    
    [self.webView loadRequest:request];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.viewDelegate != nil) {
        [self.viewDelegate vocaiViewControllerWillAppear:self animated:animated];
    }
}

- (void)setWebViewAnchor {
    // 设置约束
       self.webView.translatesAutoresizingMaskIntoConstraints = NO;
       NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self.webView
                                                                        attribute:NSLayoutAttributeTop
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.view.safeAreaLayoutGuide
                                                                        attribute:NSLayoutAttributeTop
                                                                       multiplier:1.0
                                                                         constant:0];
       NSLayoutConstraint *leadingConstraint = [NSLayoutConstraint constraintWithItem:self.webView
                                                                             attribute:NSLayoutAttributeLeading
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self.view.safeAreaLayoutGuide
                                                                             attribute:NSLayoutAttributeLeading
                                                                            multiplier:1.0
                                                                              constant:0];
       NSLayoutConstraint *trailingConstraint = [NSLayoutConstraint constraintWithItem:self.webView
                                                                              attribute:NSLayoutAttributeTrailing
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:self.view.safeAreaLayoutGuide
                                                                              attribute:NSLayoutAttributeTrailing
                                                                             multiplier:1.0
                                                                               constant:0];
       NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self.webView
                                                                            attribute:NSLayoutAttributeBottom
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.view
                                                                            attribute:NSLayoutAttributeBottom
                                                                           multiplier:1.0
                                                                             constant:0];
       [NSLayoutConstraint activateConstraints:@[topConstraint, leadingConstraint, trailingConstraint, bottomConstraint]];
}


// Objective - C
- (void)dealloc {
    self.webView.UIDelegate = nil;
    self.webView.navigationDelegate = nil;
    [self.webView stopLoading];
    [self.webView removeFromSuperview];
    self.webView = nil;
}

-(void)showPickView {
    CustomOptionsView *optionsView = [[CustomOptionsView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) language:self.vocaiChatParams.language];
    
    optionsView.language = self.vocaiChatParams.language;
        optionsView.optionSelectedBlock = ^(NSString *selectedOption) {
            
            NSString *videoString = [LanguageTool getStringForKey:@"key_take_video" withLanguage:self.vocaiChatParams.language];
            NSString *galleryString = [LanguageTool getStringForKey:@"key_choose_from_gallery" withLanguage:self.vocaiChatParams.language];
            NSString *fileString = [LanguageTool getStringForKey:@"key_choose_from_file" withLanguage:self.vocaiChatParams.language];
            NSString *takePhotoString = [LanguageTool getStringForKey:@"key_take_photo" withLanguage:self.vocaiChatParams.language];
            if ([selectedOption isEqualToString: takePhotoString]){
                BOOL isAuthorized = hasCameraPermission();
                if (isAuthorized) {
                    [self openCamera];
                } else {
                    // 模拟调用显示无权限 Toast 的方法
                    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                        if (granted) {
                            // 任务完成后回到主线程更新UI
                            dispatch_async(dispatch_get_main_queue(), ^{
                                 // 更新UI或执行其他必须在主线程的操作
                                [self openCamera];
                             });
                            // 继续进行需要摄像头的操作
                        } else {
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                // 后台任务...
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [self showNoPermissionToastOnView:self.view message:@"No camera permission. Please go to the Settings Center to enable it."];
                                });
                            });
                        }
                    }];
                }
            }
            if ([selectedOption isEqualToString: videoString]){
                BOOL isAuthorized = hasCameraPermission();
                if (isAuthorized) {
                    [self startVideoRecording];
                } else {
                    // 模拟调用显示无权限 Toast 的方法
                    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                        if (granted) {
                            // 任务完成后回到主线程更新UI
                            dispatch_async(dispatch_get_main_queue(), ^{
                                 // 更新UI或执行其他必须在主线程的操作
                                [self startVideoRecording];
                             });
                            // 继续进行需要摄像头的操作
                        } else {
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                // 后台任务...
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [self showNoPermissionToastOnView:self.view message:@"No camera permission. Please go to the Settings Center to enable it."];
                                });
                            });
                        }
                    }];
                }
            }
            
            if ([selectedOption isEqualToString: galleryString]){
                [self openAlbum];
            }
            if ([selectedOption isEqualToString: fileString]){
                [self openFilePicker];
            }
        };
    [optionsView showInWindow];
}

- (void)openCamera {
    // 判断相机可不可用
    BOOL isCamera = [UIImagePickerController isCameraDeviceAvailable: UIImagePickerControllerCameraDeviceFront];
    if (!isCamera) {
        NSLog(@"No camera available");
        return;
    }
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.allowsEditing = NO;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)openAlbum {
    // 检查设备是否支持打开相册
      if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
          // 创建 UIImagePickerController 实例
          self.imagePickerController = [[UIImagePickerController alloc] init];
          // 设置相册为图片选择器的数据源
          self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
          // 设置代理
          self.imagePickerController.delegate = self;
          // 允许选择视频和照片
          self.imagePickerController.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
          // 弹出相册选择界面
          [self presentViewController:self.imagePickerController animated:YES completion:nil];
      } else {
          NSLog(@"No gallery available");
      }
}


- (void)startVideoRecording {
    // 检查设备是否支持视频拍摄
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.mediaTypes = @[(NSString *)kUTTypeMovie]; // 指定媒体类型为视频
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    } else {
        NSLog(@"Video not supported");
    }
}

/// MARK: WkWebView 协议

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    if ([message.name isEqualToString:@"VOCLivechatMessageHandler"]) {
           // 获取前端传递过来的数据
           id data = message.body;
           NSLog(@"Data received: %@", data);
            if ([data isKindOfClass:[NSDictionary class]]) {
                WebCallBackModel *callBackModel = [self convertDictionaryToModel:data];
                
                if ([callBackModel.type isEqualToString: @"Livechat_Input_File"]) {
                    [self showPickView];
                }
                            
                if ([callBackModel.type isEqualToString: @"Livechat_Click_File"]) {
                    [self displayPdfViewWithUrl:callBackModel.data.url];
                }
             }
           
           // 模拟处理数据
           NSString *responseData = @"";
            // 调用前端的回调函数
           NSString *jsCallback = [NSString stringWithFormat:@"frontendCallback('%@')", responseData];
           [self.webView evaluateJavaScript:jsCallback completionHandler:^(id result, NSError * _Nullable error) {
               if (error) {
                   NSLog(@"Eval JavaScript callback error: %@", error.localizedDescription);
               } else {
                   NSLog(@"Eval JavaScript callback success，result: %@", result);
               }
           }];
       }
}


- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"Web page loaded successfully");
}

//MARK: 图片选择器代理
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        // 获取选择的图片
        UIImage *selectedImage = info[UIImagePickerControllerEditedImage];
        if (!selectedImage) {
            selectedImage = info[UIImagePickerControllerOriginalImage];
        }
        NSURL *imageURL = info[UIImagePickerControllerReferenceURL];
        NSString *fileName = imageURL.lastPathComponent;
        
        // 在这里可以对选择的图片进行处理，例如显示在 UIImageView 上
        NSData *imageData = UIImageJPEGRepresentation(selectedImage, 0.8);
        self.randomNumber = [RandomStringGenerator randomStringWithLength:8];
        NSString *lastJs = [NSString stringWithFormat:@"handleRecieveImageLoading('%@')", self.randomNumber];
        [self.webView evaluateJavaScript: lastJs completionHandler: nil];
        self.fileName = fileName;
        [self uploadFile:imageData fileName:fileName uploadFiledType:0];
        
    } else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) { //  返回了拍摄的视频
        NSURL *videoURL = info[UIImagePickerControllerMediaURL];
        NSData *videoData = [self convertLocalVideoURLToData:videoURL];
        self.randomNumber = [RandomStringGenerator randomStringWithLength:8];
        NSString *lastJs = [NSString stringWithFormat:@"handleRecieveVideoLoading('%@')", self.randomNumber];
        [self.webView evaluateJavaScript: lastJs completionHandler: nil];
        self.fileName = videoURL.lastPathComponent;
        [self uploadFile: videoData fileName: videoURL.lastPathComponent uploadFiledType: 2];
    }
    
    // 关闭图片选择器
    [picker dismissViewControllerAnimated:YES completion:nil];
}



- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    // 用户取消选择，关闭图片选择器
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)uploadFile: (NSData *) fileData fileName:(NSString *)fileName uploadFiledType: (UploaFileType) uploadFileType {
    self.uploaFileType = uploadFileType;
    NSString *fileType = @"";
    switch (uploadFileType) {
        case UploadFileTypePic:
            fileType = @"image/jpeg";
            break;
        case UploadFileTypeFile:
            fileType = @"application/pdf";
            break;
        case UploadFileTypeVideo:
            fileType = @"video/x-msvideo";
            break;
        default:
            break;
    }

    // 上传的 URL
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:self.vocaiChatParams.botId forKey:@"botId"];
    [dict setValue:self.vocaiChatParams.chatId forKey:@"chatId"];
    [dict setValue:[NSString stringWithFormat: @"{\"uid\":\"%@\",\"type\":\"EMAIL\"}", self.vocaiChatParams.email] forKey:@"contact"];
    // 调用上传方法
    [[ImageUploader sharedUploader] uploadFile: fileData
                                      fileName: fileName
                                      fileType: fileType
                                      toURL: @"https://apps.voc.ai/api_v2/intelli/resource/upload/lead"
                                      withParams: dict
                                      progress:^(NSProgress *uploadProgress) {
                                             // 处理上传进度
                                             NSLog(@"Upload progress: %.2f%%", uploadProgress.fractionCompleted * 100);
                                         }
                                      completion:^(BOOL success, NSString * _Nullable message, NSDictionary * _Nullable response) {
                                           if (success) {
                                               NSString * url = response[@"url"];
                                               NSString *jobId = response[@"jobId"];
                                               if (isStringEmptyOrNil(jobId)) { /// 第一次传成功 不需要轮询
                                                   [self refreshWebViewWithUploadFiledType:uploadFileType toUrl:url];
                                               } else { /// 第一次上传没有成功 需要轮询
                                                   NSString *urlString = [NSString stringWithFormat:@"https://apps.voc.ai/api_v2/intelli/resource/status?jobId=%@",
                                                                          jobId];
                                                   NSURL *url = [NSURL URLWithString: urlString];
                                                   [self startPollingWithUrl: url];
                                                   self.uploadFileMeta = fileType;
                                               }
                                           } else {
                                               NSLog(@"Upload media error: %@", message);
                                           }
                                    }];
}


/**
  * submit result back to webview.
 */
- (void)refreshWebViewWithUploadFiledType: (UploaFileType) uploaFileType toUrl: (NSString*)url {
    if (uploaFileType == UploadFileTypePic) { // Picture
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *urlDict = @{@"url": url,
                                      @"reserveId": self.randomNumber};
            NSString *imageUrl = [NSString stringWithFormat:@"handleRecieveImage('%@', %@)", url, [self jsonStringFromDictionary:urlDict]];
            [self.webView evaluateJavaScript: imageUrl completionHandler:nil];
         });
    }
    
    if (uploaFileType == UploadFileTypeFile) { // File
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *dict =  @{@"reserveId": self.randomNumber,
                                    @"filename": self.fileName};
            NSString *fileUrl = [NSString stringWithFormat:@"handleRecieveFile('%@',%@)", url, [self jsonStringFromDictionary:dict]];
            [self.webView evaluateJavaScript:fileUrl completionHandler:nil];
         });
    }
    
    if (uploaFileType == UploadFileTypeVideo) { // Video
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *urlDict = @{@"url": url,
                                      @"reserveId": self.randomNumber};
            NSString *videoUrl = [NSString stringWithFormat:@"handleRecieveVideo('%@', %@)", url, [self jsonStringFromDictionary:urlDict]];
            [self.webView evaluateJavaScript: videoUrl completionHandler:nil];
         });
    }
}

- (WebCallBackModel *)convertDictionaryToModel:(NSDictionary *)dict {
    WebCallBackModel *rootModel = [[WebCallBackModel alloc] init];
    
    // 处理 type 字段
    rootModel.type = dict[@"type"];
    
    // 处理 data 字段
    NSDictionary *dataDict = dict[@"data"];
    if (dataDict) {
        UserModel *dataModel = [[UserModel alloc] init];
        dataModel.botId = [dataDict[@"botId"] integerValue];
        dataModel.chatId = dataDict[@"chatId"];
        dataModel.contact = dataDict[@"contact"];
        dataModel.url = dataDict[@"url"];
        rootModel.data = dataModel;
    }
    
    return rootModel;
}
//MARK: 文件选择器
- (void)openFilePicker {
    UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"com.adobe.pdf"] inMode:UIDocumentPickerModeImport];
    documentPicker.delegate = self;
    if (@available(iOS 11.0, *)) {
        documentPicker.allowsMultipleSelection = NO;
    } else {
        // Fallback on earlier versions
    }
    [self presentViewController:documentPicker animated:YES completion:nil];
}

#pragma mark - UIDocumentPickerDelegate
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    if (urls.count > 0) {
        NSURL *selectedURL = urls[0];
        NSError *error;
        NSData *data = [NSData dataWithContentsOfURL:selectedURL options:0 error:&error];
        if (data) {
            self.randomNumber = [RandomStringGenerator randomStringWithLength:8];
            NSString *js = [NSString stringWithFormat:@"handleRecieveFileLoading('%@')", self.randomNumber];
            self.fileName = selectedURL.lastPathComponent;
            [self.webView evaluateJavaScript: js completionHandler: nil];
            
            [self uploadFile:data fileName: self.fileName uploadFiledType: 1];
        } else {
            NSLog(@"Reading documenet error: %@", error.localizedDescription);
        }
    }
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    // 用户取消选择，关闭文件选择器界面
    [controller dismissViewControllerAnimated:YES completion:nil];
}


// 本地视频URL转NSData
- (NSData *)convertLocalVideoURLToData:(NSURL *)videoURL {
    NSError *error;
    NSData *videoData = [NSData dataWithContentsOfURL:videoURL options:NSDataReadingMappedIfSafe error:&error];
    if (error) {
        NSLog(@"Reading local video error: %@", error.localizedDescription);
        return nil;
    }
    return videoData;
}


- (void)startPollingWithUrl:(NSURL *)url {
    // 创建轮询请求工具类实例
      self.pollingTool = [[PollingRequestTool alloc] init];
      
      // 要请求的 URL
      
      // 启动轮询请求，每隔 5 秒发送一次请求
      [self.pollingTool startPollingWithURL:url interval:5 success:^(NSData * _Nullable data, NSDictionary * _Nullable response) {
          // 处理请求成功的结果
          
          NSString * url = response[@"url"];
          NSString * status = response[@"status"];
          BOOL finished = [response[@"finished"] boolValue];
          if ([status isEqualToString:@"COMPLETE"] && finished) {
              [self refreshWebViewWithUploadFiledType: self.uploaFileType toUrl:url];
              [self.pollingTool stopPolling];
          }
      } failure:^(NSError * _Nullable error) {
          // 处理请求失败的情况
          NSLog(@"Request error: %@", error.localizedDescription);
      }];
}

BOOL isStringEmptyOrNil(NSString *string) {
    if (string == nil) {
        return YES;
    }
    NSString *trimmedString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return trimmedString.length == 0;
}

- (NSString *)jsonStringFromDictionary:(NSDictionary *)dictionary {
    if (!dictionary) {
        return nil;
    }
    NSError *error;
    // 将字典转换为 JSON 数据
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if (error) {
        NSLog(@"JSON serialization error: %@", error.localizedDescription);
        return nil;
    }
    // 将 JSON 数据转换为字符串
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

- (void)displayPdfViewWithUrl:(NSString *)url {
    NSURL *pdfURL = [NSURL URLWithString: url];
    self.pdfDisplayView = [[PDFDisplayView alloc] initWithFrame:self.view.bounds pdfURL: pdfURL];
    self.pdfDisplayView.delegate = self;
    [self.view addSubview:self.pdfDisplayView];
}

- (void)PDFDisplayViewDidClose:(PDFDisplayView *)view {
    NSLog(@"PDF 显示视图已关闭");
    // 可以在这里添加其他关闭后的处理逻辑
}

-(NSString *)dictionaryToQueryString:(NSDictionary *)dictionary {
    NSMutableArray *components = [NSMutableArray array];
    for (id key in dictionary) {
        id value = dictionary[key];
        NSString *encodedKey = [key stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSString *encodedValue = [value stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSString *component = [NSString stringWithFormat:@"%@=%@", encodedKey, encodedValue];
        [components addObject:component];
    }
    return [components componentsJoinedByString:@"&"];
}

// 封装的检测摄像头权限的方法
BOOL hasCameraPermission(void) {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    return authStatus == AVAuthorizationStatusAuthorized;
}

// 封装显示无权限 Toast 的方法
- (void)showNoPermissionToastOnView:(UIView *)view message:(NSString *)message {
    UILabel *toastLabel = [[UILabel alloc] init];
    toastLabel.text = message;
    toastLabel.textAlignment = NSTextAlignmentCenter;
    toastLabel.textColor = [UIColor whiteColor];
    toastLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    toastLabel.layer.cornerRadius = 5;
    toastLabel.clipsToBounds = YES;
    toastLabel.font = [UIFont systemFontOfSize:14];
    [toastLabel sizeToFit];
    toastLabel.frame = CGRectMake((view.bounds.size.width - toastLabel.bounds.size.width) / 2,
                                  view.bounds.size.height - 100,
                                  toastLabel.bounds.size.width + 20,
                                  toastLabel.bounds.size.height + 10);
    
    [view addSubview:toastLabel];
    
    [UIView animateWithDuration:0.2 animations:^{
        toastLabel.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 delay:2.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            toastLabel.alpha = 0;
        } completion:^(BOOL finished) {
            [toastLabel removeFromSuperview];
        }];
    }];
}

@end
