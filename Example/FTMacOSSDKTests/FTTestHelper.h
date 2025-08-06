//
//  FTTestHelper.h
//  FTMacOSSDKTests
//
//  Created by hulilei on 2023/5/9.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger,TestClickView){
    ClickTableView_AutoTrack = 200,
    ClickTableView_Rum = 201,
    ClickTableView_ConsoleLog = 206,
    ClickTabViewItem_First = 300,
    ClickTabViewItem_Second = 301,
    ClickTabViewItem_Third = 302,
    ClickCollectionViewItem = 306,
    ClickCollectionViewItem2 = 308,
    ClickPopUpButton = 320,
    ClickComboBox = 321,
    ClickButtonCheck = 322,
    ClickSegmentedControl = 323,
    ClickStepper = 324,
    ClickLableGes = 325,
    ClickImageGes = 326,
};
@interface FTTestHelper : XCTestCase
- (void)clickView:(TestClickView)view;
- (void)clickAtView:(NSView *)view;
- (void)sleep:(NSInteger)time;
- (void)jumpToMainTestWindow;
@end

NS_ASSUME_NONNULL_END
