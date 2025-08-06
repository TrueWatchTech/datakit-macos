//
//  FTReadWriteHelper.h
//  FTMobileAgent
//
//  Created by hulilei on 2022/7/7.
//  Copyright © 2022 DataFlux-cn. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Thread-safe multi-read single-write tool implemented using GCD barrier mode; ValueType generic
@interface FTReadWriteHelper<ValueType> : NSObject
/// Initialize
/// - Parameter value: Object that needs thread safety
-(instancetype)initWithValue:(ValueType)value;

/// Thread-safe read data
/// - Parameter block: Read data block
- (void)concurrentRead:(void (^)(ValueType value))block;
/// Thread-safe write data
/// - Parameter block: Write data block
- (void)concurrentWrite:(void (^)(ValueType value))block;
/// Thread-safe read data
/// - Returns: Read data.
- (ValueType)currentValue;
@end

NS_ASSUME_NONNULL_END
