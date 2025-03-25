vocai sdk 接入文档

通过cocoaPods集成 
参考如下：
platform :ios, '12.0'
inhibit_all_warnings!
target 'testProject' do
   
  pod 'VocLiveChatFramework', '1.1.0'
end


安装好之后如果有如下报错
![截屏2025-03-25 09 55 47](https://github.com/user-attachments/assets/aebe0dba-4d79-4598-9891-d77f11212631)
需要到这里设置：
![41742867705_ pic](https://github.com/user-attachments/assets/0a6d22e3-b235-4d8c-aaf5-007c0c43d0c4)

导入框架内头文件：
#import <VocalWebcomponent/VocaiChatModel.h>
#import <VocalWebcomponent/VocaiSdkBuilder.h>


将仓库里面的图片和语言配置拖到项目里面去：


构建初始化模型: NSDictionary *exampleOtherDict = @{@"value":@"october"}; VocaiChatModel *vocaiModel = [[VocaiChatModel alloc] initWithId:@"" token:@"" email:@"zhikang@163.com" botId:@"19365" language:@"cn" otherParams:exampleOtherDict];

初始化模型以及调用返回的ViewController [VocaiSdkBuilder buildSdkWithParams: vocaiModel];
