//
//  PDFDisplayView.m
//  abc
//
//  Created by 刘志康 on 2025/3/5.
//

#import "PDFDisplayView.h"

@interface PDFDisplayView () <NSURLSessionDataDelegate>

@property (nonatomic, strong) PDFView *pdfView;
@property (nonatomic, strong) NSURL *pdfURL;
@property (nonatomic, strong) NSMutableData *downloadedData;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation PDFDisplayView

- (instancetype)initWithFrame:(CGRect)frame pdfURL:(NSURL *)pdfURL {
    self = [super initWithFrame:frame];
    if (self) {
        self.pdfURL = pdfURL;
        self.downloadedData = [NSMutableData data];
        [self setupPDFView];
        [self setupCloseButton];
        [self setupActivityIndicator];
        [self startDownload];
    }
    return self;
}

- (void)setupPDFView {
    self.pdfView = [[PDFView alloc] initWithFrame:self.bounds];
    self.pdfView.autoScales = YES;
    [self addSubview:self.pdfView];
}

- (void)setupCloseButton {
    self.closeButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [self.closeButton setImage: [UIImage imageNamed:@"close"] forState: UIControlStateNormal];
    [self.closeButton setTitleColor: [UIColor blackColor] forState:UIControlStateNormal];
    [self.closeButton addTarget:self action:@selector(closeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    self.closeButton.frame = CGRectMake(self.bounds.size.width - 60, 60, 25, 25);
    [self addSubview:self.closeButton];
}

- (void)setupActivityIndicator {
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    self.activityIndicator.center = self.center;
    [self addSubview:self.activityIndicator];
}

- (void)startDownload {
    [self.activityIndicator startAnimating];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    NSURLSessionDataTask *task = [session dataTaskWithURL:self.pdfURL];
    [task resume];
}

// NSURLSessionDataDelegate 方法，接收到响应时调用
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    completionHandler(NSURLSessionResponseAllow);
}

// NSURLSessionDataDelegate 方法，接收到数据时调用
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [self.downloadedData appendData:data];
}

// NSURLSessionDataDelegate 方法，任务完成时调用
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicator stopAnimating];
        [self.activityIndicator removeFromSuperview];
    });
    
    if (error) {
        NSLog(@"Download PDF error: %@", error.localizedDescription);
    } else {
        PDFDocument *pdfDocument = [[PDFDocument alloc] initWithData:self.downloadedData];
        if (pdfDocument) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.pdfView.document = pdfDocument;
            });
        }
    }
}

- (void)closeButtonTapped {
    [self removeFromSuperview];
    if ([self.delegate respondsToSelector:@selector(PDFDisplayViewDidClose:)]) {
        [self.delegate PDFDisplayViewDidClose:self];
    }
}

@end
