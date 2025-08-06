//
//  NSTabView+FTAutoTrack.h
//  FTMacOSSDK-framework
//
//  Created by hulilei on 2021/9/26.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSTabView (FTAutoTrack)
-(void)datakit_setDelegate:(id<NSTabViewDelegate>)delegate;
@end

NS_ASSUME_NONNULL_END
