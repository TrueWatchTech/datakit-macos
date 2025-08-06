//
//  FTWKWebViewHandler.h
//  FTMobileAgent
//
//  Created by hulilei on 2020/9/16.
//  Copyright © 2020 hll. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "FTURLSessionInterceptorProtocol.h"
NS_ASSUME_NONNULL_BEGIN
/// webView add web-side rum data
@protocol FTWKWebViewRumDelegate <NSObject>
@optional

-(void)ftAddScriptMessageHandlerWithWebView:(WKWebView *)webView;

@end
/// Handle WKWebView Trace, js interaction
@interface FTWKWebViewHandler : NSObject<WKNavigationDelegate>
@property (nonatomic, assign) BOOL enableTrace;
@property (nonatomic, weak) id<FTWKWebViewRumDelegate> rumTrackDelegate;
@property (nonatomic, weak) id<FTURLSessionInterceptorProtocol> interceptor;
+ (instancetype)sharedInstance;

- (void)reloadWebView:(WKWebView *)webView completionHandler:(void (^)(NSURLRequest *request,BOOL needTrace))completionHandler;

- (void)addWebView:(WKWebView *)webView request:(NSURLRequest *)request;

- (void)removeWebView:(WKWebView *)webView;

- (void)addScriptMessageHandlerWithWebView:(WKWebView *)webView;
@end

NS_ASSUME_NONNULL_END
