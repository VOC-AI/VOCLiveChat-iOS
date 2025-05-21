## vocai sdk 接入文档

---

通过cocoaPods集成 
参考如下：

```
platform :ios, '12.0'
inhibit_all_warnings!
target 'testProject' do
   
  pod 'VocLiveChatFramework', '1.2.2'
end
```

安装好之后如果有如下报错

![截屏2025-03-25 09 55 47](https://github.com/user-attachments/assets/aebe0dba-4d79-4598-9891-d77f11212631)

需要到这里设置：

![41742867705_ pic](https://github.com/user-attachments/assets/0a6d22e3-b235-4d8c-aaf5-007c0c43d0c4)

导入框架内头文件：

```
#import <VocLiveChatFramework/VocaiChatModel.h>
#import <VocLiveChatFramework/VocaiSdkBuilder.h>
```

将仓库里面的图片和语言配置拖到项目里面去：


构建初始化模型:

```
NSDictionary *exampleOtherDict = nil;
VocaiChatModel *vocaiModel = [[VocaiChatModel alloc] initWithBotId:@"19365" token:@"6731F71BE4B0187458389512" email:@"zhikang@163.com" language:@"cn" otherParams:exampleOtherDict];
VocaiSdkBuilder *builder = [[VocaiSdkBuilder alloc] init];
UIViewController *viewController = [builder buildSdkWithParams: vocaiModel];
```

如果要监听视图声明周期的ViewWillAppear: 则遵循下面的协议， 设置好代理

```
   <VocaiSdkBuilderViewControllerLifecycleDelegate>
    builder.sdkViewWillAppearDelegate = self;
```

然后在对应的代理方法：

```
- (void)vocalSdkViewControllerWillAppear:(UIViewController *)viewController animated:(BOOL)animated{
```

可以拿到对应的视图控制器。该代理在对应的控制器ViewWillAppear的时候调用。
初始化模型以及调用返回的

```
ViewController [VocaiSdkBuilder buildSdkWithParams: vocaiModel];
```
