//
//  AVCaptureViewController.h
//  abc
//
//  Created by 刘志康 on 2025/2/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^VideoDataCallback)(NSData *videoData);

@interface AVCaptureViewController : UIViewController
@property (nonatomic, copy) VideoDataCallback videoDataCallback;
@end

NS_ASSUME_NONNULL_END
