//
//  AVCaptureViewController.m
//  abc
//
//  Created by 刘志康 on 2025/2/26.
//

#import "VocaiAVCaptureViewController.h"
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
    [self.recordButton setTitle:@"Start Recording" forState:UIControlStateNormal];
    [self.recordButton addTarget:self action:@selector(toggleRecording) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.recordButton];
}

- (void)toggleRecording {
    if ([self.movieFileOutput isRecording]) {
        [self.movieFileOutput stopRecording];
        [self.recordButton setTitle:@"Start Recording" forState:UIControlStateNormal];
    } else {
        // 获取视频保存路径
        NSString *outputPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"output.mp4"];
        NSURL *outputURL = [NSURL fileURLWithPath:outputPath];
        // 开始录制
        [self.movieFileOutput startRecordingToOutputFileURL:outputURL recordingDelegate:self];
        [self.recordButton setTitle:@"Stop Recording" forState:UIControlStateNormal];
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
    if (!videoURL) return nil;

    NSError *error = nil;
    if (videoURL.isFileURL) {
        BOOL accessed = NO;
        if ([videoURL respondsToSelector:@selector(startAccessingSecurityScopedResource)]) {
            accessed = [videoURL startAccessingSecurityScopedResource];
        }
        NSData *data = [NSData dataWithContentsOfURL:videoURL options:NSDataReadingMappedIfSafe error:&error];
        if (data && data.length > 0) {
            if (accessed) {
                [videoURL stopAccessingSecurityScopedResource];
            }
            return data;
        }

        // Try coordinated read for file-provider URLs
        NSFileCoordinator *coordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
        __block BOOL copied = NO;
        __block NSURL *copiedURL = nil;
        NSError *coordError = nil;
        [coordinator coordinateReadingItemAtURL:videoURL options:NSFileCoordinatorReadingWithoutChanges error:&coordError byAccessor:^(NSURL * _Nonnull newURL) {
            NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"vocai_capture_coordinated_%@.mp4", [[NSUUID UUID] UUIDString]]];
            NSURL *tempURL = [NSURL fileURLWithPath:tempPath];
            NSError *copyErr = nil;
            if ([[NSFileManager defaultManager] copyItemAtURL:newURL toURL:tempURL error:&copyErr]) {
                copied = YES;
                copiedURL = tempURL;
            }
        }];

        if (accessed) {
            [videoURL stopAccessingSecurityScopedResource];
        }

        if (copied && copiedURL) {
            NSData *copiedData = [NSData dataWithContentsOfURL:copiedURL options:NSDataReadingMappedIfSafe error:&error];
            [[NSFileManager defaultManager] removeItemAtURL:copiedURL error:nil];
            if (copiedData && copiedData.length > 0) {
                return copiedData;
            }
        }
        // fallthrough to export
    }

    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:videoURL options:nil];
    NSArray<NSString *> *presets = [AVAssetExportSession exportPresetsCompatibleWithAsset:asset];
    NSString *preset = AVAssetExportPresetPassthrough;
    if (![presets containsObject:preset]) {
        if (presets.count > 0) preset = presets.firstObject;
        else preset = AVAssetExportPresetHighestQuality;
    }

    NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"vocai_capture_export_%@.mp4", [[NSUUID UUID] UUIDString]]];
    NSURL *tempURL = [NSURL fileURLWithPath:tempPath];
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:asset presetName:preset];
    exporter.outputURL = tempURL;
    exporter.outputFileType = AVFileTypeMPEG4;
    exporter.shouldOptimizeForNetworkUse = YES;

    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        dispatch_semaphore_signal(sema);
    }];

    dispatch_time_t timeout = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30 * NSEC_PER_SEC));
    if (dispatch_semaphore_wait(sema, timeout) != 0) {
        NSLog(@"Video export timed out");
        return nil;
    }

    if (exporter.status == AVAssetExportSessionStatusCompleted) {
        NSData *exportedData = [NSData dataWithContentsOfURL:tempURL options:NSDataReadingMappedIfSafe error:&error];
        [[NSFileManager defaultManager] removeItemAtURL:tempURL error:nil];
        if (exportedData && exportedData.length > 0) {
            return exportedData;
        } else {
            NSLog(@"Exported video is empty or unreadable: %@", error.localizedDescription);
            return nil;
        }
    } else {
        NSLog(@"Video export failed: %@", exporter.error.localizedDescription);
        return nil;
    }
}

@end
