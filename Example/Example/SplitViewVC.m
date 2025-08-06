//
//  SplitViewVC.m
//  Example
//
//  Created by hulilei on 2021/9/26.
//

#import "SplitViewVC.h"
#import "SplitViewItemVC2.h"
@interface SplitViewVC ()

@end

@implementation SplitViewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    for (NSSplitViewItem *item in self.splitViewItems) {
        NSLog(@"NSSplitViewItem viewController = %@",item.viewController);

    }
    // Do view setup here.
}
- (void)tableViewSelectionDidSelect:(NSInteger)index{
    SplitViewItemVC2 *item2 = (SplitViewItemVC2 *)self.splitViewItems[1].viewController;
    [item2 showViewIndex:index];
}
@end
