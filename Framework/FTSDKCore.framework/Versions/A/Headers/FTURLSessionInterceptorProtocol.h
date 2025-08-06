//
//  FTURLSessionInterceptorProtocol.h
//  FTMobileSDK
//
//  Created by hulilei on 2022/9/14.
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


#ifndef FTURLSessionInterceptorProtocol_h
#define FTURLSessionInterceptorProtocol_h
#import "FTRumResourceProtocol.h"
#import "FTTracerProtocol.h"
NS_ASSUME_NONNULL_BEGIN
typedef BOOL(^FTIntakeUrl)(NSURL *url);
typedef BOOL(^FTResourceUrlHandler)(NSURL *url);
typedef NSDictionary* _Nullable (^ResourcePropertyProvider)( NSURLRequest * _Nullable request, NSURLResponse * _Nullable response,NSData *_Nullable data, NSError *_Nullable error);

/// Session interception processing delegate
@protocol FTURLSessionInterceptorProtocol<NSObject>
@optional
/// User collection filter callback
@property (nonatomic, copy ,nullable) FTIntakeUrl intakeUrlHandler;
@property (nonatomic, copy ,nullable) FTResourceUrlHandler resourceUrlHandler;


/// Collected resource data receiving object
@property (nonatomic, weak) id<FTRumResourceProtocol> rumResourceHandler;

- (void)setTracer:(id<FTTracerProtocol>)tracer;
/// Implement trace functionality, add trace parameters to request header
/// - Parameter request: HTTP initial request
- (NSURLRequest *)interceptRequest:(NSURLRequest *)request;

/// Request start -startResource
/// - Parameters:
///   - task: Request task
///   - session: Session
- (void)interceptTask:(NSURLSessionTask *)task;

/// Collect request data information
/// - Parameters:
///   - task: Request task
///   - metrics: Request task data records
- (void)taskMetricsCollected:(NSURLSessionTask *)task metrics:(NSURLSessionTaskMetrics *)metrics API_AVAILABLE(ios(10.0),macos(10.12));
/// Collect request response data
/// - Parameters:
///   - task: Request task
///   - data: Request response data
- (void)taskReceivedData:(NSURLSessionTask *)task data:(NSData *)data;
/// Request end -stopResource
/// - Parameters:
///   - task: Request task
///   - error: Error information
///
/// When passing to RUM, first call -stopResource, then call -addResourceWithKey
- (void)taskCompleted:(NSURLSessionTask *)task error:(nullable NSError *)error ;

/// Request end -stopResource
/// - Parameters:
///   - task: Request task
///   - error: Error information
///   - extraProvider: User custom extra information
- (void)taskCompleted:(NSURLSessionTask *)task error:(nullable NSError *)error extraProvider:(nullable ResourcePropertyProvider)extraProvider;
@end
NS_ASSUME_NONNULL_END
#endif /* FTURLSessionInterceptorProtocol_h */
