//
//  FTGlobalRumManager.h
//  FTMobileAgent
//
//  Created by hulilei on 2020/4/14.
//  Copyright © 2020 hll. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum FTAppState:NSUInteger FTAppState;

NS_ASSUME_NONNULL_BEGIN
@class FTResourceMetricsModel,FTResourceContentModel;
/// SDK uses this class to enable various RUM functionalities. Users can add RUM events through the FTGlobalRumManager singleton
@interface FTGlobalRumManager : NSObject

/// Get FTGlobalRumManager singleton
+ (instancetype)sharedManager;

/// Create page
///
/// Called before the `-startViewWithName` method. This method is used to record the page loading time. If the loading time cannot be obtained, this method can be omitted.
/// - Parameters:
///   - viewName: Page name
///   - loadTime: Page loading time
-(void)onCreateView:(NSString *)viewName loadTime:(NSNumber *)loadTime;
/// Enter page
///
/// - Parameters:
///   - viewName: Page name
-(void)startViewWithName:(NSString *)viewName;
/// Enter page
/// - Parameters:
///   - viewName: Page name
///   - property: Event custom properties (optional)
-(void)startViewWithName:(NSString *)viewName property:(nullable NSDictionary *)property;

/// Leave page
-(void)stopView;

/// Leave page
/// - Parameter property: Event custom properties (optional)
-(void)stopViewWithProperty:(nullable NSDictionary *)property;

/// Add Action event
///
/// - Parameters:
///   - actionName: Event name
///   - actionType: Event type
- (void)addActionName:(NSString *)actionName actionType:(NSString *)actionType;
/// Add Action event
/// - Parameters:
///   - actionName: Event name
///   - actionType: Event type
///   - property: Event custom properties (optional)
- (void)addActionName:(NSString *)actionName actionType:(NSString *)actionType property:(nullable NSDictionary *)property;

/// Add Error event
///
/// - Parameters:
///   - type: Error type
///   - message: Error message
///   - stack: Stack information
- (void)addErrorWithType:(NSString *)type message:(NSString *)message stack:(NSString *)stack;
/// Add Error event
/// - Parameters:
///   - type: Error type
///   - message: Error message
///   - stack: Stack information
///   - property: Event custom properties (optional)
- (void)addErrorWithType:(NSString *)type message:(NSString *)message stack:(NSString *)stack property:(nullable NSDictionary *)property;

/// Add Error event
/// - Parameters:
///   - type: Error type
///   - state: Program running state
///   - message: Error message
///   - stack: Stack information
///   - property: Event custom properties (optional)
- (void)addErrorWithType:(NSString *)type state:(FTAppState)state  message:(NSString *)message stack:(NSString *)stack property:(nullable NSDictionary *)property;

/// Add Long Task event
///
/// - Parameters:
///   - stack: Long task stack
///   - duration: Long task duration (nanoseconds)
- (void)addLongTaskWithStack:(NSString *)stack duration:(NSNumber *)duration;

/// Add Long Task event
/// - Parameters:
///   - stack: Long task stack
///   - duration: Long task duration (nanoseconds)
///   - property: Event custom properties (optional)
- (void)addLongTaskWithStack:(NSString *)stack duration:(NSNumber *)duration property:(nullable NSDictionary *)property;
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

@end

NS_ASSUME_NONNULL_END
