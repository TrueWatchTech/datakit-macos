//
//  FTDateUtil.h
//  FTMacOSSDK
//
//  Created by hulilei on 2021/8/5.
//  Copyright © 2021 DataFlux-cn. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Time utility class
@interface FTDateUtil : NSObject
/// Get current timestamp in milliseconds
+ (long long)currentTimeMillisecond;
/// Get timestamp for given time in nanoseconds
/// @param date Time
+ (long long)dateTimeNanosecond:(NSDate *)date;
/// Get current timestamp in nanoseconds
+ (long long)currentTimeNanosecond;
/// Get GMT format time
+ (NSString *)currentTimeGMT;
/// Get time interval in nanoseconds
/// - Parameters:
///   - date: Start time
///   - toDate: End time
+ (NSNumber *)nanosecondTimeIntervalSinceDate:(NSDate *)date toDate:(NSDate *)toDate;
@end

NS_ASSUME_NONNULL_END
