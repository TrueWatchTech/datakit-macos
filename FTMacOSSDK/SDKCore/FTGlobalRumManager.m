//
//  FTGlobalRumManager.m
//  FTMobileAgent
//
//  Created by hulilei on 2020/4/14.
//  Copyright © 2020 hll. All rights reserved.
//
#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag on this file.
#endif
#import "FTResourceMetricsModel.h"
#import "FTResourceContentModel.h"
#import "FTSDKAgent+Private.h"
#import "FTGlobalRumManager+Private.h"
#import "FTInternalLog.h"
#import "FTDateUtil.h"
#import "FTJSONUtil.h"
#import "FTUncaughtExceptionHandler.h"
#import "FTAppLifeCycle.h"
#import "FTRUMMonitor.h"
#import "FTWKWebViewHandler.h"
#import "FTAppLaunchTracker.h"
#import "FTConstants.h"
#import "FTLongTaskDetector.h"
#import "FTURLSessionInstrumentation.h"
#import "FTWKWebViewJavascriptBridge.h"
#import "FTRumDatasProtocol.h"
@interface FTGlobalRumManager ()<FTAppLifeCycleDelegate,FTWKWebViewRumDelegate,FTAppLaunchDataDelegate,FTRunloopDetectorDelegate>
@property (nonatomic, strong) FTSDKConfig *config;
@property (nonatomic, strong) FTRumConfig *rumConfig;
@property (nonatomic, assign) CFTimeInterval launch;
@property (nonatomic, strong) NSDate *launchTime;
@property (nonatomic, strong) FTRUMMonitor *monitor;
@property (nonatomic, strong) FTLongTaskDetector *longTaskDetector;
@property (nonatomic, strong) FTAppLaunchTracker *launchTracker;
@property (nonatomic, strong) FTWKWebViewJavascriptBridge *jsBridge;

@end

@implementation FTGlobalRumManager
static FTGlobalRumManager *sharedManager = nil;
static dispatch_once_t onceToken;
-(instancetype)init{
    self = [super init];
    if (self) {
        _launchTime = [NSDate date];
        [[FTAppLifeCycle sharedInstance] addAppLifecycleDelegate:self];
    }
    return self;
}
+ (instancetype)sharedManager {
    dispatch_once(&onceToken, ^{
        sharedManager = [[super allocWithZone:NULL] init];
    });
    return sharedManager;
}
-(void)setRumConfig:(FTRumConfig *)rumConfig{
    _rumConfig = rumConfig;
    if (self.rumConfig.appid.length<=0) {
        FTInnerLogError(@"RumConfig appid data format error, failed to enable RUM");
        return;
    }
    self.monitor = [[FTRUMMonitor alloc]initWithMonitorType:(DeviceMetricsMonitorType)rumConfig.deviceMetricsMonitorType frequency:(MonitorFrequency)rumConfig.monitorFrequency];
    self.rumManager = [[FTRUMManager alloc]initWithRumSampleRate:rumConfig.sampleRate errorMonitorType:(ErrorMonitorType)rumConfig.errorMonitorType monitor:self.monitor writer:[FTSDKAgent sharedInstance]];
    if(rumConfig.enableTrackAppCrash){
        [[FTUncaughtExceptionHandler sharedHandler] addErrorDataDelegate:self.rumManager];
    }

    if(rumConfig.enableTrackAppCrash){
        [[FTUncaughtExceptionHandler sharedHandler] addErrorDataDelegate:self.rumManager];
    }
    self.launchTracker = [[FTAppLaunchTracker alloc]initWithDelegate:self];
    //Collect view, resource, jsBridge
    if (rumConfig.enableTrackAppANR||rumConfig.enableTrackAppFreeze) {
        _longTaskDetector = [[FTLongTaskDetector alloc]initWithDelegate:self enableTrackAppANR:rumConfig.enableTrackAppANR enableTrackAppFreeze:rumConfig.enableTrackAppFreeze];
        [_longTaskDetector startDetecting];
    }
    [FTWKWebViewHandler sharedInstance].rumTrackDelegate = self;
}

- (void)trackAppFreeze:(NSString *)stack duration:(NSNumber *)duration{
    [self.rumManager addLongTaskWithStack:stack duration:duration property:nil];
}
#pragma mark ========== FTRunloopDetectorDelegate ==========
- (void)longTaskStackDetected:(NSString*)slowStack duration:(long long)duration{
    [self.rumManager addLongTaskWithStack:slowStack duration:[NSNumber numberWithLongLong:duration]];
}
- (void)anrStackDetected:(NSString*)slowStack{
    [self.rumManager addErrorWithType:@"ios_crash" message:@"ios_anr" stack:slowStack];
}
#pragma mark ========== AUTO TRACK ==========
- (void)applicationWillTerminate{
    @try {
        [self.rumManager syncProcess];
    }@catch (NSException *exception) {
        FTInnerLogError(@"applicationWillResignActive exception %@",exception);
    }
}
-(void)addClickActionWithName:(NSString *)actionName{
    [self.rumManager addActionName:actionName actionType:@"click"];
}
- (void)addActionName:(nonnull NSString *)actionName actionType:(nonnull NSString *)actionType {
    [self.rumManager addActionName:actionName actionType:actionType];
}

- (void)addActionName:(nonnull NSString *)actionName actionType:(nonnull NSString *)actionType property:(nullable NSDictionary *)property {
    [self.rumManager addActionName:actionName actionType:actionType property:property];
}

- (void)addErrorWithType:(nonnull NSString *)type message:(nonnull NSString *)message stack:(nonnull NSString *)stack {
    [self.rumManager addErrorWithType:type message:message stack:stack];
}

- (void)addErrorWithType:(nonnull NSString *)type message:(nonnull NSString *)message stack:(nonnull NSString *)stack property:(nullable NSDictionary *)property {
    [self.rumManager addErrorWithType:type message:message stack:stack property:property];
}
- (void)addLongTaskWithStack:(nonnull NSString *)stack duration:(nonnull NSNumber *)duration {
    [self.rumManager addLongTaskWithStack:stack duration:duration];
}
- (void)addLongTaskWithStack:(nonnull NSString *)stack duration:(nonnull NSNumber *)duration property:(nullable NSDictionary *)property {
    [self.rumManager addLongTaskWithStack:stack duration:duration property:property];
}
- (void)onCreateView:(nonnull NSString *)viewName loadTime:(nonnull NSNumber *)loadTime {
    [self.rumManager onCreateView:viewName loadTime:loadTime];
}
- (void)startViewWithName:(nonnull NSString *)viewName {
    [self.rumManager startViewWithName:viewName];
}
- (void)startViewWithName:(nonnull NSString *)viewName property:(nullable NSDictionary *)property {
    [self.rumManager startViewWithName:viewName property:property];
}
- (void)stopView {
    [self.rumManager stopView];
}
- (void)stopViewWithProperty:(nullable NSDictionary *)property {
    [self.rumManager stopViewWithProperty:property];
}

- (void)addErrorWithType:(nonnull NSString *)type state:(FTAppState)state message:(nonnull NSString *)message stack:(nonnull NSString *)stack property:(nullable NSDictionary *)property {
    [self.rumManager addErrorWithType:type state:state message:message stack:stack property:property];
}


- (void)startResourceWithKey:(nonnull NSString *)key {
    [[FTURLSessionInstrumentation sharedInstance].externalResourceHandler startResourceWithKey:key];
}

- (void)startResourceWithKey:(nonnull NSString *)key property:(nullable NSDictionary *)property {
    [[FTURLSessionInstrumentation sharedInstance].externalResourceHandler startResourceWithKey:key property:property];

}

- (void)stopResourceWithKey:(nonnull NSString *)key {
    [[FTURLSessionInstrumentation sharedInstance].externalResourceHandler stopResourceWithKey:key];
}

- (void)stopResourceWithKey:(nonnull NSString *)key property:(nullable NSDictionary *)property {
    [[FTURLSessionInstrumentation sharedInstance].externalResourceHandler stopResourceWithKey:key property:property];
}
- (void)addResourceWithKey:(nonnull NSString *)key metrics:(nullable FTResourceMetricsModel *)metrics content:(nonnull FTResourceContentModel *)content {
    [[FTURLSessionInstrumentation sharedInstance].externalResourceHandler addResourceWithKey:key metrics:metrics content:content];
}
#pragma mark ========== APP LAUNCH ==========
-(void)ftAppHotStart:(NSNumber *)duration{
    [self.rumManager addLaunch:FTLaunchHot duration:duration];
    if (self.rumManager.viewReferrer) {
        NSString *viewid = [NSUUID UUID].UUIDString;
        NSString *viewReferrer =self.rumManager.viewReferrer;
        self.rumManager.viewReferrer = @"";
        [self.rumManager onCreateView:viewReferrer loadTime:@0];
        [self.rumManager startViewWithViewID:viewid viewName:viewReferrer property:nil];
    }
}
-(void)ftAppColdStart:(NSNumber *)duration isPreWarming:(BOOL)isPreWarming{
    [self.rumManager addLaunch:isPreWarming?FTLaunchWarm:FTLaunchCold duration:duration];
}
#pragma mark ========== FTANRDetectorDelegate ==========
- (void)onMainThreadSlowStackDetected:(NSString*)slowStack{
    [self.rumManager addLongTaskWithStack:slowStack duration:[NSNumber numberWithLongLong:MXRMonitorRunloopOneStandstillMillisecond*MXRMonitorRunloopStandstillCount*1000000]];
}
#pragma mark ========== jsBridge ==========
-(void)ftAddScriptMessageHandlerWithWebView:(WKWebView *)webView{
    if (![webView isKindOfClass:[WKWebView class]]) {
        return;
    }
    self.jsBridge = [FTWKWebViewJavascriptBridge bridgeForWebView:webView];
    [self.jsBridge registerHandler:@"sendEvent" handler:^(id data, WVJBResponseCallback responseCallback) {
        [self dealReceiveScriptMessage:data callBack:responseCallback];
    }];
}
- (void)dealReceiveScriptMessage:(id )message callBack:(WVJBResponseCallback)callBack{
    @try {
        NSDictionary *messageDic = [message isKindOfClass:NSDictionary.class]?message:[FTJSONUtil dictionaryWithJsonString:message];
        
        if (![messageDic isKindOfClass:[NSDictionary class]]) {
            FTInnerLogError(@"Message body is formatted failure from JS SDK");
            return;
        }
        NSString *name = messageDic[@"name"];
        if ([name isEqualToString:@"rum"]||[name isEqualToString:@"track"]||[name isEqualToString:@"log"]||[name isEqualToString:@"trace"]) {
            NSDictionary *data = messageDic[@"data"];
            NSString *measurement = data[FT_MEASUREMENT];
            NSDictionary *tags = data[FT_TAGS];
            NSDictionary *fields = data[FT_FIELDS];
            long long time = [data[@"time"] longLongValue];
            time = time>0?time:[FTDateUtil currentTimeNanosecond];
            if (measurement && fields.count>0) {
                if ([name isEqualToString:@"rum"]) {
                    [self.rumManager addWebViewData:measurement tags:tags fields:fields tm:time];
                }
            }
        }
    } @catch (NSException *exception) {
        FTInnerLogError(@"%@ error: %@", self, exception);
    }
}
#pragma mark ========== Deinitialize ==========
-(void)rumDeinitialize{
    _rumManager = nil;
    onceToken = 0;
    sharedManager =nil;
    [[FTAppLifeCycle sharedInstance] removeAppLifecycleDelegate:self];
}
@end
