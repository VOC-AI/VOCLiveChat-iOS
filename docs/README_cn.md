## vocai sdk 接入文档

---

通过cocoaPods集成 
参考如下：

```
platform :ios, '10.0'
inhibit_all_warnings!
target 'testProject' do
  pod 'VocLiveChatFramework', '1.5.9'
end
```

导入框架内头文件：

### 支持版本

iOS 10及以上

```objective-c
#import <VocLiveChatFramework/VocaiChatModel.h>
#import <VocLiveChatFramework/VocaiSdkBuilder.h>
#import <VocLiveChatFramework/VocaiMessageCenter.h>
```

### 使用方式

1. 构建初始化参数:

```objective-c
NSDictionary *exampleOtherDict = nil;
VocaiChatModel *vocaiModel = [[VocaiChatModel alloc] initWithBotId:@"19365" token:@"6731F71BE4B0187458389512" email:@"zhikang@163.com" language:@"cn" otherParams:exampleOtherDict];
VocaiSdkBuilder *builder = [[VocaiSdkBuilder alloc] init];
UIViewController *viewController = [builder buildSdkWithParams: vocaiModel];
```

2. 初始化模型以及调用返回的

```objective-c
ViewController [VocaiSdkBuilder buildSdkWithParams: vocaiModel];
```

3. 如果要监听视图生命周期的ViewWillAppear: 则遵循下面的协议， 设置好代理

```objective-c
<VocaiSdkBuilderViewControllerLifecycleDelegate>
builder.sdkViewWillAppearDelegate = self;
```

然后在对应的代理方法实现：

```objective-c
- (void)vocaiSdkViewControllerWillAppear:(UIViewController *)viewController animated:(BOOL)animated;
```

4. 如果要监听当前是否有未读消息的状态，需要在初始化 view 时候传入对应的参数，并添加监听。注意需要控制监听、解除监听避免内存泄露

```objective-c
- (void)viewDidLoad {
    [super viewDidLoad];
    VocaiChatModel *vocaiModel = [[VocaiChatModel alloc] initWithBotId:@"499" token:@"66D806CAE4B05062935CCFD0" email:nil language:str otherParams:nil];
    vocaiModel.uploadFileTypes = @[@"public.data"];
    VocaiMessageCenter *center = [VocaiMessageCenter sharedInstance];
    [center setParams:vocaiModel];
    [center addObserver:self];
    [center startAutoRefresh];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



// 实现代理方法
- (void)messageCenter:(id)center didHaveNewMessage:(BOOL)hasNewMessage forChatId:(nonnull NSString *)chatId {
    // 更新UI或执行其他操作
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"%@ -- %@", @"New Message Received", @(hasNewMessage));
    });
}

- (void)dealloc {
    // 移除观察者
    [[VocaiMessageCenter sharedInstance] removeObserver:self];
    
    // 停止自动刷新（如果之前启动过）
    [[VocaiMessageCenter sharedInstance] stopAllAutoRefresh];
}

```

5. 操控是否打开链接，以及重载链接具体的打开方式

首先将获取到的 `ChatViewController` 设置 `viewDelegate`

```objective-c
ChatWebViewController *viewController = [builder buildSdkWithParams: self.model];
viewController.viewDelegate = self;
```

```objective-c
- (BOOL) voaiShouldOpenURL:(NSURL*) url {
    return YES;
}

- (void) voaiNeedToOpenURLAction:(NSURL*) url {
    NSLog(@"Opening URL:\n%@", url);
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL status){
        NSLog(@"Done.");
    }];
}
```

### Trouble shooting

1. 附件点击相机时发生崩溃，需要编辑工程的 plist 文件，增加如下选项

```xml
  <key>NSCameraUsageDescription</key>
  <string>Please grant camera permission.</string>
  <key>NSPhotoLibraryUsageDescription</key>
  <string>Please grant gallery permission.</string>
```

2. 包拉不到怎么办？改下 Podfile 里的引用方式

```ruby
pod 'VocLiveChatFramework', :git => 'git@github.com:VOC-AI/VOCLiveChat-iOS.git', :tag => '1.6.3'
```


3. 安装好之后如果有如下报错

![截屏2025-03-25 09 55 47](https://github.com/user-attachments/assets/aebe0dba-4d79-4598-9891-d77f11212631)

需要到这里设置：

![41742867705_ pic](https://github.com/user-attachments/assets/0a6d22e3-b235-4d8c-aaf5-007c0c43d0c4)

4. LiveChat 功能异常怎么解决？

botId 和 botToken 的传入应该取决于 [后台配置](https://apps.voc.ai/chatbot)

5. 关于返回按钮如何实现

- 首先是否有返回按钮取决于您是否使用 UINavigationController, 如果使用的话，表现效果会和您实现的 NavigationBar 的效果一直。
- 如果客服会话页面是被 presentViewController 打开的，您可以在初始化 `ChatViewController` 时，在参数里添加 `showBackButton = YES`参数，使用 VOCAI 自带的返回按钮