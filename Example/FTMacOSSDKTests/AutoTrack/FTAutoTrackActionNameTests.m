//
//  FTAutoTrackActionNameTests.m
//  FTMacOSSDKTests
//
//  Created by hulilei on 2023/5/5.
//

#import <XCTest/XCTest.h>
#import "FTTestHelper.h"
#import "NSCollectionView+FTAutoTrack.h"
#import "NSMenuItem+FTAutoTrack.h"
#import "NSTabView+FTAutoTrack.h"
#import "NSView+FTAutoTrack.h"
#import "FTMacOSSDK.h"
#import "FTTrackerEventDBTool.h"
#import "LoginWindow.h"
#import "FTSDKAgent+Private.h"
#import "FTRUMManager.h"
#import "FTGlobalRumManager+Private.h"
#import "SplitViewVC.h"
#import "SplitViewItemVC2.h"
@interface FTAutoTrackActionNameTests : FTTestHelper
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *appid;
@end

@implementation FTAutoTrackActionNameTests
// NSButton、NSPopUpButton、NSSegmentedControl
- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    NSProcessInfo *processInfo = [NSProcessInfo processInfo];
    self.url = [processInfo environment][@"ACCESS_SERVER_URL"];
    self.appid = [processInfo environment][@"APP_ID"];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}
- (void)testButtonActionName{
    NSButton *button = [[NSButton alloc]init];
    button.title = @"testActionName";
    NSString *actionName = [button datakit_actionName];
    XCTAssertTrue([actionName isEqualToString:@"[NSButton]testActionName"]);
    
    NSButton *checkButton = [NSButton checkboxWithTitle:@"check" target:self action:@selector(check)];
    checkButton.state = NSControlStateValueOn;
    XCTAssertTrue([[checkButton datakit_actionName] isEqualToString:@"[NSButton]check"]);
}
- (void)testPopUpButtonActionName{
    NSPopUpButton *popupButton = [[NSPopUpButton alloc]init];
    [popupButton addItemsWithTitles:@[@"Normal Speed", @"2x Speed", @"4x Speed", @"8x Speed", @"16x Speed"]];
    XCTAssertTrue([[popupButton datakit_actionName] isEqualToString:@"[NSPopUpButton]Normal Speed"]);
    [popupButton selectItemAtIndex:1];
    XCTAssertTrue([[popupButton datakit_actionName] isEqualToString:@"[NSPopUpButton]2x Speed"]);
}
- (void)testSegmentedControlActionName{
    NSSegmentedControl *segmentedControl = [[NSSegmentedControl alloc]init];
    segmentedControl.segmentCount = 3;
    [segmentedControl setLabel:@"first" forSegment:0];
    [segmentedControl setLabel:@"second" forSegment:1];
    [segmentedControl setLabel:@"third" forSegment:2];
    [segmentedControl setSelectedSegment:1];
    XCTAssertTrue([[segmentedControl datakit_actionName] isEqualToString:@"[NSSegmentedControl]second"]);
    NSSegmentedControl *menuControl = [[NSSegmentedControl alloc]init];
    menuControl.segmentCount = 3;
    [menuControl setMenu:[[NSMenu alloc]initWithTitle:@"one"] forSegment:0];
    [menuControl setMenu:[[NSMenu alloc]initWithTitle:@"two"] forSegment:1];
    [menuControl setMenu:[[NSMenu alloc]initWithTitle:@"three"] forSegment:2];
    [menuControl setSelectedSegment:2];
    
    XCTAssertTrue([[menuControl datakit_actionName] isEqualToString:@"[NSSegmentedControl]three"]);

}
- (void)testStepperActionName{
    NSStepper *stepper = [[NSStepper alloc]init];
    stepper.minValue = 0;
    stepper.maxValue = 100;
    XCTAssertTrue([[stepper datakit_actionName] isEqualToString:@"[NSStepper]0"]);
}
- (void)testSliderActionName{
    NSSlider *slider = [[NSSlider alloc]init];
    slider.minValue = 0;
    slider.maxValue = 100;
    XCTAssertTrue([[slider datakit_actionName] isEqualToString:@"[NSSlider]0"]);
}
- (void)testComboBoxActionName{
    NSComboBox *comboBox = [[NSComboBox alloc]init];
    [comboBox addItemWithObjectValue:@1];
    [comboBox addItemWithObjectValue:@2];
    [comboBox addItemsWithObjectValues:@[@3,@4,@5,@6]];
    [comboBox selectItemWithObjectValue:@2];
    XCTAssertTrue([[comboBox datakit_actionName] isEqualToString:@"[NSComboBox]2"]);
}
- (void)testSwitchActionName{
    if (@available(macOS 10.15, *)) {
        NSSwitch *mSwitch = [[NSSwitch alloc]init];
        mSwitch.state = NSControlStateValueOn;
        XCTAssertTrue([[mSwitch datakit_actionName] isEqualToString:@"[NSSwitch]On"]);
    }
}
// NSGestureRecognizer
// 
- (void)testLableActionName{
    NSTextField *lable = [[NSTextField alloc]init];
    lable.stringValue = @"test";
    XCTAssertTrue([[lable datakit_actionName] isEqualToString:@"[NSTextField]test"]);
    NSSecureTextField *secureLable = [[NSSecureTextField alloc]init];
    secureLable.stringValue = @"secureTest";
    XCTAssertTrue([[secureLable datakit_actionName] isEqualToString:@"[NSSecureTextField]"]);

}
- (void)testImageViewActionName{
    NSImageView *image = [[NSImageView alloc]init];
    image.image = [NSImage imageNamed:NSImageNameComputer];
    XCTAssertTrue([[image datakit_actionName] isEqualToString:@"[NSImageView]"]);
}
- (void)testActionLaunch{
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
    [self setRumConfig];
    XCTestExpectation *expectation= [self expectationWithDescription:@"Asynchronous operation timeout"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
    [[FTGlobalRumManager sharedManager].rumManager syncProcess];
    NSArray *array = [[FTTrackerEventDBTool sharedManger] getFirstRecords:10 withType:FT_DATA_TYPE_RUM];
    BOOL hasLaunchData = NO;
    for (FTRecordModel *model in array) {
        NSDictionary *dict = [FTJSONUtil dictionaryWithJsonString:model.data];
         if([dict[FT_OP] isEqualToString:FT_DATA_TYPE_RUM]){
             NSDictionary *data = dict[FT_OPDATA];
             if([data[FT_KEY_SOURCE] isEqualToString:FT_RUM_SOURCE_ACTION]){
                 NSDictionary *tags = data[FT_TAGS];
                 NSString *actionName = tags[FT_KEY_ACTION_NAME];
                 XCTAssertTrue([actionName isEqualToString:@"app_cold_start"]);
                 hasLaunchData = YES;
                 break;
             }
         }
     }
     XCTAssertTrue(hasLaunchData == YES);
     [[FTSDKAgent sharedInstance] shutDown];
}
- (void)testClickButtonAndTableView{
    [self setRumConfig];
    [self jumpToMainTestWindow];
    [self clickView:ClickTableView_AutoTrack];
    [self clickView:ClickTableView_AutoTrack];
    [self sleep:1];
    [[FTGlobalRumManager sharedManager].rumManager syncProcess];
    NSArray *datas = [[FTTrackerEventDBTool sharedManger] getFirstRecords:10 withType:FT_DATA_TYPE_RUM];
    XCTAssertTrue(datas.count>0);
    BOOL tableViewClick = NO,loginBtnClick = NO;
    for (FTRecordModel *model in datas) {
        NSDictionary *dict = [FTJSONUtil dictionaryWithJsonString:model.data];
        NSDictionary *data = dict[FT_OPDATA];
        if([data[FT_KEY_SOURCE] isEqualToString:FT_RUM_SOURCE_ACTION]){
            NSDictionary *data = dict[FT_OPDATA];
            NSDictionary *tags = data[FT_TAGS];
            NSString *actionName = tags[FT_KEY_ACTION_NAME];
            if([actionName isEqualToString:@"[NSButton]Login"]){
                loginBtnClick = YES;
            }else if([actionName isEqualToString:@"[NSTableView]AutoTrack Click"]){
                tableViewClick = YES;
            }
        }
    }
    XCTAssertTrue(loginBtnClick);
    XCTAssertTrue(tableViewClick);
    [[FTSDKAgent sharedInstance] shutDown];
}
- (void)testClickCollectionView{
    [self setRumConfig];
    [self jumpToMainTestWindow];
    [self clickView:ClickTableView_AutoTrack];
    [self clickView:ClickTabViewItem_Third];
    [self sleep:0.5];
    [self clickView:ClickCollectionViewItem];
    [self clickView:ClickCollectionViewItem2];
    [self sleep:1];
    [[FTGlobalRumManager sharedManager].rumManager syncProcess];
    NSArray *datas = [[FTTrackerEventDBTool sharedManger] getFirstRecords:10 withType:FT_DATA_TYPE_RUM];
    XCTAssertTrue(datas.count>0);
    BOOL tabViewItemClick = NO,collectionView = NO;
    for (FTRecordModel *model in datas) {
        NSDictionary *dict = [FTJSONUtil dictionaryWithJsonString:model.data];
        NSDictionary *data = dict[FT_OPDATA];
        if([data[FT_KEY_SOURCE] isEqualToString:FT_RUM_SOURCE_ACTION]){
            NSDictionary *data = dict[FT_OPDATA];
            NSDictionary *tags = data[FT_TAGS];
            NSString *actionName = tags[FT_KEY_ACTION_NAME];
            if([actionName isEqualToString:@"[NSTabView]ThirdView"]){
                tabViewItemClick = YES;
            }else if([actionName isEqualToString:@"[NSCollectionView][section:0][item:1]"]){
                collectionView = YES;
            }
        }
    }
    XCTAssertTrue(tabViewItemClick);
    XCTAssertTrue(collectionView);
}
// NSPopUpButton\NSComboBox\NSButton
- (void)testClickFirstView{
    [self setRumConfig];
    [self jumpToMainTestWindow];
    [self clickView:ClickTableView_AutoTrack];
    [self clickView:ClickTabViewItem_First];
    [self sleep:0.5];
    [self clickView:ClickComboBox];
    [self clickView:ClickPopUpButton];
    [self clickView:ClickButtonCheck];
    [self clickView:ClickButtonCheck];
    [self sleep:1];
    [[FTGlobalRumManager sharedManager].rumManager syncProcess];
    NSArray *datas = [[FTTrackerEventDBTool sharedManger] getFirstRecords:30 withType:FT_DATA_TYPE_RUM];
    XCTAssertTrue(datas.count>0);
    BOOL popUpButtonClick = NO,comboBoxClick = NO,comboBoxItemClick = NO,buttonClick = NO;
    NSInteger count = 0;
    for (FTRecordModel *model in datas) {
        NSDictionary *dict = [FTJSONUtil dictionaryWithJsonString:model.data];
        NSDictionary *data = dict[FT_OPDATA];
        if([data[FT_KEY_SOURCE] isEqualToString:FT_RUM_SOURCE_ACTION]){
            count ++;
            NSDictionary *data = dict[FT_OPDATA];
            NSDictionary *tags = data[FT_TAGS];
            NSString *actionName = tags[FT_KEY_ACTION_NAME];
            if([actionName isEqualToString:@"[NSPopUpButton]Item 2"]){
                popUpButtonClick = YES;
            }else if([actionName isEqualToString:@"[NSComboBox]"]){
                comboBoxClick = YES;
            }else if([actionName isEqualToString:@"[NSComboBox]Item 1"]){
                comboBoxItemClick = YES;
            }else if([actionName isEqualToString:@"[NSButton]Check"]){
                buttonClick = YES;
            }
        }
    }
    XCTAssertTrue(popUpButtonClick);
    XCTAssertTrue(comboBoxClick);
    XCTAssertTrue(comboBoxItemClick);
    XCTAssertTrue(buttonClick);
}
// NSSegmentedControl\NSStepper\NSTextField\NSImageView
- (void)testClickSecondView{
    [self setRumConfig];
    [self jumpToMainTestWindow];
    [self clickView:ClickTableView_AutoTrack];
    [self clickView:ClickTabViewItem_Second];
    [self sleep:0.5];
    [self clickView:ClickSegmentedControl];
    [self clickView:ClickStepper];
    [self clickView:ClickLableGes];
    [self clickView:ClickImageGes];
    [self clickView:ClickImageGes];
    [self sleep:1];
    [[FTGlobalRumManager sharedManager].rumManager syncProcess];
    NSArray *datas = [[FTTrackerEventDBTool sharedManger] getFirstRecords:30 withType:FT_DATA_TYPE_RUM];
    XCTAssertTrue(datas.count>0);
    BOOL segmentedControlClick = NO,stepperClick = NO,lableClick = NO,imageClick = NO;
    NSInteger count = 0;
    for (FTRecordModel *model in datas) {
        NSDictionary *dict = [FTJSONUtil dictionaryWithJsonString:model.data];
        NSDictionary *data = dict[FT_OPDATA];
        if([data[FT_KEY_SOURCE] isEqualToString:FT_RUM_SOURCE_ACTION]){
            count ++ ;
            NSDictionary *data = dict[FT_OPDATA];
            NSDictionary *tags = data[FT_TAGS];
            NSString *actionName = tags[FT_KEY_ACTION_NAME];
            if([actionName isEqualToString:@"[NSSegmentedControl]1"]){
                segmentedControlClick = YES;
            }else if([actionName isEqualToString:@"[NSStepper]2"]){
                stepperClick = YES;
            }else if([actionName isEqualToString:@"[NSTextField]Label"]){
                lableClick = YES;
            }else if([actionName isEqualToString:@"[NSImageView]"]){
                imageClick = YES;
            }
        }
    }
    XCTAssertTrue(count>6 && count<9);
    XCTAssertTrue(segmentedControlClick);
    XCTAssertTrue(stepperClick);
    XCTAssertTrue(lableClick);
    XCTAssertTrue(imageClick);
}
- (void)setRumConfig{
    FTSDKConfig *config = [[FTSDKConfig alloc]initWithDatakitUrl:self.url];
    config.enableSDKDebugLog = YES;
    [FTSDKAgent startWithConfigOptions:config];
    FTRumConfig *rumConfig = [[FTRumConfig alloc]initWithAppid:self.appid];
    rumConfig.errorMonitorType = FTErrorMonitorAll;
    rumConfig.enableTraceUserView = YES;
    rumConfig.enableTraceUserAction = YES;
    rumConfig.deviceMetricsMonitorType = FTDeviceMetricsMonitorAll;
    rumConfig.monitorFrequency = FTMonitorFrequencyFrequent;
    [[FTSDKAgent sharedInstance] startRumWithConfigOptions:rumConfig];
    [[FTTrackerEventDBTool sharedManger] deleteItemWithTm:[FTDateUtil currentTimeNanosecond]];
}
- (void)check{
    
}

@end
