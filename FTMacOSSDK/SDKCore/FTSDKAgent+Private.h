//
//  FTSDKAgent+Private.h
//  FTMacOSSDK-framework
//
//  Created by hulilei on 2021/9/24.
//

#import "FTSDKAgent.h"
#import "FTRUMDataWriteProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface FTSDKAgent (Private)<FTRUMDataWriteProtocol>
#if FTMacOSSDK_COMPILED_FOR_TESTING
- (void)syncProcess;
#endif
@end

NS_ASSUME_NONNULL_END
