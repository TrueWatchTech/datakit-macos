//
//  FTErrorDataProtocol.h
//  FTMobileAgent
//
//  Created by hulilei on 2022/10/12.
//  Copyright © 2022 DataFlux-cn. All rights reserved.
//
#import <Foundation/Foundation.h>

/// Add error data protocol
@protocol FTErrorDataDelegate <NSObject>
/// Add Error data
/// - Parameters:
///   - type: Error type
///   - message: Error message
///   - stack: Stack information
- (void)internalErrorWithType:(NSString *)type message:(NSString *)message stack:(NSString *)stack;
@end
