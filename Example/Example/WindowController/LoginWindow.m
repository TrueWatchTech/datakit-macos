//
//  LoginWindow.m
//  Example
//
//  Created by hulilei on 2021/9/9.
//

#import "LoginWindow.h"

@implementation LoginWindow

-(instancetype)init{
    self = [super init];
    if(self){
        self.movableByWindowBackground = YES;
    }
    return self;
}
-(BOOL)canBecomeKeyWindow{
    
    return YES;
}
@end
