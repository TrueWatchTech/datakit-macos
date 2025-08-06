//
//  NSTabView+FTAutoTrack.m
//  FTMacOSSDK-framework
//
//  Created by hulilei on 2021/9/26.
//

#import "NSTabView+FTAutoTrack.h"
#import "FTSwizzler.h"
#import "FTGlobalRumManager.h"
#import "NSView+FTAutoTrack.h"
#import "FTInternalLog.h"
#import "FTAutoTrack.h"
@implementation NSTabView (FTAutoTrack)
-(NSString *)datakit_actionName{
    if(self.selectedTabViewItem.label.length>0){
        return [NSString stringWithFormat:@"[%@]%@",NSStringFromClass(self.class),self.selectedTabViewItem.label];
    }
    NSInteger index = [self indexOfTabViewItem:self.selectedTabViewItem];
    if(index != NSNotFound){
        return [NSString stringWithFormat:@"[%@]selectedIndex:%ld",NSStringFromClass(self.class),(long)index];
    }
    return [NSString stringWithFormat:@"[%@]",NSStringFromClass(self.class)];
}
-(void)datakit_setDelegate:(id<NSTabViewDelegate>)delegate{
    [self datakit_setDelegate:delegate];
    if (self.delegate == nil) {
        return;
    }
    SEL selector = @selector(tabView:didSelectTabViewItem:);
    Class class = [FTSwizzler realDelegateClassFromSelector:selector proxy:delegate];
    
    if ([FTSwizzler realDelegateClass:class respondsToSelector:selector]) {
        void (^didSelectItemBlock)(id, SEL, id, id) = ^(id view, SEL command, NSTabView *tabView, NSTabViewItem *tabViewItem) {
            
            if (tabView && tabViewItem) {
                if([FTAutoTrack sharedInstance].addRumDatasDelegate && [[FTAutoTrack sharedInstance].addRumDatasDelegate respondsToSelector:@selector(addClickActionWithName:)]){
                    [[FTAutoTrack sharedInstance].addRumDatasDelegate addClickActionWithName:self.datakit_actionName];
                }
            }
        };
        
        [FTSwizzler swizzleSelector:selector
                            onClass:class
                          withBlock:didSelectItemBlock
                              named:@"tabView_didSelect"];
    }
    
}

@end
