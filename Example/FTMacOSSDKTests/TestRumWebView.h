//
//  TestRumWebView.h
//  FTMacOSSDKTests
//
//  Created by hulilei on 2023/10/9.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TestRumWebView : NSViewController
@property (nonatomic, strong) WKWebView *mWebView;
- (void)test_loadUrl;
- (void)test_addWebViewRumView:(void(^)(void))complete;
@end

NS_ASSUME_NONNULL_END
