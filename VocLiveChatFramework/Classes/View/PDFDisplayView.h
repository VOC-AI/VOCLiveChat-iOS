//
//  PDFDisplayView.h
//  abc
//
//  Created by 刘志康 on 2025/3/5.
//
#import <UIKit/UIKit.h>
#import <PDFKit/PDFKit.h>

@protocol PDFDisplayViewDelegate;

@interface PDFDisplayView : UIView

// 初始化方法，传入远程 PDF 文件的 URL
- (instancetype)initWithFrame:(CGRect)frame pdfURL:(NSURL *)pdfURL;

@property (nonatomic, weak) id<PDFDisplayViewDelegate> delegate;


@end

@protocol PDFDisplayViewDelegate <NSObject>

- (void)PDFDisplayViewDidClose:(PDFDisplayView *)view;

@end
