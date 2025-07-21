//
//  VocaiPDFDisplayView.h
//  abc
//
//  Created by 刘志康 on 2025/3/5.
//
#import <UIKit/UIKit.h>
#import <PDFKit/PDFKit.h>

@protocol VocaiPDFDisplayViewDelegate;

@interface VocaiPDFDisplayView : UIView

// 初始化方法，传入远程 PDF 文件的 URL
- (instancetype)initWithFrame:(CGRect)frame pdfURL:(NSURL *)pdfURL;

@property (nonatomic, weak) id<VocaiPDFDisplayViewDelegate> delegate;


@end

@protocol VocaiPDFDisplayViewDelegate <NSObject>

- (void)PDFDisplayViewDidClose:(VocaiPDFDisplayView *)view;

@end
