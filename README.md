vocai sdk 接入文档

添加依赖 在需要使用本项目的工程中把VocalWebcomponent.framework 拖到工程下面。 效果如下： 
![截屏2025-03-06 22 25 10](https://github.com/user-attachments/assets/82c3951b-5208-47b4-a8ae-b3174b400309)


设置frameWork的ember模式：需要在工程的General 下找到Frame 的设置。 将我们的frame设置成Embed & Sign
![截屏2025-03-06 22 28 26](https://github.com/user-attachments/assets/556f3943-711b-4235-a80d-f45b53f2943f)


导入框架内头文件： #import "VocalWebcomponent/VocaiChatModel.h" #import "VocalWebcomponent/VocaiSdkBuilder.h"

构建初始化模型: NSDictionary *exampleOtherDict = @{@"value":@"october"}; VocaiChatModel *vocaiModel = [[VocaiChatModel alloc] initWithId:@"" token:@"" email:@"zhikang@163.com" botId:@"19365" language:@"cn" otherParams:exampleOtherDict];

初始化模型以及调用返回的ViewController [VocaiSdkBuilder buildSdkWithParams: vocaiModel];
