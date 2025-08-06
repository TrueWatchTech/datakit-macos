//
//  FTBaseInfoHandler.h
//  FTMobileAgent
//
//  Created by hulilei on 2019/12/3.
//  Copyright © 2019 hll. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FTSDKCompat.h"
NS_ASSUME_NONNULL_BEGIN

/// Some utility methods
@interface FTBaseInfoHandler : NSObject


/// Convert dictionary to string
/// - Parameter dict: Dictionary to be converted
+ (NSString *)convertToStringData:(NSDictionary *)dict;

/// URL path group processing
/// - Parameter url: URL
+ (NSString *)replaceNumberCharByUrl:(NSURL *)url;

/// Bool value to string conversion
/// - Parameter isTrue: Bool value
+ (NSString *)boolStr:(BOOL)isTrue;

/// Sampling rate judgment
/// - Parameter sampling: User set sampling rate
/// - Returns: Whether to sample
+ (BOOL)randomSampling:(int)sampling;

/// Get random UUID string (no `-`, all lowercase)
+ (NSString *)randomUUID;
#if FT_IOS
/// Phone carrier
+(NSString *)telephonyCarrier;
#endif
/// Device IP Address
/// - Parameter preferIPv4 Whether to prefer IPv4
+ (NSString *)cellularIPAddress:(BOOL)preferIPv4;
@end

NS_ASSUME_NONNULL_END
