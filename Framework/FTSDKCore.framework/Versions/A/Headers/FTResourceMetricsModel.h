//
//  FTResourceMetricsModel.h
//  FTMobileAgent
//
//  Created by hulilei on 2021/11/19.
//  Copyright © 2021 DataFlux-cn. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Resource loading time data model
@interface FTResourceMetricsModel : NSObject
///Resource loading DNS resolution time domainLookupEnd - domainLookupStart
@property (nonatomic, strong) NSNumber *resource_dns;
///Resource loading TCP connection time connectEnd - connectStart
@property (nonatomic, strong) NSNumber *resource_tcp;
///Resource loading SSL connection time connectEnd - secureConnectStart
@property (nonatomic, strong) NSNumber *resource_ssl;
///Resource loading request response time responseStart - requestStart
@property (nonatomic, strong) NSNumber *resource_ttfb;
///Resource loading content transmission time responseEnd - responseStart
@property (nonatomic, strong) NSNumber *resource_trans;
///Resource loading first packet time responseStart - domainLookupStart
@property (nonatomic, strong) NSNumber *resource_first_byte;
///Resource loading time duration(responseEnd-fetchStartDate)
@property (nonatomic, strong) NSNumber *duration;
///Response result size response data size
@property (nonatomic, strong) NSNumber *responseSize;
/// Initialization method
///
/// - Parameters:
///   - metrics: SessionTaskMetric
/// - Returns: metrics instance.
-(instancetype)initWithTaskMetrics:(NSURLSessionTaskMetrics *)metrics API_AVAILABLE(ios(10.0),macosx(10.12));

@end

NS_ASSUME_NONNULL_END
