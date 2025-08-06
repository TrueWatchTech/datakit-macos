//
//  FTAutoTrack.h
//  FTMacOSSDK-framework
//
//  Created by hulilei on 2021/9/9.
//

#import <Foundation/Foundation.h>
#import "FTRumDatasProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface FTAutoTrack : NSObject
@property (nonatomic,weak) id<FTRumDatasProtocol> addRumDatasDelegate;
/// Singleton
+ (instancetype)sharedInstance;
- (void)startHookView:(BOOL)enableView action:(BOOL)enableAction;
@end

NS_ASSUME_NONNULL_END
