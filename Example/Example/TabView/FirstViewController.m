//
//  FirstViewController.m
//  Example
//
//  Created by hulilei on 2021/9/10.
//

#import "FirstViewController.h"

@interface FirstViewController ()<NSComboBoxDelegate>
@property (strong) IBOutlet NSComboBox *comboBox;
@property (strong) IBOutlet NSPopUpButton *item;

@end

@implementation FirstViewController
-(void)viewWillAppear{
    [super viewWillAppear];
    NSLog(@"FirstViewController viewWillAppear");

}
- (void)viewDidAppear{
    [super viewDidAppear];
    NSLog(@"FirstViewController viewDidAppear");
    NSLog(@"keyWindow = %@",[NSApplication sharedApplication].keyWindow);
    self.comboBox.delegate = self;
}

- (void)viewClick:(NSGestureRecognizer *)gesture {
    NSLog(@"touch view");
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do view setup here.
}
- (void)comboBoxWillPopUp:(NSNotification *)notification{
    NSLog(@"keyWindow = %@",[NSApplication sharedApplication].keyWindow);
}
- (void)viewDidDisappear{
    [super viewDidDisappear];
    NSLog(@"FirstViewController viewDidDisappear");

}
@end
