//
//  URLSessionAutoInstrumentation.h
//  FTMobileAgent
//
//  Created by hulilei on 2022/9/13.
//  Copyright © 2022 DataFlux-cn. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.


#import <Foundation/Foundation.h>
#import "FTURLSessionInterceptorProtocol.h"
#import "FTTracerProtocol.h"
#import "FTExternalResourceProtocol.h"
NS_ASSUME_NONNULL_BEGIN
typedef enum FTNetworkTraceType:NSUInteger FTNetworkTraceType;
/// URL session automation object for collecting RUM data and implementing trace functionality
@interface FTURLSessionInstrumentation : NSObject

/// Session interception processing object for handling resource link tracing (trace) and RUM resource data collection
@property (nonatomic, weak ,readonly) id<FTURLSessionInterceptorProtocol> interceptor;
/// Object provided to external for handling user custom resource data
@property (nonatomic, weak ,readonly) id<FTExternalResourceProtocol> externalResourceHandler;

@property (atomic, assign, readonly) BOOL shouldInterceptor;

- (BOOL)isNotSDKInsideUrl:(NSURL *)url;
/// Singleton
+ (instancetype)sharedInstance;

/// Set whether to automatically collect RUM Resource
/// - Parameter enableAutoRumTrack: Whether to automatically collect
- (void)setEnableAutoRumTrack:(BOOL)enableAutoRumTrack resourceUrlHandler:(FTResourceUrlHandler)resourceUrlHandler;

/// Set trace configuration items, enable trace
/// - Parameters:
///   - enableAutoTrace: Whether to enable automatic link tracing
///   - enableLinkRumData: Whether to associate with RUM
///   - sampleRate: Sampling rate
///   - traceType: Link type
- (void)setTraceEnableAutoTrace:(BOOL)enableAutoTrace enableLinkRumData:(BOOL)enableLinkRumData sampleRate:(int)sampleRate traceType:(FTNetworkTraceType)traceType;
/// Set SDK internal data upload URL
/// - Parameter sdkUrlStr: SDK internal data upload URL
- (void)setSdkUrlStr:(NSString *)sdkUrlStr;

/// Set RUM resource data processing object that follows FTRumResourceProtocol
///
/// HTTP resource data collected by this module should be passed to RUM module
/// - Parameter handler: RUM module data receiving object
- (void)setRumResourceHandler:(id<FTRumResourceProtocol>)handler;

/// Set URL filtering
/// - Parameter intakeUrlHandler: Callback to determine whether to collect, return YES to collect, NO to filter out
- (void)setIntakeUrlHandler:(FTIntakeUrl)intakeUrlHandler;

- (void)enableSessionDelegate:(id <NSURLSessionDelegate>)delegate;

/// Unregister
- (void)resetInstance;
@end

NS_ASSUME_NONNULL_END
