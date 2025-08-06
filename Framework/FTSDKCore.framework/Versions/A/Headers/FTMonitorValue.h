//
//  FTMonitorValue.h
//  FTMobileAgent
//
//  Created by hulilei on 2022/7/5.
//  Copyright © 2022 DataFlux-cn. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Monitor value
@interface FTMonitorValue : NSObject
/// Sample count
@property (nonatomic, assign) int sampleValueCount;
/// Sample minimum value
@property (nonatomic, assign ,readonly) double minValue;
/// Sample maximum value
@property (nonatomic, assign ,readonly) double maxValue;
/// Sample average value
@property (nonatomic, assign ,readonly) double meanValue;

/// Add sample value
/// - Parameter sample: Sample value
- (void)addSample:(double)sample;
/// Sample maximum minimum difference
- (double)greatestDiff;
/// Scale down by ratio
/// - Parameter scale: Scale down ratio
- (FTMonitorValue *)scaledDown:(double)scale;
@end

NS_ASSUME_NONNULL_END
