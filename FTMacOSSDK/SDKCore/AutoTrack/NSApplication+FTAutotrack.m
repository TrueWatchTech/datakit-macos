//
//  NSApplication+FTAutotrack.m
//  Pods
//
//  Created by hulilei on 2021/9/10.
//

#import "NSApplication+FTAutotrack.h"
#import "FTGlobalRumManager.h"
#import "NSView+FTAutoTrack.h"
#import "FTAutoTrack.h"
#import "NSMenuItem+FTAutoTrack.h"
@implementation NSApplication (FTAutotrack)
- (BOOL)datakit_sendAction:(SEL)action to:(nullable id)target from:(nullable id)sender{
    [self datakitTrack:action to:target from:sender];
    return [self datakit_sendAction:action to:target from:sender];
}
- (void)datakitTrack:(SEL)action to:(id)target from:(id )sender{

    if (![sender isKindOfClass:[NSView class]] && ![sender isKindOfClass:[NSMenuItem class]] && ![sender isKindOfClass:[NSGestureRecognizer class]]) {
        return;
    }
    //Don't collect drag events
    if (self.currentEvent.type != NSEventTypeLeftMouseUp &&  self.currentEvent.type != NSEventTypeLeftMouseDown ) {
        return;
    }
    //Handle gesture events
    if ([sender isKindOfClass:NSGestureRecognizer.class]) {
        NSGestureRecognizer *ges = (NSGestureRecognizer *)sender;
        if (ges.state != NSGestureRecognizerStateEnded) {
            return;
        }
        NSView *view = ges.view;
        if([view isKindOfClass:[NSImageView class]]||[view isKindOfClass:[NSTextField class]]){
            if([FTAutoTrack sharedInstance].addRumDatasDelegate && [[FTAutoTrack sharedInstance].addRumDatasDelegate respondsToSelector:@selector(addClickActionWithName:)]){
                [[FTAutoTrack sharedInstance].addRumDatasDelegate addClickActionWithName:view.datakit_actionName];
            }
        }
        return;
    }
    //NSMenu doesn't inherit from NSView
    if ([sender isKindOfClass:NSMenuItem.class]) {
        // Exclude NSPopUpButton popped NSMenuItem clicks to avoid duplication
        if(target != NULL && [target isKindOfClass:[NSPopUpButtonCell class]]){
            return;
        }
        NSMenuItem *menu = (NSMenuItem *)sender;
        if([FTAutoTrack sharedInstance].addRumDatasDelegate && [[FTAutoTrack sharedInstance].addRumDatasDelegate respondsToSelector:@selector(addClickActionWithName:)]){
            [[FTAutoTrack sharedInstance].addRumDatasDelegate addClickActionWithName:menu.datakit_actionName];
        }
        return;
    }
    //Don't collect click events on scrollbars
    if ([sender isKindOfClass:NSScroller.class]){
        return;
    }
    //Filter NSTableView doubleAction
    if([sender isKindOfClass:NSTableView.class]){
        NSTableView *tableView = (NSTableView *)sender;
        if(action && tableView.doubleAction != tableView.action && tableView.doubleAction == action){
            return;
        }
    }
    NSView *view = sender;
    //Don't collect click events if view has no window
    if(!view.window){
        return;
    }
    NSString *actionName = view.datakit_actionName;
    // NSDatePicker
    if([sender isKindOfClass:NSDatePicker.class]){
        // Filter out NSEventTypeLeftMouseDown without action
        if( self.currentEvent.type == NSEventTypeLeftMouseDown && !action){
            return;
        }
        NSDatePicker *datePicker = (NSDatePicker *)view;
        if (action && datePicker.datePickerStyle == NSDatePickerStyleClockAndCalendar){
            actionName = [NSString stringWithFormat:@"[%@]%@",NSStringFromClass([sender class]),NSStringFromSelector(action)];
        }
    }
    //Filter NSComboBox dropdown selection box click events to avoid duplication
    if ([sender isKindOfClass:NSClassFromString(@"NSComboTableView")]){
        return;
    }
    //Filter NSSearchField cancel button multiple sendAction on single click, and distinguish between search button and cancel button
    if ([sender isKindOfClass:NSSearchField.class]) {
        if(!action){
            return;
        }
        actionName = [NSString stringWithFormat:@"[%@]%@",NSStringFromClass([sender class]),NSStringFromSelector(action)];
    }
    if([sender isKindOfClass:NSDatePicker.class] && action){
        actionName = [NSString stringWithFormat:@"[%@]%@",NSStringFromClass([sender class]),NSStringFromSelector(action)];
    }
    
    if([FTAutoTrack sharedInstance].addRumDatasDelegate && [[FTAutoTrack sharedInstance].addRumDatasDelegate respondsToSelector:@selector(addClickActionWithName:)]){
        [[FTAutoTrack sharedInstance].addRumDatasDelegate addClickActionWithName:actionName];
    }
    
}
@end
