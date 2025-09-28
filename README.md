## Vocai SDK Integration Documentation

---

### Integration via CocoaPods

Refer to the following configuration:

```ruby
platform :ios, '10.0'
inhibit_all_warnings!
target 'testProject' do
  pod 'VocLiveChatFramework', '1.7.1'
end
```

### Import Framework Headers

```objective-c
#import <VocLiveChatFramework/VocaiChatModel.h>
#import <VocLiveChatFramework/VocaiSdkBuilder.h>
#import <VocLiveChatFramework/VocaiMessageCenter.h>
```

### Supported Versions

iOS 10 and above

### Usage Instructions

1. **Build Initialization Parameters**:

```objective-c
NSDictionary *exampleOtherDict = nil;
VocaiChatModel *vocaiModel = [[VocaiChatModel alloc] initWithBotId:@"19365" token:@"6731F71BE4B0187458389512" email:@"zhikang@163.com" language:@"cn" otherParams:exampleOtherDict];
VocaiSdkBuilder *builder = [[VocaiSdkBuilder alloc] init];
UIViewController *viewController = [builder buildSdkWithParams:vocaiModel];
```

2. **Initialize the Model and Call the Returned ViewController**:

```objective-c
ViewController [VocaiSdkBuilder buildSdkWithParams:vocaiModel];
```

3. **Listen to View Lifecycle Events (ViewWillAppear)**:

Adopt the following protocol and set the delegate:

```objective-c
<VocaiSdkBuilderViewControllerLifecycleDelegate>
builder.sdkViewWillAppearDelegate = self;
```

Implement the corresponding delegate method:

```objective-c
- (void)vocaiSdkViewControllerWillAppear:(UIViewController *)viewController animated:(BOOL)animated;
```

4. **Monitor Unread Message Status**:

Pass parameters during view initialization and add observers. Ensure proper observer management to avoid memory leaks.

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

// Implement delegate methods
- (void)messageCenter:(id)center didHaveNewMessage:(BOOL)hasNewMessage forChatId:(nonnull NSString *)chatId {
    // Update UI or perform other operations
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"%@ -- %@", @"New Message Received", @(hasNewMessage));
    });
}

- (void)dealloc {
    // Remove observer
    [[VocaiMessageCenter sharedInstance] removeObserver:self];
    
    // Stop auto-refresh (if previously started)
    [[VocaiMessageCenter sharedInstance] stopAllAutoRefresh];
}
```

5. **Control Link Opening Behavior**:

First, set the `viewDelegate` for the obtained `ChatViewController`:

```objective-c
ChatWebViewController *viewController = [builder buildSdkWithParams:self.model];
viewController.viewDelegate = self;
```

```objective-c
- (BOOL)voaiShouldOpenURL:(NSURL*)url {
    return YES;
}

- (void)voaiNeedToOpenURLAction:(NSURL*)url {
    NSLog(@"Opening URL:\n%@", url);
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL status){
        NSLog(@"Done.");
    }];
}
```

### Troubleshooting

1. **Crash When Tapping Camera for Attachments**:
   Add the following entries to your project's `Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>Please grant camera permission.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Please grant gallery permission.</string>
```

2. **Unable to Fetch Podspec**:
   Modify the reference in your `Podfile`:

```ruby
pod 'VocLiveChatFramework', :git => 'git@github.com:VOC-AI/VOCLiveChat-iOS.git', :tag => '1.7.1'
```

3. **Post-Installation Error**:
   If you encounter the following error:
   ![Screenshot 2025-03-25 09 55 47](https://github.com/user-attachments/assets/aebe0dba-4d79-4598-9891-d77f11212631)
   
   Navigate to the following settings:
   ![41742867705_ pic](https://github.com/user-attachments/assets/0a6d22e3-b235-4d8c-aaf5-007c0c43d0c4)

4. **LiveChat Functionality Issues**:
   Ensure `botId` and `botToken` are correctly configured according to [backend settings](https://apps.voc.ai/chatbot).

5. How to implement the back button

Whether there is a back button depends on whether you are using `UINavigationController` . If you are, the behavior will be consistent with your implementation of the NavigationBar.
If the customer service chat page is opened using `presentViewController`, you can add the parameter `showBackButton = YES` when initializing `ChatViewController` to use VOCAI's built-in back button.
