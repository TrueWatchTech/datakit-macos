//
//  FTTraceManager.h
//  FTMacOSSDK
//
//  Created by hulilei on 2023/4/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/// Class for managing trace
///
/// Features:
/// - Determine whether to perform trace tracking based on URL
/// - Get trace request header parameters
/// - Manage traceHandler based on key
@interface FTTraceManager : NSObject
/// Singleton
+ (instancetype)sharedInstance;
/// Get trace request header parameters
/// - Parameters:
///   - key: Unique identifier that can determine a specific request
///   - url: Request URL
/// - Returns: Dictionary of trace request header parameters
- (NSDictionary *)getTraceHeaderWithKey:(NSString *)key url:(NSURL *)url;
@end

NS_ASSUME_NONNULL_END
