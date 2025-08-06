//
//  NSMenuItem+FTAutoTrack.m
//  FTMacOSSDK-framework
//
//  Created by hulilei on 2021/9/28.
//

#import "NSMenuItem+FTAutoTrack.h"

@implementation NSMenuItem (FTAutoTrack)
-(NSString *)datakit_actionName{
    return [NSString stringWithFormat:@"[NSMenuItem]%@",self.title];
}
@end
