//
//  FTANRMonitor.h
//  FTMobileAgent
//
//  Created by hulilei on 2020/9/28.
//  Copyright © 2020 hll. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@protocol FTRunloopDetectorDelegate <NSObject>
@optional
- (void)longTaskStackDetected:(NSString*)slowStack duration:(long long)duration;
- (void)anrStackDetected:(NSString*)slowStack;
@end
@interface FTLongTaskDetector : NSObject

/// How many milliseconds exceed for one freeze, default 250 milliseconds
@property (nonatomic, assign) NSUInteger limitMillisecond;
/// Exceed 1000 milliseconds, record as one ANR freeze
@property (nonatomic, assign) NSUInteger limitANRMillisecond;
/// How many ANR freeze records count as one valid ANR
@property (nonatomic, assign) NSUInteger standstillCount;
-(instancetype)initWithDelegate:(id<FTRunloopDetectorDelegate>)delegate enableTrackAppANR:(BOOL)enableANR enableTrackAppFreeze:(BOOL)enableFreeze;

//must be called from main thread
- (void)startDetecting;
- (void)stopDetecting;

@end

NS_ASSUME_NONNULL_END
