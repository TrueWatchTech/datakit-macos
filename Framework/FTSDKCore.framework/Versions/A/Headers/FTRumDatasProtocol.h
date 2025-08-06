//
//  FTRumDatasProtocol.h
//  FTMobileAgent
//
//  Created by hulilei on 2022/6/13.
//  Copyright © 2022 DataFlux-cn. All rights reserved.
//

#ifndef FTAddRumDatasProtocol_h
#define FTAddRumDatasProtocol_h
NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, FTAppState) {
    FTAppStateUnknown,
    FTAppStateStartUp,
    FTAppStateRun,
};
/// RUM data protocol
@protocol FTRumDatasProtocol <NSObject>
/// Create page
///
/// Called before `-startViewWithName` method, this method is used to record page loading time, if loading time cannot be obtained this method can be skipped.
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

/// Add freeze event
///
/// - Parameters:
///   - stack: Freeze stack
///   - duration: Freeze duration (nanoseconds)
- (void)addLongTaskWithStack:(NSString *)stack duration:(NSNumber *)duration;

/// Add freeze event
/// - Parameters:
///   - stack: Freeze stack
///   - duration: Freeze duration (nanoseconds)
///   - property: Event custom properties (optional)
- (void)addLongTaskWithStack:(NSString *)stack duration:(NSNumber *)duration property:(nullable NSDictionary *)property;

@optional
/// Add Click Action event
///
/// - Parameters:
///   - actionName: Event name
- (void)addClickActionWithName:(NSString *)actionName;

/// Add Click Action event
/// - Parameters:
///   - actionName: Event name
///   - property: Event custom properties (optional)
- (void)addClickActionWithName:(NSString *)actionName property:(nullable NSDictionary *)property;
/**
 * Enter page
 * @param viewId          Page id
 * @param viewName         Page name
 */
-(void)startViewWithViewID:(NSString *)viewId viewName:(NSString *)viewName property:(nullable NSDictionary *)property;
/**
 * Leave page
 * @param viewId          Page id
 */
-(void)stopViewWithViewID:(NSString *)viewId property:(nullable NSDictionary *)property;
@end
NS_ASSUME_NONNULL_END
#endif 
