//
//  FTAutoTrack.m
//  FTMacOSSDK-framework
//
//  Created by hulilei on 2021/9/9.
//

#import "FTAutoTrack.h"
#import "FTInternalLog.h"
#import "FTSwizzle.h"
#import "NSWindow+FTAutoTrack.h"
#import "NSApplication+FTAutotrack.h"
#import "NSCollectionView+FTAutoTrack.h"
#import "NSTabView+FTAutoTrack.h"
@implementation FTAutoTrack

+ (instancetype)sharedInstance {
    static FTAutoTrack *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}
- (void)startHookView:(BOOL)enableView action:(BOOL)enableAction{
    if(enableView){
        [self logWindowLifeCycle];
    }
    if(enableAction){
        [self logTargetAction];
    }
}
- (void)logWindowLifeCycle{
    @try {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSError *error = NULL;
            [NSWindow ft_swizzleMethod:@selector(initWithCoder:) withMethod:@selector(datakit_initWithCoder:) error:&error];
            [NSWindow ft_swizzleMethod:@selector(initWithContentRect:styleMask:backing:defer:) withMethod:@selector(datakit_initWithContentRect:styleMask:backing:defer:) error:&error];
            [NSWindow ft_swizzleMethod:@selector(init) withMethod:@selector(datakit_init) error:&error];
            [NSWindow ft_swizzleMethod:@selector(resignKeyWindow) withMethod:@selector(datakit_resignKeyWindow) error:&error];
            [NSWindow ft_swizzleMethod:@selector(becomeKeyWindow) withMethod:@selector(datakit_becomeKeyWindow) error:&error];
        });
    } @catch (NSException *exception) {
        FTInnerLogError(@"exception: %@", exception);
    }
}
- (void)logTargetAction{
    @try {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSError *error = NULL;
            [NSApplication ft_swizzleMethod:@selector(sendAction:to:from:) withMethod:@selector(datakit_sendAction:to:from:) error:&error];
            [NSCollectionView ft_swizzleMethod:@selector(setDelegate:) withMethod:@selector(datakit_setDelegate:) error:&error];
            [NSTabView ft_swizzleMethod:@selector(setDelegate:) withMethod:@selector(datakit_setDelegate:) error:&error];
        });
    } @catch (NSException *exception) {
        FTInnerLogError(@"exception: %@", exception);
    }
}
@end
