//
//  FTTraceHandler.h
//  FTMobileAgent
//
//  Created by hulilei on 2021/10/13.
//  Copyright © 2021 DataFlux-cn. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
@class FTResourceContentModel,FTResourceMetricsModel;
/// Process single request, bind intercepted data from single request into data required by RUM
@interface FTSessionTaskHandler : NSObject
/// Unique identifier, used for RUM to process resource data identification
@property (nonatomic, copy, readwrite) NSString *identifier;

/// Initial request sent during this interception. It is the request sent by `URLSession`, not the request given by the user.
@property (nonatomic, strong) NSURLRequest *request;
/// Request response sent during this interception.
@property (nonatomic, strong) NSURLResponse *response;
/// Local error occurred during this interception. Returns `nil` if the task completed successfully.
@property (nonatomic, strong) NSError *error;
/// Task data received during interception. Returns `nil` if there was an error when the task completed.
@property (nonatomic, strong) NSMutableData *data;
/// RUM resource required request duration for each stage (not required)
@property (nonatomic, strong) FTResourceMetricsModel *metricsModel;
/// RUM resource required basic data
@property (nonatomic, strong) FTResourceContentModel *contentModel;
/// trace: span_id Returns `nil` when trace functionality is not enabled or not associated with RUM.
@property (nonatomic, copy) NSString *spanID;
/// trace: trace_id Returns `nil` when trace functionality is not enabled or not associated with RUM.
@property (nonatomic, copy) NSString *traceID;

/// Initialization method
/// - Parameter identifier: Unique identifier, based on identifier
-(instancetype)initWithIdentifier:(NSString *)identifier;
///  Request response data
/// - Parameter data: Data obtained from request
///
/// traceHandle internally will bind data to contentModel after receiving -taskCompleted method
- (void)taskReceivedData:(NSData *)data;

/// Request data information for each stage
/// - Parameter metrics: Data information
///
/// traceHandle internally processes data into metricsModel that RUM can receive
- (void)taskReceivedMetrics:(NSURLSessionTaskMetrics *)metrics API_AVAILABLE(macos(10.12));

/// Request completed
/// - Parameters:
///   - task: Request task
///   - error: Error information
///
///  Organize data and some task data into contentModel
- (void)taskCompleted:(NSURLSessionTask *)task error:(NSError *)error;

@end
NS_ASSUME_NONNULL_END
