//
//  FTSessionManger.h
//  FTMobileAgent
//
//  Created by hulilei on 2021/5/21.
//  Copyright © 2021 hll. All rights reserved.
//

#import "FTRUMHandler.h"
#import "FTEnumConstant.h"
#import "FTErrorDataProtocol.h"
#import "FTRumDatasProtocol.h"
#import "FTRumResourceProtocol.h"
@class FTRumConfig,FTResourceMetricsModel,FTResourceContentModel,FTRUMMonitor;

NS_ASSUME_NONNULL_BEGIN
/// App launch type
typedef NS_ENUM(NSUInteger, FTLaunchType) {
    /// Hot start
    FTLaunchHot,
    /// Cold start
    FTLaunchCold,
    /// Pre-start, system pre-loaded before APP launch
    FTLaunchWarm
};
@interface FTRUMManager : FTRUMHandler<FTRumResourceProtocol,FTErrorDataDelegate,FTRumDatasProtocol>
@property (nonatomic, assign) FTAppState appState;
@property (atomic,copy,readwrite) NSString *viewReferrer;
#pragma mark - init -

-(instancetype)initWithRumSampleRate:(int)sampleRate errorMonitorType:(ErrorMonitorType)errorMonitorType monitor:(nullable FTRUMMonitor *)monitor writer:(id<FTRUMDataWriteProtocol>)writer;

#pragma mark - resource -
/// HTTP request start
///
/// - Parameters:
///   - key: Request identifier
- (void)startResourceWithKey:(NSString *)key;
/// HTTP request start
/// - Parameters:
///   - key: Request identifier
///   - property: Event custom properties (optional)
- (void)startResourceWithKey:(NSString *)key property:(nullable NSDictionary *)property;

/// HTTP request data
///
/// - Parameters:
///   - key: Request identifier
///   - metrics: Request related performance attributes
///   - content: Request related data
- (void)addResourceWithKey:(NSString *)key metrics:(nullable FTResourceMetricsModel *)metrics content:(FTResourceContentModel *)content;
/// HTTP request end
///
/// - Parameters:
///   - key: Request identifier
- (void)stopResourceWithKey:(NSString *)key;
/// HTTP request end
/// - Parameters:
///   - key: Request identifier
///   - property: Event custom properties (optional)
- (void)stopResourceWithKey:(NSString *)key property:(nullable NSDictionary *)property;
#pragma mark - webView js -

/// Add WebView data
/// - Parameters:
///   - measurement: measurement description
///   - tags: tags description
///   - fields: fields description
///   - tm: tm description
- (void)addWebViewData:(NSString *)measurement tags:(NSDictionary *)tags fields:(NSDictionary *)fields tm:(long long)tm;
#pragma mark - view -
/**
 * Create page
 * @param viewName     Page name
 * @param loadTime     Page loading time
 */
-(void)onCreateView:(NSString *)viewName loadTime:(NSNumber *)loadTime;
/**
 * Enter page, viewId managed internally
 * @param viewName         Page name
 */
-(void)startViewWithName:(NSString *)viewName;
-(void)startViewWithName:(NSString *)viewName property:(nullable NSDictionary *)property;
/**
 * Enter page
 * @param viewId           Page id
 * @param viewName         Page name
 */
-(void)startViewWithViewID:(NSString *)viewId viewName:(NSString *)viewName property:(nullable NSDictionary *)property;

/// Leave page
-(void)stopView;
/**
 * Leave page
 * @param viewId          Page id
 */
-(void)stopViewWithViewID:(nullable NSString *)viewId property:(nullable NSDictionary *)property;
/**
 * Leave page
 */
-(void)stopViewWithProperty:(nullable NSDictionary *)property;

#pragma mark - action -
/// Click event
/// @param actionName actionName Click event name
- (void)addClickActionWithName:(nonnull NSString *)actionName;
/**
 * Click event
 * @param actionName Click event name
 */
- (void)addClickActionWithName:(NSString *)actionName property:(nullable NSDictionary *)property;
/// Action event
/// @param actionName Event name
/// @param actionType Event type
- (void)addActionName:(nonnull NSString *)actionName actionType:(nonnull NSString *)actionType;

/// Action event
/// @param actionName Event name
/// @param actionType Event type
/// @param property Event custom properties (optional)
- (void)addActionName:(NSString *)actionName actionType:(NSString *)actionType property:(nullable NSDictionary *)property;
/**
 * App launch
 * @param type      Launch type
 * @param duration  Launch duration
 */
- (void)addLaunch:(FTLaunchType)type duration:(NSNumber *)duration;

#pragma mark - Error / Long Task -
/// Crash
/// @param type Error type: java_crash/native_crash/abort/ios_crash
/// @param message Error message
/// @param stack Error stack
- (void)addErrorWithType:(nonnull NSString *)type message:(nonnull NSString *)message stack:(nonnull NSString *)stack;
/**
 * Crash
 * @param type       Error type: java_crash/native_crash/abort/ios_crash
 * @param message    Error message
 * @param stack      Error stack
 * @param property   Event properties (optional)
 */
- (void)addErrorWithType:(NSString *)type message:(NSString *)message stack:(NSString *)stack property:(nullable NSDictionary *)property;
/// Freeze
/// @param stack Freeze stack
/// @param duration Freeze duration
- (void)addLongTaskWithStack:(nonnull NSString *)stack duration:(nonnull NSNumber *)duration;
/**
 * Freeze
 * @param stack      Freeze stack
 * @param duration   Freeze duration
 * @param property   Event properties (optional)
 */
- (void)addLongTaskWithStack:(NSString *)stack duration:(NSNumber *)duration property:(nullable NSDictionary *)property;
#pragma mark - get LinkRumData -

/// Get RUM information when FTTraceConfig, FTLoggerConfig enable enableLinkRumData
-(NSDictionary *)getCurrentSessionInfo;

/// Wait for all RUM data being processed to complete
- (void)syncProcess;
@end

NS_ASSUME_NONNULL_END
