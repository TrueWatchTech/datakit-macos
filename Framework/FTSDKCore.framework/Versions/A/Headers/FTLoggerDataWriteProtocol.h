//
//  FTLoggerDataWriteProtocol.h
//  FTMobileSDK
//
//  Created by hulilei on 2023/5/26.
//  Copyright © 2023 DataFlux-cn. All rights reserved.
//

#ifndef FTLoggerDataWriteProtocol_h
#define FTLoggerDataWriteProtocol_h
#import "FTEnumConstant.h"
NS_ASSUME_NONNULL_BEGIN
/// RUM data writing interface
@protocol FTLoggerDataWriteProtocol <NSObject>

/// Logger data writing
/// - Parameters:
///   - content: Log content
///   - status: Log status
///   - tags: Properties
///   - field: Metrics
///   - time: Data generation timestamp (ns)
-(void)logging:(NSString *)content status:(LogStatus)status tags:(nullable NSDictionary *)tags field:(nullable NSDictionary *)field time:(long long)time;
@end
NS_ASSUME_NONNULL_END

#endif /* FTLoggerDataWriteProtocol_h */
