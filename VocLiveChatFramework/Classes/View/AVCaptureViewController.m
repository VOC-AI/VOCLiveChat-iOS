//
//  AVCaptureViewController.m
//  abc
//
//  Created by 刘志康 on 2025/2/26.
//

#import "AVCaptureViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "VocaiImageUploader.h"

@interface AVCaptureViewController () <AVCaptureFileOutputRecordingDelegate>

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureDeviceInput *videoInput;
@property (nonatomic, strong) AVCaptureDeviceInput *audioInput;
@property (nonatomic, strong) AVCaptureMovieFileOutput *movieFileOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) UIButton *recordButton;

@end

@implementation AVCaptureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 初始化捕获会话
    self.captureSession = [[AVCaptureSession alloc] init];
    [self.captureSession setSessionPreset:AVCaptureSessionPresetHigh];
    
    // 获取后置摄像头设备
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
    NSError *videoError;
    self.videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:videoDevice error:&videoError];
    if (videoError) {
        NSLog(@"Video input error: %@", videoError.localizedDescription);
        return;
    }
    if ([self.captureSession canAddInput:self.videoInput]) {
        [self.captureSession addInput:self.videoInput];
    }
    
    // 获取麦克风设备
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    NSError *audioError;
    self.audioInput = [[AVCaptureDeviceInput alloc] initWithDevice:audioDevice error:&audioError];
    if (audioError) {
        NSLog(@"Audio input error: %@", audioError.localizedDescription);
        return;
    }
    if ([self.captureSession canAddInput:self.audioInput]) {
        [self.captureSession addInput:self.audioInput];
    }
    
    // 初始化视频文件输出
    self.movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    if ([self.captureSession canAddOutput:self.movieFileOutput]) {
        [self.captureSession addOutput:self.movieFileOutput];
    }
    
    // 创建预览图层
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    self.previewLayer.frame = self.view.bounds;
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:self.previewLayer];
    
    // 开始会话
    [self.captureSession startRunning];
    
    // 创建录制按钮
    self.recordButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.recordButton.frame = CGRectMake(100, 500, 200, 50);
    [self.recordButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.recordButton setTitle:@"开始录制" forState:UIControlStateNormal];
    [self.recordButton addTarget:self action:@selector(toggleRecording) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.recordButton];
}

- (void)toggleRecording {
    if ([self.movieFileOutput isRecording]) {
        [self.movieFileOutput stopRecording];
        [self.recordButton setTitle:@"开始录制" forState:UIControlStateNormal];
    } else {
        // 获取视频保存路径
        NSString *outputPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"output.mp4"];
        NSURL *outputURL = [NSURL fileURLWithPath:outputPath];
        // 开始录制
        [self.movieFileOutput startRecordingToOutputFileURL:outputURL recordingDelegate:self];
        [self.recordButton setTitle:@"停止录制" forState:UIControlStateNormal];
    }
}

#pragma mark - AVCaptureFileOutputRecordingDelegate

- (void)captureOutput:(AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections error:(NSError *)error {
    if (error) {
        NSLog(@"Recording error: %@", error.localizedDescription);
    } else {
        NSLog(@"Video saved to: %@", outputFileURL.path);
        NSData *videoData = [self convertLocalVideoURLToData:outputFileURL];
        if (self.videoDataCallback) {
            // 通过 block 传递视频数据
            self.videoDataCallback(videoData);
        }
    }
    [self.navigationController popViewControllerAnimated:true];
}

// 本地视频URL转NSData
- (NSData *)convertLocalVideoURLToData:(NSURL *)videoURL {
    NSError *error;
    NSData *videoData = [NSData dataWithContentsOfURL:videoURL options:NSDataReadingMappedIfSafe error:&error];
    if (error) {
        NSLog(@"读取本地视频文件失败: %@", error.localizedDescription);
        return nil;
    }
    return videoData;
}

@end
