//
//  FTRUMTests.m
//  ExampleTests
//
//  Created by hulilei on 2023/4/11.
//

#import <XCTest/XCTest.h>
#import "FTSDKAgent+Private.h"
#import "FTMacOSSDK.h"
#import "FTConstants.h"
#import "FTTrackerEventDBTool.h"
#import "FTRUMManager.h"
#import "FTGlobalRumManager+Private.h"
#import "FTTrackerEventDBTool.h"
#import "FTDateUtil.h"
#import "FTRecordModel.h"
#import "FTJSONUtil.h"
#import "FTResourceContentModel.h"
#import "FTResourceMetricsModel.h"
#import "TestRumWebView.h"
#import "FTMacOSSDKVersion.h"
#import "FTTestHelper.h"
@interface FTRUMTests : XCTestCase<WKNavigationDelegate>
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *traceUrl;
@property (nonatomic, copy) NSString *appid;
@property (nonatomic, strong) XCTestExpectation *loadExpect;
@property (nonatomic, strong) TestRumWebView *testWebView;
@end

@implementation FTRUMTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    NSProcessInfo *processInfo = [NSProcessInfo processInfo];
    self.url = [processInfo environment][@"ACCESS_SERVER_URL"];
    self.traceUrl = [processInfo environment][@"TRACE_URL"];
    self.appid = [processInfo environment][@"APP_ID"];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}
- (void)setRumConfig{
    FTSDKConfig *config = [[FTSDKConfig alloc]initWithDatakitUrl:self.url];
    [FTSDKAgent startWithConfigOptions:config];
    FTRumConfig *rumConfig = [[FTRumConfig alloc]initWithAppid:self.appid];
    rumConfig.errorMonitorType = FTErrorMonitorAll;
    rumConfig.enableTraceUserResource = YES;
    rumConfig.deviceMetricsMonitorType = FTDeviceMetricsMonitorAll;
    rumConfig.monitorFrequency = FTMonitorFrequencyFrequent;
    [[FTSDKAgent sharedInstance] startRumWithConfigOptions:rumConfig];
    [[FTTrackerEventDBTool sharedManger] deleteItemWithTm:[FTDateUtil currentTimeNanosecond]];
}
- (void)testSamplerate0{
    FTSDKConfig *config = [[FTSDKConfig alloc]initWithDatakitUrl:self.url];
    FTRumConfig *rumConfig = [[FTRumConfig alloc]initWithAppid:self.appid];
    rumConfig.sampleRate = 0;
    [FTSDKAgent startWithConfigOptions:config];
    [[FTSDKAgent sharedInstance] startRumWithConfigOptions:rumConfig];
    
    NSArray *oldArray = [[FTTrackerEventDBTool sharedManger] getFirstRecords:100 withType:FT_DATA_TYPE_RUM];
    [[FTGlobalRumManager sharedManager] startViewWithName:@"TestSamplerate0"];
    [[FTGlobalRumManager sharedManager] addActionName:@"TestSamplerate0Click" actionType:@"click"];
    [[FTGlobalRumManager sharedManager] addActionName:@"TestSamplerate0Click" actionType:@"click"];
    [[FTGlobalRumManager sharedManager].rumManager syncProcess];
    NSArray *newArray = [[FTTrackerEventDBTool sharedManger] getFirstRecords:100 withType:FT_DATA_TYPE_RUM];
    XCTAssertTrue(newArray.count == oldArray.count);
    
    [[FTSDKAgent sharedInstance] shutDown];
}
- (void)testSamplerate100{
    FTSDKConfig *config = [[FTSDKConfig alloc]initWithDatakitUrl:self.url];
    FTRumConfig *rumConfig = [[FTRumConfig alloc]initWithAppid:self.appid];
    rumConfig.sampleRate = 100;
    [FTSDKAgent startWithConfigOptions:config];
    [[FTSDKAgent sharedInstance] startRumWithConfigOptions:rumConfig];
    NSArray *oldArray = [[FTTrackerEventDBTool sharedManger] getFirstRecords:100 withType:FT_DATA_TYPE_RUM];
    [[FTGlobalRumManager sharedManager] startViewWithName:@"TestSamplerate0"];
    [[FTGlobalRumManager sharedManager] addActionName:@"TestSamplerate0Click" actionType:@"click"];
    [[FTGlobalRumManager sharedManager] addActionName:@"TestSamplerate0Click" actionType:@"click"];
    [[FTGlobalRumManager sharedManager].rumManager syncProcess];
    NSArray *newArray = [[FTTrackerEventDBTool sharedManger] getFirstRecords:100 withType:FT_DATA_TYPE_RUM];
    XCTAssertTrue(newArray.count > oldArray.count);
    [[FTSDKAgent sharedInstance] shutDown];
}
- (void)testAddViewEvent{
    [self addViewEventProperty:nil stopProperty:nil];
}
- (void)testAddViewWithProperty{
    [self addViewEventProperty:@{@"ft_start_view":@"test_value"} stopProperty:@{@"ft_stop_view":@"test_value"}];
}
- (void)addViewEventProperty:(NSDictionary *)start stopProperty:(NSDictionary *)stop {
    [self setRumConfig];
    if(start){
        [[FTGlobalRumManager sharedManager] startViewWithName:@"TestAddViewEvent" property:start];
    }else{
        [[FTGlobalRumManager sharedManager] startViewWithName:@"TestAddViewEvent"];
    }
    if(stop){
        [[FTGlobalRumManager sharedManager] stopViewWithProperty:stop];
    }else{
        [[FTGlobalRumManager sharedManager] stopView];
    }
    [[FTGlobalRumManager sharedManager] startViewWithName:@"TestAddViewEvent2"];
    [[FTGlobalRumManager sharedManager].rumManager syncProcess];
    NSArray *newArray = [[FTTrackerEventDBTool sharedManger] getFirstRecords:100 withType:FT_DATA_TYPE_RUM];
    XCTAssertTrue(newArray.count>0);
    BOOL hasViewData = NO,hasStart = NO,hasStop = NO;
    for (FTRecordModel *model in newArray) {
        NSDictionary *dict = [FTJSONUtil dictionaryWithJsonString:model.data];
        if([dict[FT_OP] isEqualToString:FT_DATA_TYPE_RUM]){
            NSDictionary *data = dict[FT_OPDATA];
            if([data[FT_KEY_SOURCE] isEqualToString:FT_RUM_SOURCE_VIEW]){
                NSDictionary *tags = data[FT_TAGS];
                NSString *viewName = tags[FT_KEY_VIEW_NAME];
                if([viewName isEqualToString:@"TestAddViewEvent"]){
                    NSDictionary *fields = data[FT_FIELDS];
                    if(start){
                        if([fields[start.allKeys.firstObject] isEqualToString:start[start.allKeys.firstObject]]){
                            hasStart = YES;
                        }
                    }
                    if(stop){
                        if([fields[stop.allKeys.firstObject] isEqualToString:stop[stop.allKeys.firstObject]]){
                            hasStop = YES;
                        }
                    }
                    hasViewData = YES;
                }
            }
        }
    }
    XCTAssertTrue(hasViewData == YES);
    if(start){
        XCTAssertTrue(hasStart == YES);
    }
    if(stop){
        XCTAssertTrue(hasStop == YES);
    }
    [[FTSDKAgent sharedInstance] shutDown];
    
}
- (void)testAddActionEvent{
    [self addActionWithProperty:nil];
}
- (void)testAddActionProperty{
    [self addActionWithProperty:@{@"ft_action_property":@"ft_value"}];
}
- (void)addActionWithProperty:(NSDictionary *)property{
    [self setRumConfig];
    [[FTGlobalRumManager sharedManager] startViewWithName:@"TestAddActionEvent"];
    if(property){
        [[FTGlobalRumManager sharedManager] addActionName:@"addAction" actionType:@"click" property:property];
        [[FTGlobalRumManager sharedManager] addActionName:@"addAction2" actionType:@"click" property:property];
    }else{
        [[FTGlobalRumManager sharedManager] addActionName:@"addAction" actionType:@"click"];
        [[FTGlobalRumManager sharedManager] addActionName:@"addAction2" actionType:@"click"];
    }

    [[FTGlobalRumManager sharedManager].rumManager syncProcess];
    NSArray *newArray = [[FTTrackerEventDBTool sharedManger] getFirstRecords:100 withType:FT_DATA_TYPE_RUM];
    XCTAssertTrue(newArray.count>0);
    BOOL hasAction = NO;
    for (FTRecordModel *model in newArray) {
       NSDictionary *dict = [FTJSONUtil dictionaryWithJsonString:model.data];
        if([dict[FT_OP] isEqualToString:FT_DATA_TYPE_RUM]){
            NSDictionary *data = dict[FT_OPDATA];
            if([data[FT_KEY_SOURCE] isEqualToString:FT_RUM_SOURCE_ACTION]){
                NSDictionary *tags = data[FT_TAGS];
                NSString *actionName = tags[FT_KEY_ACTION_NAME];
                if([actionName isEqualToString:@"addAction"]){
                    if(property){
                        NSDictionary *field = data[FT_FIELDS];
                        XCTAssertTrue([field[property.allKeys.firstObject] isEqualToString:property[property.allKeys.firstObject]]);
                    }
                    hasAction = YES;
                    break;
                }
            }
        }
    }
    XCTAssertTrue(hasAction == YES);
    [[FTSDKAgent sharedInstance] shutDown];
}
- (void)testAddResourceEvent{
    [self addResource:nil end:nil];
}
- (void)testAddResourceWithProperty{
    [self addResource:@{@"ft_start_resource":@"ft_value"} end:@{@"ft_end_resource":@"ft_value"}];
}
- (void)addResource:(NSDictionary *)start end:(NSDictionary *)end{
    [self setRumConfig];
    [[FTGlobalRumManager sharedManager] startViewWithName:@"TestRumView"];
    [self addResource:start endContext:end];
    [[FTGlobalRumManager sharedManager].rumManager syncProcess];
    NSArray *newArray = [[FTTrackerEventDBTool sharedManger] getFirstRecords:100 withType:FT_DATA_TYPE_RUM];
    XCTAssertTrue(newArray.count>0);
    BOOL hasResource = NO;
    for (FTRecordModel *model in newArray) {
       NSDictionary *dict = [FTJSONUtil dictionaryWithJsonString:model.data];
        if([dict[FT_OP] isEqualToString:FT_DATA_TYPE_RUM]){
            NSDictionary *data = dict[FT_OPDATA];
            if([data[FT_KEY_SOURCE] isEqualToString:FT_RUM_SOURCE_RESOURCE]){
                if(start){
                    NSDictionary *field = data[FT_FIELDS];
                    XCTAssertTrue([field[start.allKeys.firstObject] isEqualToString:start[start.allKeys.firstObject]]);
                    XCTAssertTrue([field[end.allKeys.firstObject] isEqualToString:end[end.allKeys.firstObject]]);

                }
                hasResource = YES;
                break;
            }
        }
    }
    XCTAssertTrue(hasResource == YES);
    [[FTSDKAgent sharedInstance] shutDown];
}
- (void)testAddErrorEvent{
    [self addErrorWithProperty:nil];
}
- (void)testAddErrorProperty{
    [self addErrorWithProperty:@{@"ft_error":@"ft_value"}];
}
- (void)addErrorWithProperty:(NSDictionary *)property{
    [self setRumConfig];
    [[FTGlobalRumManager sharedManager] addErrorWithType:@"macOS" message:@"error_message" stack:@"error_stack" property:property];
    [[FTGlobalRumManager sharedManager].rumManager syncProcess];
    NSArray *newArray = [[FTTrackerEventDBTool sharedManger] getFirstRecords:100 withType:FT_DATA_TYPE_RUM];
    XCTAssertTrue(newArray.count>0);
    BOOL hasError = NO;
    for (FTRecordModel *model in newArray) {
       NSDictionary *dict = [FTJSONUtil dictionaryWithJsonString:model.data];
        if([dict[FT_OP] isEqualToString:FT_DATA_TYPE_RUM]){
            NSDictionary *data = dict[FT_OPDATA];
            if([data[FT_KEY_SOURCE] isEqualToString:FT_RUM_SOURCE_ERROR]){
                NSDictionary *fields = data[FT_FIELDS];
                NSString *message = fields[FT_KEY_ERROR_MESSAGE];
                if(property){
                    XCTAssertTrue([fields[property.allKeys.firstObject] isEqualToString:property[property.allKeys.firstObject]]);
                }
                XCTAssertTrue([message isEqualToString:@"error_message"]);
                hasError = YES;
                break;
            }
        }
    }
    XCTAssertTrue(hasError == YES);
    [[FTSDKAgent sharedInstance] shutDown];
}
- (void)testErrorMonitor{
    [self setRumConfig];
    [[FTGlobalRumManager sharedManager] addErrorWithType:@"macOS" message:@"error_message" stack:@"error_stack"];
    [[FTGlobalRumManager sharedManager].rumManager syncProcess];
    NSArray *newArray = [[FTTrackerEventDBTool sharedManger] getFirstRecords:100 withType:FT_DATA_TYPE_RUM];
    XCTAssertTrue(newArray.count>0);
    BOOL hasError = NO;
    for (FTRecordModel *model in newArray) {
       NSDictionary *dict = [FTJSONUtil dictionaryWithJsonString:model.data];
        if([dict[FT_OP] isEqualToString:FT_DATA_TYPE_RUM]){
            NSDictionary *data = dict[FT_OPDATA];
            if([data[FT_KEY_SOURCE] isEqualToString:FT_RUM_SOURCE_ERROR]){
                NSDictionary *tags = data[FT_TAGS];
                XCTAssertTrue([tags.allKeys containsObject:FT_MEMORY_TOTAL]);
                XCTAssertTrue([tags.allKeys containsObject:FT_MEMORY_USE]);
                XCTAssertTrue([tags.allKeys containsObject:FT_CPU_USE]);
                XCTAssertTrue([tags.allKeys containsObject:FT_BATTERY_USE]);
                hasError = YES;
                break;
            }
        }
    }
    XCTAssertTrue(hasError == YES);
    [[FTSDKAgent sharedInstance] shutDown];
}
- (void)testAddLongTaskEvent{
    [self addLongTask:nil];
}
- (void)testAddLongTaskProperty{
    [self addLongTask:@{}];
}
- (void)addLongTask:(NSDictionary *)property{
    [self setRumConfig];
    if(property){
        [[FTGlobalRumManager sharedManager] addLongTaskWithStack:@"long_task_stack" duration:@5000000000 property:property];
    }else{
        [[FTGlobalRumManager sharedManager] addLongTaskWithStack:@"long_task_stack" duration:@5000000000];
    }
    [[FTGlobalRumManager sharedManager].rumManager syncProcess];
    NSArray *newArray = [[FTTrackerEventDBTool sharedManger] getFirstRecords:100 withType:FT_DATA_TYPE_RUM];
    XCTAssertTrue(newArray.count>0);
    BOOL hasLongTask = NO;
    for (FTRecordModel *model in newArray) {
       NSDictionary *dict = [FTJSONUtil dictionaryWithJsonString:model.data];
        if([dict[FT_OP] isEqualToString:FT_DATA_TYPE_RUM]){
            NSDictionary *data = dict[FT_OPDATA];
            if([data[FT_KEY_SOURCE] isEqualToString:FT_RUM_SOURCE_LONG_TASK]){
                NSDictionary *fields = data[FT_FIELDS];
                NSString *stack = fields[FT_KEY_LONG_TASK_STACK];
                XCTAssertTrue([stack isEqualToString:@"long_task_stack"]);
                hasLongTask = YES;
                break;
            }
        }
    }
    XCTAssertTrue(hasLongTask == YES);
    [[FTSDKAgent sharedInstance] shutDown];
}
- (void)testBindUser{
    [self setRumConfig];
    [[FTSDKAgent sharedInstance] bindUserWithUserID:@"id_12345" userName:@"name_1" userEmail:@"text@123.com" extra:@{@"user_age":@"12"}];
    [[FTGlobalRumManager sharedManager] addErrorWithType:@"macOS" message:@"error_message" stack:@"error_stack"];
    [[FTGlobalRumManager sharedManager].rumManager syncProcess];
    NSArray *newArray = [[FTTrackerEventDBTool sharedManger] getFirstRecords:100 withType:FT_DATA_TYPE_RUM];
    XCTAssertTrue(newArray.count>0);
    for (FTRecordModel *model in newArray) {
       NSDictionary *dict = [FTJSONUtil dictionaryWithJsonString:model.data];
        if([dict[FT_OP] isEqualToString:FT_DATA_TYPE_RUM]){
            NSDictionary *data = dict[FT_OPDATA];
            if([data[FT_KEY_SOURCE] isEqualToString:FT_RUM_SOURCE_ERROR]){
                NSDictionary *tags = data[FT_TAGS];
                XCTAssertTrue([tags[FT_USER_ID] isEqualToString:@"id_12345"]);
                XCTAssertTrue([tags[FT_USER_NAME] isEqualToString:@"name_1"]);
                XCTAssertTrue([tags[FT_USER_EMAIL] isEqualToString:@"text@123.com"]);
                XCTAssertTrue([tags[@"user_age"] isEqualToString:@"12"]);
            }
        }
    }
    [[FTSDKAgent sharedInstance] shutDown];
}
- (void)testRumDeviceMetricsMonitor{
    [self setRumConfig];
    [[FTGlobalRumManager sharedManager] startViewWithName:@"TestRumView"];
    XCTestExpectation *expectation= [self expectationWithDescription:@"Asynchronous operation timeout"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
    [NSThread sleepForTimeInterval:1];
    [[FTGlobalRumManager sharedManager] addErrorWithType:@"macOS" message:@"error_message" stack:@"error_stack"];
    [[FTGlobalRumManager sharedManager].rumManager syncProcess];
    NSArray *newArray = [[FTTrackerEventDBTool sharedManger] getFirstRecords:100 withType:FT_DATA_TYPE_RUM];
    XCTAssertTrue(newArray.count>0);
    [newArray enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(FTRecordModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
       NSDictionary *dict = [FTJSONUtil dictionaryWithJsonString:model.data];
        if([dict[FT_OP] isEqualToString:FT_DATA_TYPE_RUM]){
            NSDictionary *data = dict[FT_OPDATA];
            if([data[FT_KEY_SOURCE] isEqualToString:FT_RUM_SOURCE_VIEW]){
                NSDictionary *field = data[FT_FIELDS];
                XCTAssertTrue([field.allKeys containsObject:FT_CPU_TICK_COUNT]);
                XCTAssertTrue([field.allKeys containsObject:FT_CPU_TICK_COUNT_PER_SECOND]);
                XCTAssertTrue([field.allKeys containsObject:FT_MEMORY_AVG]);
                XCTAssertTrue([field.allKeys containsObject:FT_MEMORY_MAX]);
                XCTAssertTrue([field.allKeys containsObject:FT_MEMORY_MAX]);
                *stop = YES;
            }
        }
    }];
    [[FTSDKAgent sharedInstance] shutDown];
}
- (void)testUnbindUser{
    [self setRumConfig];
    [[FTSDKAgent sharedInstance] bindUserWithUserID:@"id_12345"];
    [[FTGlobalRumManager sharedManager] addErrorWithType:@"macOS" message:@"error_message" stack:@"error_stack"];
    [[FTGlobalRumManager sharedManager].rumManager syncProcess];
    NSArray *newArray = [[FTTrackerEventDBTool sharedManger] getFirstRecords:100 withType:FT_DATA_TYPE_RUM];
    XCTAssertTrue(newArray.count>0);
    FTRecordModel *model = [newArray lastObject];
        NSDictionary *dict = [FTJSONUtil dictionaryWithJsonString:model.data];
    if([dict[FT_OP] isEqualToString:FT_DATA_TYPE_RUM]){
        NSDictionary *data = dict[FT_OPDATA];
        NSDictionary *tags = data[FT_TAGS];
        XCTAssertTrue([tags[FT_USER_ID] isEqualToString:@"id_12345"]);
        XCTAssertFalse([tags[FT_USER_NAME] isEqualToString:@"name_1"]);
        XCTAssertFalse([tags[FT_USER_EMAIL] isEqualToString:@"text@123.com"]);
        XCTAssertFalse([tags[@"user_age"] isEqualToString:@"12"]);
    }
    [[FTSDKAgent sharedInstance] unbindUser];
    [[FTTrackerEventDBTool sharedManger] deleteItemWithTm:[FTDateUtil currentTimeNanosecond]];
    [[FTGlobalRumManager sharedManager] addErrorWithType:@"macOS" message:@"error_message" stack:@"error_stack"];
    [[FTGlobalRumManager sharedManager].rumManager syncProcess];
    NSArray *datas = [[FTTrackerEventDBTool sharedManger] getFirstRecords:100 withType:FT_DATA_TYPE_RUM];
    XCTAssertTrue(datas.count>0);
    for (FTRecordModel *model in datas) {
        NSDictionary *dict = [FTJSONUtil dictionaryWithJsonString:model.data];
        if([dict[FT_OP] isEqualToString:FT_DATA_TYPE_RUM]){
            NSDictionary *data = dict[FT_OPDATA];
            NSDictionary *tags = data[FT_TAGS];
            XCTAssertFalse([tags[FT_USER_ID] isEqualToString:@"id_12345"]);
            XCTAssertFalse([tags[FT_USER_NAME] isEqualToString:@"name_1"]);
            XCTAssertFalse([tags[FT_USER_EMAIL] isEqualToString:@"text@123.com"]);
            XCTAssertFalse([tags[@"user_age"] isEqualToString:@"12"]);
        }
    }
    [[FTSDKAgent sharedInstance] shutDown];
}
- (void)testGlobalContext{
    FTSDKConfig *config = [[FTSDKConfig alloc]initWithDatakitUrl:self.url];
    config.globalContext = @{@"sdk_globalContext":@"test"};
    [FTSDKAgent startWithConfigOptions:config];
    FTRumConfig *rumConfig = [[FTRumConfig alloc]initWithAppid:self.appid];
    rumConfig.errorMonitorType = FTErrorMonitorAll;
    rumConfig.deviceMetricsMonitorType = FTDeviceMetricsMonitorAll;
    rumConfig.globalContext = @{@"rum_globalContext":@"test"};
    [[FTSDKAgent sharedInstance] startRumWithConfigOptions:rumConfig];
    [[FTTrackerEventDBTool sharedManger] deleteItemWithTm:[FTDateUtil currentTimeNanosecond]];
    [[FTGlobalRumManager sharedManager] addErrorWithType:@"macOS" message:@"error_message" stack:@"error_stack"];
    [[FTGlobalRumManager sharedManager].rumManager syncProcess];
    NSArray *newArray = [[FTTrackerEventDBTool sharedManger] getFirstRecords:100 withType:FT_DATA_TYPE_RUM];
    XCTAssertTrue(newArray.count>0);
    for (FTRecordModel *model in newArray) {
       NSDictionary *dict = [FTJSONUtil dictionaryWithJsonString:model.data];
        if([dict[FT_OP] isEqualToString:FT_DATA_TYPE_RUM]){
            NSDictionary *data = dict[FT_OPDATA];
            NSDictionary *tags = data[FT_TAGS];
            XCTAssertTrue([tags[@"rum_globalContext"] isEqualToString:@"test"]);
            XCTAssertTrue([tags[@"sdk_globalContext"] isEqualToString:@"test"]);
        }
    }
    [[FTSDKAgent sharedInstance] shutDown];
}
- (void)testIntakeUrl{
    [self setRumConfig];
    [[FTGlobalRumManager sharedManager] startViewWithName:@"Test"];
    [[FTSDKAgent sharedInstance] isIntakeUrl:^BOOL(NSURL * _Nonnull url) {
        if([url isEqual:[NSURL URLWithString:self.traceUrl]]){
            return YES;
        }
        return NO;
    }];
    NSUInteger oldCount = [[FTTrackerEventDBTool sharedManger] getDatasCount];

    XCTestExpectation *expectation= [self expectationWithDescription:@"Asynchronous operation timeout"];
    [self networkWithUrl:self.traceUrl handler:^(NSDictionary *header) {
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
    [[FTGlobalRumManager sharedManager].rumManager syncProcess];
    NSUInteger newCount = [[FTTrackerEventDBTool sharedManger] getDatasCount];
    XCTAssertTrue(newCount>oldCount);
    XCTestExpectation *expectation2= [self expectationWithDescription:@"Asynchronous operation timeout"];

    [self networkWithUrl:@"https://www.baidu.com/more/" handler:^(NSDictionary *header) {
        [expectation2 fulfill];
    }];
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
    [[FTGlobalRumManager sharedManager].rumManager syncProcess];
    NSUInteger newCount2 = [[FTTrackerEventDBTool sharedManger] getDatasCount];
    XCTAssertTrue(newCount2==newCount);
    
}
- (void)networkWithUrl:(NSString *)urlStr handler:(void (^)(NSDictionary *header))completionHandler{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
   __block NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *header = task.currentRequest.allHTTPHeaderFields;
        completionHandler?completionHandler(header):nil;
    }];
    [task resume];
}
- (void)addResource:(NSDictionary *)startContext endContext:(NSDictionary *)endContext{
    NSString *key = [[NSUUID UUID]UUIDString];
    NSURL *url = [NSURL URLWithString:@"https://www.baidu.com/more/"];
    NSDictionary *traceHeader = [[FTTraceManager sharedInstance] getTraceHeaderWithKey:key url:url];
    if(startContext){
        [[FTGlobalRumManager sharedManager] startResourceWithKey:key property:startContext];
    }else{
        [[FTGlobalRumManager sharedManager] startResourceWithKey:key];
    }
    FTResourceContentModel *model = [FTResourceContentModel new];
    model.url = url;
    model.httpStatusCode = 200;
    model.httpMethod = @"GET";
    model.requestHeader = traceHeader;
    model.responseHeader = @{ @"Accept-Ranges": @"bytes",
                              @"Cache-Control": @"max-age=86400",
                              @"Content-Encoding": @"gzip",
                              @"Connection":@"keep-alive",
                              @"Content-Length":@"11328",
                              @"Content-Type": @"text/html",
                              @"Server": @"Apache",
                              @"Vary": @"Accept-Encoding,User-Agent"
                              
    };
    if(endContext){
        [[FTGlobalRumManager sharedManager] stopResourceWithKey:key property:endContext];
    }else{
        [[FTGlobalRumManager sharedManager] stopResourceWithKey:key];
    }
    FTResourceMetricsModel *metrics = [FTResourceMetricsModel new];
    metrics.duration = @1000;
    metrics.resource_dns = @0;
    metrics.resource_ssl = @12;
    metrics.resource_tcp = @100;
    metrics.resource_ttfb = @101;
    metrics.resource_trans = @102;
    metrics.resource_first_byte = @103;
    [[FTGlobalRumManager sharedManager] addResourceWithKey:key metrics:metrics content:model];
}
/// 1.Verify webview incoming data addition
/// 2.Verify data format
///   Basic tags:
///    Consistent with webview:
///    sdk_name
///    sdk_version
///    service
///    New tag fields:
///    package_native
///    is_web_view
///   Rest consistent with native SDK
///
///   rum related adjustments:
///   session_id: consistent with native SDK
///   is_active: false
///   Rest consistent with webview
- (void)testAddWebRumViewData{
    [self setRumConfig];
    self.testWebView = [[TestRumWebView alloc]init];
    [self.testWebView view];
    [self.testWebView viewWillAppear];
    [self.testWebView viewDidLoad];
    self.testWebView.mWebView.navigationDelegate = self;
    self.loadExpect = [self expectationWithDescription:@"Request timeout!"];
    [self.testWebView test_loadUrl];
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
    XCTestExpectation *jsScript = [self expectationWithDescription:@"Request timeout!"];
    [self.testWebView test_addWebViewRumView:^{
        [jsScript fulfill];
    }];
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
    [[FTGlobalRumManager sharedManager].rumManager syncProcess];
    NSArray *datas =[[FTTrackerEventDBTool sharedManger] getFirstRecords:10 withType:FT_DATA_TYPE_RUM];
    __block BOOL hasViewData = NO;
    [datas enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(FTRecordModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *dict = [FTJSONUtil dictionaryWithJsonString:obj.data];
        NSString *op = dict[@"op"];
        XCTAssertTrue([op isEqualToString:@"RUM"]);
        NSDictionary *opdata = dict[FT_OPDATA];
        NSString *measurement = opdata[FT_KEY_SOURCE];
        NSDictionary *tags = opdata[FT_TAGS];
        if ([measurement isEqualToString:FT_RUM_SOURCE_VIEW]) {
            if(tags[FT_IS_WEBVIEW]){
                NSDictionary *field = opdata[FT_FIELDS];
                NSInteger errorCount = [field[FT_KEY_VIEW_ERROR_COUNT] integerValue];
                NSInteger resourceCount = [field[FT_KEY_VIEW_RESOURCE_COUNT] integerValue];
                NSInteger longTaskCount = [field[FT_KEY_VIEW_LONG_TASK_COUNT] integerValue];
                NSString *viewName = tags[FT_KEY_VIEW_NAME];
                NSDictionary *tags = opdata[FT_TAGS];
                XCTAssertTrue(errorCount == 0);
                XCTAssertTrue(longTaskCount == 0);
                XCTAssertTrue(resourceCount == 0);
                XCTAssertTrue([viewName isEqualToString:@"testJSBridge"]);

                // rum related adjustments
                XCTAssertFalse([tags[FT_RUM_KEY_SESSION_ID] isEqualToString:@"12345"]);
                XCTAssertTrue([field[FT_KEY_IS_ACTIVE] isEqualToString:@"false"]);

                // basic tags
                XCTAssertTrue([tags[@"package_native"] isEqualToString:SDK_VERSION]);
                XCTAssertFalse([tags[FT_SDK_VERSION] isEqualToString:SDK_VERSION]);
                XCTAssertTrue([tags[FT_SDK_NAME] isEqualToString:@"df_web_rum_sdk"]);
                XCTAssertTrue([tags[FT_KEY_SERVICE] isEqualToString:@"browser"]);

                hasViewData = YES;
            }
        }
    }];
    XCTAssertTrue(hasViewData);
}
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{
    [self.loadExpect fulfill];
    self.loadExpect = nil;
}
@end
