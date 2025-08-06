//
//  FTMonitorItem.h
//  FTMobileAgent
//
//  Created by hulilei on 2022/7/6.
//  Copyright © 2022 DataFlux-cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FTReadWriteHelper.h"
NS_ASSUME_NONNULL_BEGIN
@class FTDisplayRateMonitor,FTCPUMonitor,FTMemoryMonitor,FTMonitorValue;
/// Monitoring item, each ViewHandler in RUM contains a monitoring item to monitor data (memory, CPU, fps) during the View lifecycle
@interface FTMonitorItem : NSObject
/// FPS monitor
@property (nonatomic, strong) FTDisplayRateMonitor *displayRateMonitor;
/// CPU monitor
@property (nonatomic, strong) FTCPUMonitor *cpuMonitor;
/// Memory monitor
@property (nonatomic, strong) FTMemoryMonitor *memoryMonitor;

/// Monitoring item initialization method
/// - Parameters:
///   - cpuMonitor: CPU monitor
///   - memoryMonitor: Memory monitor
///   - displayRateMonitor: FPS monitor
///   - frequency: Sampling frequency
- (instancetype)initWithCpuMonitor:(FTCPUMonitor *)cpuMonitor memoryMonitor:(FTMemoryMonitor *)memoryMonitor displayRateMonitor:(FTDisplayRateMonitor *)displayRateMonitor frequency:(NSTimeInterval)frequency;
/// Get FPS data
- (FTMonitorValue *)refreshDisplay;
/// Get CPU data
- (FTMonitorValue *)cpu;
/// Get memory data
- (FTMonitorValue *)memory;

@end

NS_ASSUME_NONNULL_END
