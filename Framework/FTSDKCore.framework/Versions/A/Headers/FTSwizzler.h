//
//  FTSwizzler.h
//  FTMobileAgent
//
//  Created by hulilei on 2021/7/2.
//  Copyright © 2021 hll. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MAPTABLE_ID(x) (__bridge id)((void *)x)

// Ignore the warning cause we need the paramters to be dynamic and it's only being used internally
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"
typedef void (^datafluxSwizzleBlock)();
#pragma clang diagnostic pop
/// Method swizzling tool
///
/// Usage notes: Determine if parameters are basic constants, if so, you may need to add replacement methods yourself
@interface FTSwizzler : NSObject

/// Method swizzling
/// - Parameters:
///   - aSelector: Method to hook
///   - aClass: Class of the method
///   - block: Code block to execute after hooking the method
///   - aName: Tag
+ (void)swizzleSelector:(SEL)aSelector onClass:(Class)aClass withBlock:(datafluxSwizzleBlock)block named:(NSString *)aName;
/// Cancel method swizzling
/// - Parameters:
///   - aSelector: Hooked method
///   - aClass: Class of the method
+ (void)unswizzleSelector:(SEL)aSelector onClass:(Class)aClass;
/// Cancel method swizzling based on tag, other swizzles for this method continue to take effect
/// - Parameters:
///   - aSelector: Hooked method
///   - aClass: Class of the method
///   - aName: Tag
+ (void)unswizzleSelector:(SEL)aSelector onClass:(Class)aClass named:(NSString *)aName;
+ (void)printSwizzles;
+ (BOOL)realDelegateClass:(Class)cls respondsToSelector:(SEL)sel;
+ (Class)realDelegateClassFromSelector:(SEL)selector proxy:(id)proxy;
@end
