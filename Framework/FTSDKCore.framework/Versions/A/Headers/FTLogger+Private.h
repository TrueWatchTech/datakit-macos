//
//  FTLogger+Private.h
//  FTMobileSDK
//
//  Created by hulilei on 2023/5/26.
//  Copyright © 2023 DataFlux-cn. All rights reserved.
//

#import "FTLogger.h"
#import "FTEnumConstant.h"
#import "FTLoggerDataWriteProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface FTLogger ()
/// Called when SDK starts, enable Logger
/// - Parameters:
///   - enable: Whether to output to console
///   - enableCustomLog: Whether to collect custom logs
///   - filter: Log filtering rules
///   - sampletRate: Collection rate
///   - writer: Data writing object
+ (void)startWithEnablePrintLogsToConsole:(BOOL)enable enableCustomLog:(BOOL)enableCustomLog logLevelFilter:(NSArray<NSNumber*>*)filter sampleRate:(int)sampletRate writer:(id<FTLoggerDataWriteProtocol>)writer;

/// Log input
/// - Parameters:
///   - message: Log content, can be JSON string
///   - status: Level and status
///   - property: Custom properties (optional)
- (void)log:(NSString *)message
     status:(LogStatus)status
   property:(nullable NSDictionary *)property;

/// Synchronously execute log processing queue
- (void)syncProcess;
@end

NS_ASSUME_NONNULL_END
