//
//  WebViewController.m
//  Example
//
//  Created by hulilei on 2023/5/8.
//

#import "WebViewController.h"
#import <WebKit/WebKit.h>

@interface WebViewController ()<WKUIDelegate>
@property (nonatomic, strong) WKWebView *mWebView;

@end

@implementation WebViewController
-(void)loadView{
    self.view = [[NSView alloc]initWithFrame:NSMakeRect(0, 0, 1000, 800)];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [self loadWebView];

}
- (void)loadWebView{
    WKUserContentController *userContentController = WKUserContentController.new;
    NSString *cookieSource = [NSString stringWithFormat:@"document.cookie = 'user=%@';", @"userValue"];

    WKUserScript *cookieScript = [[WKUserScript alloc] initWithSource:cookieSource injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    [userContentController addUserScript:cookieScript];

    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.userContentController = userContentController;
    self.mWebView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
    self.mWebView.UIDelegate = self;
    [self.view addSubview:self.mWebView];
    NSProcessInfo *processInfo = [NSProcessInfo processInfo];
    NSString *urlStr = [processInfo environment][@"WEB_URL"];
    NSURL *url =  [NSURL URLWithString:[NSString stringWithFormat:@"%@?requestUrl=%@/api/user",urlStr,urlStr]];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [self.mWebView loadRequest:request];
}
-(void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    NSAlert *alert = [[NSAlert alloc]init];
    [alert addButtonWithTitle:@"ok"];
    [alert setMessageText:message];
    [alert setAlertStyle:NSAlertStyleInformational];
    [alert beginSheetModalForWindow:self.view.window completionHandler:nil];
    completionHandler();
}
@end
