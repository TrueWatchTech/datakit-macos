//
//  FTTrackConfig.h
//  FTMacOSSDK
//
//  Created by hulilei on 2021/8/6.
//  Copyright © 2021 TRUEWATCH. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
///Event level and status, default: FTStatusInfo
typedef NS_ENUM(NSInteger, FTLogStatus) {
    /// Info
    FTStatusInfo         = 0,
    /// Warning
    FTStatusWarning,
    /// Error
    FTStatusError,
    /// Critical
    FTStatusCritical,
    /// OK
    FTStatusOk,
};
/// Device information in ERROR
typedef NS_OPTIONS(NSUInteger, FTErrorMonitorType) {
    /// Enable all monitoring: battery, memory, CPU usage
    FTErrorMonitorAll          = 0xFFFFFFFF,
    /// Battery level
    FTErrorMonitorBattery      = 1 << 1,
    /// Total memory, memory usage
    FTErrorMonitorMemory       = 1 << 2,
    /// CPU usage
    FTErrorMonitorCpu          = 1 << 3,
};
/// Device information monitoring items
typedef NS_OPTIONS(NSUInteger, FTDeviceMetricsMonitorType){
    /// Enable all monitoring items: memory, CPU
    FTDeviceMetricsMonitorAll      = 0xFFFFFFFF,
    /// Average memory, peak memory
    FTDeviceMetricsMonitorMemory   = 1 << 2,
    /// CPU max, average
    FTDeviceMetricsMonitorCpu      = 1 << 3,
};
/// Monitoring item sampling frequency
typedef NS_ENUM(NSUInteger, FTMonitorFrequency) {
    /// 500ms (default)
    FTMonitorFrequencyDefault,
    /// 100ms
    FTMonitorFrequencyFrequent,
    /// 1000ms
    FTMonitorFrequencyRare,
};
/// Network link tracing usage type
typedef NS_ENUM(NSUInteger, FTNetworkTraceType) {
    /// datadog trace
    FTNetworkTraceTypeDDtrace,
    /// zipkin multi header
    FTNetworkTraceTypeZipkinMultiHeader,
    /// zipkin single header
    FTNetworkTraceTypeZipkinSingleHeader,
    /// w3c traceparent
    FTNetworkTraceTypeTraceparent,
    /// skywalking 8.0+
    FTNetworkTraceTypeSkywalking,
    /// jaeger
    FTNetworkTraceTypeJaeger,
};
/// Environment field. Property values: prod/gray/pre/common/local.
typedef NS_ENUM(NSInteger, FTEnv) {
    /// Production environment
    FTEnvProd         = 0,
    /// Gray environment
    FTEnvGray,
    /// Pre-release environment
    FTEnvPre,
    /// Daily environment
    FTEnvCommon,
    /// Local environment
    FTEnvLocal,
};
/// Log discard strategy
typedef NS_ENUM(NSInteger, FTLogCacheDiscard)  {
    /// Default, when log data count exceeds maximum (5000), new data is not written
    FTDiscard,
    /// When log data exceeds maximum, discard old data
    FTDiscardOldest
};
/// RUM filter resource callback, returns: NO means to collect, YES means not to collect.
typedef BOOL(^FTResourceUrlHandler)(NSURL * url);

/// SDK basic configuration items
@interface FTSDKConfig : NSObject
/// Designated initializer, set metricsUrl
/// - Parameter metricsUrl: Data reporting address
- (instancetype)initWithMetricsUrl:(NSString *)metricsUrl DEPRECATED_MSG_ATTRIBUTE("Deprecated, please use -initWithDatakitUrl: for replacement");

/// Local environment deployment, set datakitUrl
/// - Parameter datakitUrl: datakit data reporting address
- (instancetype)initWithDatakitUrl:(NSString *)datakitUrl;

/// Use public DataWay deployment, set datawayUrl and clientToken
/// - Parameter datawayUrl: datawayUrl data reporting address
/// - Parameter clientToken: dataway token
- (instancetype)initWithDatawayUrl:(NSString *)datawayUrl clientToken:(NSString *)clientToken;

/// Disable init initialization
- (instancetype)init NS_UNAVAILABLE;

/// Disable new initialization
+ (instancetype)new NS_UNAVAILABLE;

/// Data reporting address
@property (nonatomic, copy) NSString *metricsUrl DEPRECATED_MSG_ATTRIBUTE("Deprecated, please use datakitUrl for replacement");

@property (nonatomic, copy) NSString *datakitUrl;
@property (nonatomic, copy) NSString *datawayUrl;
/// client token
@property (nonatomic, copy) NSString *clientToken;
/// Name of the business or service, default: df_rum_macos
@property (nonatomic, copy) NSString *service;
/// Environment field.
@property (nonatomic, copy) NSString *env;
/// Set whether SDK is allowed to print Debug logs.
@property (nonatomic, assign) BOOL enableSDKDebugLog;
/// Application version number.
@property (nonatomic, copy) NSString *version;
/// Set SDK global tag
///
/// Reserved tags: sdk_package_flutter, sdk_package_react_native
@property (nonatomic, strong) NSDictionary<NSString*,NSString*> *globalContext;
/// Set env according to the provided FTEnv type
/// - Parameter envType: environment
- (void)setEnvWithType:(FTEnv)envType;
@end
/// Logger function configuration item
@interface FTLoggerConfig : NSObject
/// Disable new initialization
+ (instancetype)new NS_UNAVAILABLE;
/// Log discard strategy
@property (nonatomic, assign) FTLogCacheDiscard  discardType;
/// Sampling configuration, property value: 0 to 100, 100 means full collection, no data sample compression.
@property (nonatomic, assign) int sampleRate;
/// Whether to associate logger data with rum
@property (nonatomic, assign) BOOL enableLinkRumData;
/// Whether to upload custom log
@property (nonatomic, assign) BOOL enableCustomLog;
/// Whether to print custom logs in the console
@property (nonatomic, assign) BOOL printCustomLogToConsole; 
/// Status array for collecting custom logs, default is full collection
///
/// Example: @[@(FTStatusInfo),@(FTStatusError)]
/// Or @[@0,@1]
@property (nonatomic, strong) NSArray<NSNumber*> *logLevelFilter;
/// logger global tag
@property (nonatomic, strong) NSDictionary<NSString*,NSString*> *globalContext;
@end

/// RUM function configuration item
@interface FTRumConfig : NSObject
/// Designated initializer, set appid
///
/// - Parameters:
///   - appid: Unique identifier for user access monitoring application ID, automatically generated when creating monitoring in the user access monitoring console.
/// - Returns: rum configuration item.
- (instancetype)initWithAppid:(nonnull NSString *)appid;
/// Disable new initialization
+ (instancetype)new NS_UNAVAILABLE;
/// Unique identifier for user access monitoring application ID, generated when creating monitoring in the user access monitoring console.
@property (nonatomic, copy) NSString *appid;
/// Sampling configuration, property value: 0 to 100, 100 means full collection, no data sample compression.
@property (nonatomic, assign) int sampleRate;
/// Set whether to automatically track user behavior operations, currently supports application startup and click operations,
/// Only effective when there is View event collection
@property (nonatomic, assign) BOOL enableTraceUserAction;
/// Set whether to automatically track page lifecycle
///
/// SDK collects Window as View. If users want more detailed View collection, they can use the open API provided by the SDK for manual collection.
/// Note: Resource and Action data can only be collected normally under View event collection.
@property (nonatomic, assign) BOOL enableTraceUserView;
/// Set whether to track user network requests (only for native http)
@property (nonatomic, assign) BOOL enableTraceUserResource;
/// Custom resource collection rules.
/// Determine whether to collect corresponding resource data based on the request resource url, default is to collect all. Return: NO means to collect, YES means not to collect.
@property (nonatomic, copy) FTResourceUrlHandler resourceUrlHandler;
/// Set whether to collect crash logs
@property (nonatomic, assign) BOOL enableTrackAppCrash;
/// Set whether to collect freezes
@property (nonatomic, assign) BOOL enableTrackAppFreeze;
/// Set whether to collect ANR
///
/// runloop collects main thread freezes
@property (nonatomic, assign) BOOL enableTrackAppANR;
/// Device information in ERROR
@property (nonatomic, assign) FTErrorMonitorType errorMonitorType;
/// Set monitoring type, if not set, monitoring will not be enabled
@property (nonatomic, assign) FTDeviceMetricsMonitorType deviceMetricsMonitorType;
/// Set monitoring sampling frequency
@property (nonatomic, assign) FTMonitorFrequency monitorFrequency;
/// Set rum global tag
///
/// Reserved tag: special key - track_id (for tracing function)
@property (nonatomic, strong) NSDictionary<NSString*,NSString*> *globalContext;
@end
/// Trace function configuration item
@interface FTTraceConfig : NSObject
/// Disable new initialization
+ (instancetype)new NS_UNAVAILABLE;

/// Sampling configuration, property value: 0 to 100, 100 means full collection, no data sample compression.
@property (nonatomic, assign) int sampleRate;
/// Link tracing type, default is FTNetworkTraceTypeDDtrace
@property (nonatomic, assign) FTNetworkTraceType networkTraceType;
/// Whether to associate Trace data with rum
///
/// Only effective when FTNetworkTraceType is set to FTNetworkTraceTypeDDtrace
@property (nonatomic, assign) BOOL enableLinkRumData;
/// Set whether to enable automatic network link tracing
@property (nonatomic, assign) BOOL enableAutoTrace;
@end


NS_ASSUME_NONNULL_END
