//
//  AppDelegate.m
//  Example
//
//  Created by hulilei on 2021/8/31.
//

#import "AppDelegate.h"
#import "LoginWindowController.h"
@interface AppDelegate ()

@property (nonatomic, strong) LoginWindowController *loginWindowC;
@property (nonatomic, strong) NSStatusItem *statusItem;

@end

@implementation AppDelegate
- (void)applicationWillFinishLaunching:(NSNotification *)notification{
    NSStatusBar *bar = [NSStatusBar systemStatusBar];
    NSStatusItem *item = [bar statusItemWithLength:NSSquareStatusItemLength];
    [item.button setTarget:self];
    [item.button setAction:@selector(itemClick:)];
    item.button.image = [NSImage imageNamed:@"blue"];
    self.statusItem = item;
}
- (void)itemClick:(id)sender{
    
}
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
   
//    [[FTSDKAgent sharedInstance] logging:@"applicationDidFinishLaunching" status:FTStatusInfo];
//    [self.loginWindowC showWindow:self];
    
}

-(LoginWindowController *)loginWindowC{
    if (!_loginWindowC) {
        _loginWindowC = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"LoginWindowController"];
    }
    return _loginWindowC;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    NSStatusBar *bar = [NSStatusBar systemStatusBar];
    [bar removeStatusItem:self.statusItem];
}


@end
