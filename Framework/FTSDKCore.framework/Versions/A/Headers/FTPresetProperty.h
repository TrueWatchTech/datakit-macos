//
//  FTPresetProperty.h
//  FTMobileAgent
//
//  Created by hulilei on 2020/10/23.
//  Copyright © 2020 hll. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FTEnumConstant.h"
#import "FTSDKCompat.h"
#import "FTReadWriteHelper.h"

NS_ASSUME_NONNULL_BEGIN
@class FTUserInfo;
/// Preset properties
@interface FTPresetProperty : NSObject
/// Application unique ID
@property (nonatomic, copy) NSString *appID;
/// User set logger globalContext
@property (nonatomic, strong) NSDictionary *logContext;
/// User set rum globalContext
@property (nonatomic, strong) NSDictionary *rumContext;
/// Read-write protected user information
@property (nonatomic, strong) FTReadWriteHelper<FTUserInfo*> *userHelper;
@property (nonatomic, copy) NSString *sdkVersion;
/// Device name
+ (NSString *)deviceInfo;
#if FT_MAC
+ (NSString *)getDeviceUUID;
+ (NSString *)macOSdeviceModel;
+ (NSString *)macOSSystermVersion;
#endif

/// Initialization method
/// - Parameter version: Version number
/// - Parameter env: Environment
/// - Parameter service: Service
/// - Parameter globalContext: Global custom properties
- (instancetype)initWithVersion:(NSString *)version env:(NSString *)env service:(NSString *)service globalContext:(NSDictionary *)globalContext;
/// Disable init initialization
- (instancetype)init NS_UNAVAILABLE;

/// Disable new initialization
+ (instancetype)new NS_UNAVAILABLE;

/// Get Rum ES common Tag
- (NSMutableDictionary *)rumProperty;
- (NSDictionary *)rumDynamicProperty;
/// Get logger data common Tag
/// - Parameters:
///   - status: Event level and status
- (NSDictionary *)loggerPropertyWithStatus:(LogStatus)status;
/// Reset SDK configuration items
/// - Parameter version: Version number
/// - Parameter env: Environment
/// - Parameter service: Service
/// - Parameter globalContext: Global custom properties
- (void)resetWithVersion:(NSString *)version env:(NSString *)env service:(NSString *)service globalContext:(NSDictionary *)globalContext;
@end

NS_ASSUME_NONNULL_END
