//
//  FTURLSessionInterceptor.h
//  FTMobileAgent
//
//  Created by hulilei on 2022/3/17.
//  Copyright © 2022 DataFlux-cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FTURLSessionDelegate.h"
NS_ASSUME_NONNULL_BEGIN

/// URL Session interceptor, implements RUM Resource data collection, Trace link tracing
@interface FTURLSessionInterceptor : NSObject

/// Singleton
+ (instancetype)shared;

/// Tell the interceptor to modify URL request, when automatic link tracing is enabled, calling this method will add link information to the request header,
/// If not enabled, directly return the incoming request
/// - Parameter request: Initial request
- (NSURLRequest *)interceptRequest:(NSURLRequest *)request;

/// Tell the interceptor that a task has been created
/// - Parameter task: Task
- (void)interceptTask:(NSURLSessionTask *)task;

/// Tell the interceptor that the task has received some expected data.
/// - Parameters:
///   - task: Data task that provides data.
///   - data: Data object
- (void)taskReceivedData:(NSURLSessionTask *)task data:(NSData *)data;

/// Tell the interceptor that metrics have been collected for the given task.
/// - Parameters:
///   - task: Task for which metrics were collected
///   - metrics: Collected metrics.
- (void)taskMetricsCollected:(NSURLSessionTask *)task metrics:(NSURLSessionTaskMetrics *)metrics;
/// Tell the interceptor that the task has completed
/// - Parameters:
///   - task: Task that completed data transfer.
///   - error:  If an error occurred, returns an error object indicating how the transfer failed, otherwise returns `nil`.
///   - extraProvider: Additional custom RUM resource properties
- (void)taskCompleted:(NSURLSessionTask *)task error:(nullable NSError *)error extraProvider:(nullable ResourcePropertyProvider)extraProvider;
@end

NS_ASSUME_NONNULL_END
