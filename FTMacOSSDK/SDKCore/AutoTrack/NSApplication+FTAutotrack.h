//
//  NSApplication+FTAutotrack.h
//  Pods
//
//  Created by hulilei on 2021/9/10.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSApplication (FTAutotrack)
- (BOOL)datakit_sendAction:(SEL)action to:(nullable id)target from:(nullable id)sender;
@end

NS_ASSUME_NONNULL_END
