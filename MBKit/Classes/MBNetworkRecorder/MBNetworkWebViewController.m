//
//  MBNetworkWebViewController.m
//  MaltBaby
//
//  Created by 李龙飞 on 2021/6/22.
//  Copyright © 2021 杭州因爱网络科技有限公司. All rights reserved.
//


#import "MBNetworkWebViewController.h"
#import "MBNetworkUtility.h"
#import <WebKit/WebKit.h>
#import "Masonry.h"
@interface MBNetworkWebViewController ()
<WKNavigationDelegate,UIScrollViewDelegate>
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, copy) NSString *originalText;
//
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UITapGestureRecognizer *bgColorTapGesture;
@property (nonatomic, assign) NSInteger backgroundColorIndex;
@property (nonatomic, readonly) NSArray<UIColor *> *backgroundColors;
@end

@implementation MBNetworkWebViewController
- (WKWebView *)webView {
    if (!_webView) {
        WKWebViewConfiguration *configuration = [WKWebViewConfiguration new];
        if (@available(iOS 10.0, *)) {
            configuration.dataDetectorTypes = WKDataDetectorTypeLink;
        }
        _webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
        _webView.scrollView.bounces = NO;
        _webView.scrollView.alwaysBounceVertical = NO;
        _webView.navigationDelegate = self;
    }
    return _webView;
}
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [UIScrollView new];
        _scrollView.delegate = self;
        _scrollView.backgroundColor = self.backgroundColors.firstObject;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.contentSize = self.imageView.frame.size;
        _scrollView.minimumZoomScale = 1.0;
        _scrollView.maximumZoomScale = 2.0;
    }
    return _scrollView;
}
- (id)initWithText:(NSString *)text {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.originalText = text;
        NSString *htmlHead = @"<head><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, maximum-scale=1, minimum-scale=1, user-scalable=no\"><style>img{max-width: 100%; width:auto; height:auto!important;}</style></head>";
        NSString * htmlString = [NSString stringWithFormat:@"<html>%@<body style=\"word-wrap:break-word;font-family:Arial\">%@</body></html>",htmlHead,[MBNetworkUtility stringByEscapingHTMLEntitiesInString:text]];
        [self.webView loadHTMLString:htmlString baseURL:nil];
    }
    return self;
}

- (id)initWithURL:(NSURL *)url {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.webView loadRequest:request];
    }
    return self;
}
- (id)initWithImage:(UIImage *)image {
    NSParameterAssert(image);
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.title = @"Preview";
        self.image = image;
        self.imageView = [[UIImageView alloc] initWithImage:self.image];
        [self.scrollView addSubview:self.imageView];
        _backgroundColors = @[UIColor.lightGrayColor, UIColor.whiteColor, UIColor.blackColor];
    }
    return self;
}
- (void)dealloc {
    // WKWebView's delegate is assigned so we need to clear it manually.
    if (_webView.navigationDelegate == self) {
        _webView.navigationDelegate = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.image) {
        [self.view addSubview:self.scrollView];
        self.bgColorTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeBackground)];
        [self.scrollView addGestureRecognizer:self.bgColorTapGesture];
        [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    } else if (self.originalText) {
        [self.view addSubview:self.webView];
        [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Copy" style:UIBarButtonItemStylePlain target:self action:@selector(copyButtonTapped:)];
    }
}
- (void)viewDidLayoutSubviews {
    if (self.scrollView) {
        [self centerContentInScrollViewIfNeeded];
    }
}
- (void)copyButtonTapped:(id)sender {
    [UIPasteboard.generalPasteboard setString:self.originalText];
}

#pragma mark - WKWebView Delegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    WKNavigationActionPolicy policy = WKNavigationActionPolicyCancel;
    if (navigationAction.navigationType == WKNavigationTypeOther) {
        // Allow the initial load
        policy = WKNavigationActionPolicyAllow;
    } else {
        // For clicked links, push another web view controller onto the navigation stack so that hitting the back button works as expected.
        // Don't allow the current web view to handle the navigation.
        NSURLRequest *request = navigationAction.request;
        MBNetworkWebViewController *webVC = [[[self class] alloc] initWithURL:[request URL]];
        webVC.title = [[request URL] absoluteString];
        [self.navigationController pushViewController:webVC animated:YES];
    }
    decisionHandler(policy);
}


#pragma mark - Class Helpers

+ (BOOL)supportsPathExtension:(NSString *)extension {
    BOOL supported = NO;
    NSSet<NSString *> *supportedExtensions = [self webViewSupportedPathExtensions];
    if ([supportedExtensions containsObject:[extension lowercaseString]]) {
        supported = YES;
    }
    return supported;
}

+ (NSSet<NSString *> *)webViewSupportedPathExtensions {
    static NSSet<NSString *> *pathExtensions = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Note that this is not exhaustive, but all these extensions should work well in the web view.
        // See https://developer.apple.com/library/archive/documentation/AppleApplications/Reference/SafariWebContent/CreatingContentforSafarioniPhone/CreatingContentforSafarioniPhone.html#//apple_ref/doc/uid/TP40006482-SW7
        pathExtensions = [NSSet<NSString *> setWithArray:@[@"jpg", @"jpeg", @"png", @"gif", @"pdf", @"svg", @"tiff", @"3gp", @"3gpp", @"3g2",
                                                           @"3gp2", @"aiff", @"aif", @"aifc", @"cdda", @"amr", @"mp3", @"swa", @"mp4", @"mpeg",
                                                           @"mpg", @"mp3", @"wav", @"bwf", @"m4a", @"m4b", @"m4p", @"mov", @"qt", @"mqv", @"m4v"]];
        
    });
    return pathExtensions;
}
#pragma mark UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self centerContentInScrollViewIfNeeded];
}


#pragma mark Private

- (void)centerContentInScrollViewIfNeeded {
    CGFloat horizontalInset = 0.0;
    CGFloat verticalInset = 0.0;
    if (self.scrollView.contentSize.width < self.scrollView.bounds.size.width) {
        horizontalInset = (self.scrollView.bounds.size.width - self.scrollView.contentSize.width) / 2.0;
    }
    if (self.scrollView.contentSize.height < self.scrollView.bounds.size.height) {
        verticalInset = (self.scrollView.bounds.size.height - self.scrollView.contentSize.height) / 2.0;
    }
    self.scrollView.contentInset = UIEdgeInsetsMake(verticalInset, horizontalInset, verticalInset, horizontalInset);
}

- (void)changeBackground {
    self.backgroundColorIndex++;
    self.backgroundColorIndex %= self.backgroundColors.count;
    self.scrollView.backgroundColor = self.backgroundColors[self.backgroundColorIndex];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

