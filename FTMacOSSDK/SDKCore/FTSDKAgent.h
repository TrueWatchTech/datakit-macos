//
//  FTSDKAgent.h
//  FTMacOSSDK
//
//  Created by hulilei on 2021/8/2.
//  Copyright © 2021 TRUEWATCH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FTSDKConfig.h"
NS_ASSUME_NONNULL_BEGIN
@interface FTSDKAgent : NSObject
/// Returns the previously initialized singleton
///
/// Before calling this method, you must first call the startWithConfigOptions method
+ (instancetype)sharedInstance;
/// SDK initialization method
///
/// Configure basic configuration items when starting the SDK. Required configuration items include FT-GateWay metrics write address.
///
/// Since the `viewDidLoad` method of the first displayed view `NSViewController` and the `windowDidLoad` method of `NSWindowController` are called earlier than AppDelegate `applicationDidFinishLaunching`, to avoid abnormal collection of the first view's lifecycle, it is recommended to initialize the SDK in the `main.m` file and the SDK must be initialized in the main thread.
/// - Parameter configOptions: SDK basic configuration items.
+ (void)startWithConfigOptions:(FTSDKConfig *)configOptions;
/// Configure RUM Config to enable RUM functionality
///
/// RUM user monitoring, collects user behavior data, supports collection of View, Action, Resource, LongTask, Error. Supports automatic collection and manual addition.
/// - Parameter rumConfigOptions: rum configuration items.
- (void)startRumWithConfigOptions:(FTRumConfig *)rumConfigOptions;
/// Configure Logger Config to enable Logger functionality
///
/// - Parameters:
///   - loggerConfigOptions: logger configuration items.
- (void)startLoggerWithConfigOptions:(FTLoggerConfig *)loggerConfigOptions;

/// In automatic tracking functionality, filter addresses that don't need to be collected, generally used to exclude some requests that are not business-related
/// - Parameter handler: Callback to determine whether to collect, returns YES to collect, NO to filter out
- (void)isIntakeUrl:(BOOL(^)(NSURL *url))handler DEPRECATED_MSG_ATTRIBUTE("Deprecated, please set `resourceUrlHandler` in FTRumConfig configuration for replacement");
/// Configure Trace Config to enable Trace functionality
///
/// - Parameters:
///   - traceConfigOptions: trace configuration items.
- (void)startTraceWithConfigOptions:(FTTraceConfig *)traceConfigOptions;
/// Add custom log
///
/// - Parameters:
///   - content: Log content, can be json string
///   - status: Event level and status
-(void)logging:(NSString *)content status:(FTLogStatus)status;

/// Add custom log
/// - Parameters:
///   - content: Log content, can be json string
///   - status: Event level and status
///   - property: Event custom properties (optional)
-(void)logging:(NSString *)content status:(FTLogStatus)status property:(nullable NSDictionary *)property;;
/// Bind user information
///
/// - Parameters:
///   - Id:  User ID
- (void)bindUserWithUserID:(NSString *)userId;

/// Bind user information
///
/// - Parameters:
///   - Id:  User ID
///   - userName: User name
///   - userEmail: User email
- (void)bindUserWithUserID:(NSString *)Id userName:(nullable NSString *)userName userEmail:(nullable NSString *)userEmail;
/// Bind user information
///
/// - Parameters:
///   - Id:  User ID
///   - userName: User name
///   - userEmail: User email
///   - extra: User's additional information
- (void)bindUserWithUserID:(NSString *)Id userName:(nullable NSString *)userName userEmail:(nullable NSString *)userEmail extra:(nullable NSDictionary *)extra;

/// Logout current user
- (void)unbindUser;

/// Shutdown running objects in SDK
- (void)shutDown;

@end

NS_ASSUME_NONNULL_END
