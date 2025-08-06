//
//  FTTrackConfig.m
//  FTMacOSSDK
//
//  Created by hulilei on 2021/8/6.
//  Copyright © 2021 TRUEWATCH. All rights reserved.
//

#import "FTSDKConfig.h"
#import "FTBaseInfoHandler.h"
#import "FTEnumConstant.h"
@interface FTSDKConfig()<NSCopying>
@end
@implementation FTSDKConfig
-(instancetype)initWithMetricsUrl:(NSString *)metricsUrl{
    self = [self initWithDatakitUrl:metricsUrl];
    self->_metricsUrl = metricsUrl;
    return self;
}
-(instancetype)initWithDatakitUrl:(NSString *)datakitUrl{
    if (self = [super init]) {
        _datakitUrl = datakitUrl;
        _enableSDKDebugLog = NO;
        _service = @"df_rum_macos";
        _version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        _env = FTEnvStringMap[FTEnvProd];
    }
    return self;
}
- (nonnull instancetype)initWithDatawayUrl:(nonnull NSString *)datawayUrl clientToken:(nonnull NSString *)clientToken{
    if (self = [super init]) {
        _datawayUrl = datawayUrl;
        _clientToken = clientToken;
        _enableSDKDebugLog = NO;
        _service = @"df_rum_macos";
        _version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        _env = FTEnvStringMap[FTEnvProd];
    }
    return self;
}
- (void)setEnvWithType:(FTEnv)envType{
    _env = FTEnvStringMap[envType];
}
-(void)setEnv:(NSString *)env{
    if(env!=nil && env.length>0){
        _env = env;
    }
}
-(id)copyWithZone:(NSZone *)zone{
    FTSDKConfig *options = [[[self class] allocWithZone:nil] init];
    options.datakitUrl = self.datakitUrl;
    options.datawayUrl = self.datawayUrl;
    options.clientToken = self.clientToken;
    options.env = self.env;
    options.service = self.service;
    options.enableSDKDebugLog = self.enableSDKDebugLog;
    options.globalContext = self.globalContext;
    options.version = self.version;
    return options;
}
@end

@implementation FTRumConfig
- (instancetype)init{
    return [self initWithAppid:@""];
}
- (instancetype)initWithAppid:(nonnull NSString *)appid{
    self = [super init];
    if (self) {
        _appid = appid;
        _enableTrackAppCrash= NO;
        _sampleRate = 100;
    }
    return self;
}
- (instancetype)copyWithZone:(NSZone *)zone {
    FTRumConfig *options = [[[self class] allocWithZone:zone] init];
    options.enableTrackAppCrash = self.enableTrackAppCrash;
    options.sampleRate = self.sampleRate;
    options.appid = self.appid;
    options.enableTrackAppANR = self.enableTrackAppANR;
    options.enableTraceUserView = self.enableTraceUserView;
    options.enableTrackAppFreeze = self.enableTrackAppFreeze;
    options.enableTraceUserAction = self.enableTraceUserAction;
    options.enableTraceUserResource = self.enableTraceUserResource;
    options.errorMonitorType = self.errorMonitorType;
    options.monitorFrequency = self.monitorFrequency;
    options.deviceMetricsMonitorType = self.deviceMetricsMonitorType;
    options.globalContext = self.globalContext;
    return options;
}
@end
@implementation FTLoggerConfig
-(instancetype)init{
    self = [super init];
    if (self) {
        _sampleRate = 100;
        _enableLinkRumData = NO;
        _enableCustomLog = NO;
        _logLevelFilter = @[@0,@1,@2,@3,@4];
    }
    return self;
}
- (instancetype)copyWithZone:(NSZone *)zone {
    FTLoggerConfig *options = [[[self class] allocWithZone:zone] init];
    options.sampleRate = self.sampleRate;
    options.enableLinkRumData = self.enableLinkRumData;
    options.enableCustomLog = self.enableCustomLog;
    options.logLevelFilter = self.logLevelFilter;
    options.discardType = self.discardType;
    options.printCustomLogToConsole = self.printCustomLogToConsole;
    options.globalContext = self.globalContext;
    return options;
}
@end
@implementation FTTraceConfig
-(instancetype)init{
    self = [super init];
    if (self) {
        _sampleRate= 100;
        _networkTraceType = FTNetworkTraceTypeDDtrace;
    }
    return self;
}
- (instancetype)copyWithZone:(NSZone *)zone {
    FTTraceConfig *options = [[[self class] allocWithZone:zone] init];
    options.sampleRate = self.sampleRate;
    options.enableLinkRumData = self.enableLinkRumData;
    options.networkTraceType = self.networkTraceType;
    options.enableAutoTrace = self.enableAutoTrace;
    return options;
}
@end
