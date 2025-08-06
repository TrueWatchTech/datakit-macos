//
//  FTGlobalRumManager+Private.h
//  Pods
//
//  Created by hulilei on 2023/3/17.
//

#import "FTMacOSSDK.h"
#import "FTGlobalRumManager.h"
#import "FTSDKConfig.h"
#import "FTRUMManager.h"
#import "FTRumDatasProtocol.h"
#import "FTRumResourceProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface FTGlobalRumManager ()<FTRumDatasProtocol,FTRumResourceProtocol>
@property (nonatomic, strong) FTRUMManager *rumManager;
-(void)setRumConfig:(FTRumConfig *)rumConfig;
-(void)rumDeinitialize;
@end

NS_ASSUME_NONNULL_END
