//
//  FTSDKAgent.m
//  FTMacOSSDK
//
//  Created by hulilei on 2021/8/2.
//  Copyright © 2021 TRUEWATCH. All rights reserved.
//

#import "FTSDKAgent.h"
#import "FTSDKConfig.h"
#import "FTReachability.h"
#import "FTTrackDataManager.h"
#import "FTRecordModel.h"
#import "FTInternalLog.h"
#import "FTDateUtil.h"
#import "FTConstants.h"
#import "FTBaseInfoHandler.h"
#import "NSString+FTAdd.h"
#import "FTGlobalRumManager+Private.h"
#import "FTPresetProperty.h"
#import "FTEnumConstant.h"
#import "FTTrackerEventDBTool.h"
#import "FTMacOSSDKVersion.h"
#import "FTWKWebViewHandler.h"
#import "FTNetworkInfoManager.h"
#import "FTURLSessionInstrumentation.h"
#import "FTUserInfo.h"
#import "FTAutoTrack.h"
#import "FTLogger+Private.h"
@interface FTSDKAgent()<FTLoggerDataWriteProtocol>
@property (nonatomic, strong) FTLoggerConfig *loggerConfig;
@property (nonatomic, strong) FTPresetProperty *presetProperty;
@property (nonatomic, copy) NSString *netTraceStr;
@property (nonatomic, strong) FTAutoTrack *autotrack;
@end
@implementation FTSDKAgent
static FTSDKAgent *sharedInstance = nil;
static dispatch_once_t onceToken;

+ (void)startWithConfigOptions:(FTSDKConfig *)configOptions{
    NSAssert ((strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(dispatch_get_main_queue())) == 0),@"SDK must be initialized in the main thread, otherwise it will cause unpredictable problems (such as losing launch events).");
    
    NSAssert((configOptions.datakitUrl.length!=0||(configOptions.datawayUrl.length!=0&&configOptions.clientToken.length!=0)), @"Please correctly configure datakit or dataway write address");
    dispatch_once(&onceToken, ^{
        sharedInstance = [[FTSDKAgent alloc] initWithConfig:configOptions];
    });
}
// Singleton
+ (instancetype)sharedInstance {
    NSAssert(sharedInstance, @"Please use startWithConfigOptions: to initialize SDK first");
    return sharedInstance;
}
-(instancetype)initWithConfig:(FTSDKConfig *)config{
    self = [super init];
    if(self){
        [FTInternalLog enableLog:config.enableSDKDebugLog];
        //Enable data processing manager
        NSString *bundleIdentifier = [[[NSBundle mainBundle]infoDictionary] objectForKey:@"CFBundleIdentifier"];
        [FTTrackerEventDBTool shareDatabaseWithPath:[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject] dbName:[NSString stringWithFormat:@"com.ft.macos.sdk-%@.sqlite",bundleIdentifier]];
        [FTTrackDataManager sharedInstance];
        _presetProperty = [[FTPresetProperty alloc] initWithVersion:config.version env:config.env service:config.service globalContext:config.globalContext];
        _presetProperty.sdkVersion = SDK_VERSION;
        [FTNetworkInfoManager sharedInstance].setDatakitUrl(config.datakitUrl)
            .setDatawayUrl(config.datawayUrl)
            .setClientToken(config.clientToken)
            .setSdkVersion(SDK_VERSION);
        [[FTURLSessionInstrumentation sharedInstance] setSdkUrlStr:config.datakitUrl.length>0?config.datakitUrl:config.datawayUrl];
    }
    return self;
}
-(void)startRumWithConfigOptions:(FTRumConfig *)rumConfigOptions{
    NSAssert((rumConfigOptions.appid.length!=0 ), @"Please set appid for user access monitoring application ID");
    [self.presetProperty setAppID:rumConfigOptions.appid];
    self.presetProperty.rumContext = [rumConfigOptions.globalContext copy];
    [[FTGlobalRumManager sharedManager] setRumConfig:rumConfigOptions];
    [[FTURLSessionInstrumentation sharedInstance] setEnableAutoRumTrack:rumConfigOptions.enableTraceUserResource resourceUrlHandler:rumConfigOptions.resourceUrlHandler];
    [[FTURLSessionInstrumentation sharedInstance] setRumResourceHandler:[FTGlobalRumManager sharedManager].rumManager];
    [FTAutoTrack sharedInstance].addRumDatasDelegate = [FTGlobalRumManager sharedManager];
    [[FTAutoTrack sharedInstance] startHookView:rumConfigOptions.enableTraceUserView action:rumConfigOptions.enableTraceUserAction];
    
}
- (void)startLoggerWithConfigOptions:(FTLoggerConfig *)loggerConfigOptions{
    if (!_loggerConfig) {
        self.loggerConfig = [loggerConfigOptions copy];
        self.presetProperty.logContext = [self.loggerConfig.globalContext copy];
        [FTTrackerEventDBTool sharedManger].discardNew = (loggerConfigOptions.discardType == FTDiscard);
        [FTLogger startWithEnablePrintLogsToConsole:loggerConfigOptions.printCustomLogToConsole enableCustomLog:loggerConfigOptions.enableCustomLog logLevelFilter:loggerConfigOptions.logLevelFilter sampleRate:loggerConfigOptions.sampleRate writer:self];
    }
}
- (void)startTraceWithConfigOptions:(FTTraceConfig *)traceConfigOptions{
    _netTraceStr = FTNetworkTraceStringMap[traceConfigOptions.networkTraceType];
    [FTWKWebViewHandler sharedInstance].enableTrace = traceConfigOptions.enableAutoTrace;
    [FTWKWebViewHandler sharedInstance].interceptor = [FTURLSessionInstrumentation sharedInstance].interceptor;
    [[FTURLSessionInstrumentation sharedInstance] setTraceEnableAutoTrace:traceConfigOptions.enableAutoTrace enableLinkRumData:traceConfigOptions.enableLinkRumData sampleRate:traceConfigOptions.sampleRate traceType:traceConfigOptions.networkTraceType];
}
#pragma mark ========== publick method ==========
- (void)isIntakeUrl:(BOOL(^)(NSURL *url))handler{
    if(handler){
        [[FTURLSessionInstrumentation sharedInstance] setIntakeUrlHandler:handler];
    }
}
-(void)logging:(NSString *)content status:(FTLogStatus)status{
    [self logging:content status:status property:nil];
}
-(void)logging:(NSString *)content status:(FTLogStatus)status property:(NSDictionary *)property{
    @try {
        if (!self.loggerConfig) {
            FTInnerLogError(@"[Logging] Please set FTLoggerConfig first");
            return;
        }
        if (!content || content.length == 0 ) {
            FTInnerLogError(@"[Logging] The passed data format is incorrect");
            return;
        }
        [[FTLogger sharedInstance] log:content status:(LogStatus)status property:property];
    } @catch (NSException *exception) {
        FTInnerLogError(@"exception %@",exception);
    }
}
//User binding
- (void)bindUserWithUserID:(NSString *)Id{
    [self bindUserWithUserID:Id userName:nil userEmail:nil extra:nil];
}
-(void)bindUserWithUserID:(NSString *)Id userName:(NSString *)userName userEmail:(nullable NSString *)userEmail{
    [self bindUserWithUserID:Id userName:userName userEmail:userEmail extra:nil];
}
-(void)bindUserWithUserID:(NSString *)Id userName:(NSString *)userName userEmail:(nullable NSString *)userEmail extra:(NSDictionary *)extra{
    NSParameterAssert(Id);
    [self.presetProperty.userHelper concurrentWrite:^(FTUserInfo * _Nonnull value) {
        [value updateUser:Id name:userName email:userEmail extra:extra];
    }];
    FTInnerLogInfo(@"Bind User ID : %@ , Name : %@ , Email : %@ , Extra : %@",Id,userName,userEmail,extra);
}
//User logout
- (void)unbindUser{
    [self.presetProperty.userHelper concurrentWrite:^(FTUserInfo * _Nonnull value) {
        [value clearUser];
    }];
    FTInnerLogInfo(@"User Logout");
}
- (void)shutDown{
    [[FTTrackerEventDBTool sharedManger] insertCacheToDB];
    [[FTGlobalRumManager sharedManager] rumDeinitialize];
    [[FTLogger sharedInstance] shutDown];
    [[FTURLSessionInstrumentation sharedInstance] resetInstance];
    onceToken = 0;
    sharedInstance =nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    FTInnerLogInfo(@"[SDK] SHUT DOWN");
}
#pragma mark ========== private method ==========
- (void)logging:(nonnull NSString *)content status:(LogStatus)status tags:(nullable NSDictionary *)tags field:(nullable NSDictionary *)field time:(long long)time{
    @try {
        NSString *newContent = [content ft_subStringWithCharacterLength:FT_LOGGING_CONTENT_SIZE];
        NSMutableDictionary *tagDict = [NSMutableDictionary dictionaryWithDictionary:[self.presetProperty loggerPropertyWithStatus:(LogStatus)status]];
        if (tags) {
            [tagDict addEntriesFromDictionary:tags];
        }
        if (self.loggerConfig.enableLinkRumData) {
            [tagDict addEntriesFromDictionary:[self.presetProperty rumDynamicProperty]];
            [tagDict addEntriesFromDictionary:[self.presetProperty rumProperty]];
            if(![tags.allKeys containsObject:FT_RUM_KEY_SESSION_ID]){
                NSDictionary *rumTag = [[FTGlobalRumManager sharedManager].rumManager getCurrentSessionInfo];
                [tagDict addEntriesFromDictionary:rumTag];
            }
        }
        NSMutableDictionary *filedDict = @{FT_KEY_MESSAGE:newContent,
        }.mutableCopy;
        if (field) {
            [filedDict addEntriesFromDictionary:field];
        }
        FTRecordModel *model = [[FTRecordModel alloc]initWithSource:FT_LOGGER_SOURCE op:FT_DATA_TYPE_LOGGING tags:tagDict fields:filedDict tm:time];
        [self insertDBWithItemData:model type:FTAddDataLogging];
    } @catch (NSException *exception) {
        FTInnerLogError(@"exception %@",exception);
    }
}
- (void)rumWrite:(NSString *)type  tags:(NSDictionary *)tags fields:(NSDictionary *)fields{
    [self rumWrite:type tags:tags fields:fields time:[FTDateUtil currentTimeNanosecond]];
}
- (void)rumWrite:(NSString *)type tags:(NSDictionary *)tags fields:(NSDictionary *)fields time:(long long)time{
    
    @try {
        if (![type isKindOfClass:NSString.class] || type.length == 0) {
            return;
        }
        FTAddDataType dataType = FTAddDataImmediate;
        NSMutableDictionary *baseTags =[NSMutableDictionary new];
        [baseTags addEntriesFromDictionary:[self.presetProperty rumDynamicProperty]];
        baseTags[@"network_type"] = [FTReachability sharedInstance].net;
        [baseTags addEntriesFromDictionary:tags];
        NSMutableDictionary *rumProperty = [self.presetProperty rumProperty];
        // Data injected from webview
        if([tags.allKeys containsObject:FT_IS_WEBVIEW]){
            [baseTags setValue:SDK_VERSION forKey:@"package_native"];
            [rumProperty removeObjectForKey:FT_KEY_SERVICE];
            [rumProperty removeObjectForKey:FT_SDK_VERSION];
            [rumProperty removeObjectForKey:FT_SDK_NAME];
        }
        [baseTags addEntriesFromDictionary:rumProperty];
        FTRecordModel *model = [[FTRecordModel alloc]initWithSource:type op:FT_DATA_TYPE_RUM tags:baseTags fields:fields tm:time];
        [self insertDBWithItemData:model type:dataType];
    } @catch (NSException *exception) {
        FTInnerLogError(@"exception %@",exception);
    }
}
- (void)insertDBWithItemData:(FTRecordModel *)model type:(FTAddDataType)type{
    [[FTTrackDataManager sharedInstance] addTrackData:model type:type];
}
- (void)syncProcess{
    [[FTGlobalRumManager sharedManager].rumManager syncProcess];
    [[FTLogger sharedInstance] syncProcess];
}
@end
