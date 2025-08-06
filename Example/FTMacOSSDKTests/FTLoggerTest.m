//
//  FTLoggerTest.m
//  FTMacOSSDKTests
//
//  Created by hulilei on 2023/4/11.
//

#import <XCTest/XCTest.h>
#import "FTTestHelper.h"
#import "FTSDKAgent+Private.h"
#import "FTMacOSSDK.h"
#import "FTConstants.h"
#import "FTTrackerEventDBTool.h"
#import "FTTrackDataManager.h"
#import "FTRUMManager.h"
#import "FTRecordModel.h"
#import "FTDateUtil.h"
#import "FTJSONUtil.h"
@interface FTLoggerTest : FTTestHelper
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *appid;

@end

@implementation FTLoggerTest

- (void)setUp {
    NSProcessInfo *processInfo = [NSProcessInfo processInfo];
    self.url = [processInfo environment][@"ACCESS_SERVER_URL"];
    self.appid = [processInfo environment][@"APP_ID"];
    [[FTTrackerEventDBTool sharedManger] deleteItemWithTm:[FTDateUtil currentTimeNanosecond]];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [[FTTrackerEventDBTool sharedManger]insertCacheToDB];
    [[FTSDKAgent sharedInstance] shutDown];
}
- (void)testEnableCustomLog{
    [self setRightSDKConfig];
    NSInteger count =  [[FTTrackerEventDBTool sharedManger] getDatasCount];
    FTLoggerConfig *loggerConfig = [[FTLoggerConfig alloc]init];
    loggerConfig.enableCustomLog = YES;
    [[FTSDKAgent sharedInstance] startLoggerWithConfigOptions:loggerConfig];
    [[FTSDKAgent sharedInstance] logging:@"testLoggingMethod" status:FTStatusInfo];
    [[FTSDKAgent sharedInstance] syncProcess];
    NSInteger newCount =  [[FTTrackerEventDBTool sharedManger] getDatasCount];
    XCTAssertTrue(newCount=count+1);
}
- (void)testDisbleCustomLog{
    [self setRightSDKConfig];
    NSInteger count =  [[FTTrackerEventDBTool sharedManger] getDatasCount];
    FTLoggerConfig *loggerConfig = [[FTLoggerConfig alloc]init];
    loggerConfig.enableCustomLog = NO;
    [[FTSDKAgent sharedInstance] startLoggerWithConfigOptions:loggerConfig];
    [[FTSDKAgent sharedInstance] logging:@"testLoggingMethod" status:FTStatusInfo];
    [[FTSDKAgent sharedInstance] syncProcess];
    NSInteger newCount =  [[FTTrackerEventDBTool sharedManger] getDatasCount];
    XCTAssertTrue(newCount == count);
}
- (void)testDiscardNew{
    [self setRightSDKConfig];
    FTLoggerConfig *loggerConfig = [[FTLoggerConfig alloc]init];
    loggerConfig.discardType = FTDiscard;
    [[FTSDKAgent sharedInstance] startLoggerWithConfigOptions:loggerConfig];
    for (int i = 0; i<5030; i++) {
        FTRecordModel *model = [FTRecordModel new];
        model.op = FT_DATA_TYPE_LOGGING;
        model.data = [NSString stringWithFormat:@"testData%d",i];
        [[FTTrackDataManager sharedInstance] addTrackData:model type:FTAddDataLogging];

    }
    NSInteger newCount =  [[FTTrackerEventDBTool sharedManger] getDatasCountWithType:FT_DATA_TYPE_LOGGING];
    FTRecordModel *model = [[[FTTrackerEventDBTool sharedManger] getFirstRecords:1 withType:FT_DATA_TYPE_LOGGING] firstObject];
    XCTAssertTrue([model.data isEqualToString:@"testData0"]);

    XCTAssertTrue(newCount == 5000);
}

- (void)testDiscardOldBulk{
    [self setRightSDKConfig];
    FTLoggerConfig *loggerConfig = [[FTLoggerConfig alloc]init];
    loggerConfig.discardType = FTDiscardOldest;
    [[FTSDKAgent sharedInstance] startLoggerWithConfigOptions:loggerConfig];

    for (int i = 0; i<5045; i++) {
        FTRecordModel *model = [FTRecordModel new];
        model.op = FT_DATA_TYPE_LOGGING;
        model.data = [NSString stringWithFormat:@"testData%d",i];
        [[FTTrackDataManager sharedInstance] addTrackData:model type:FTAddDataLogging];

    }
    NSInteger newCount =  [[FTTrackerEventDBTool sharedManger] getDatasCountWithType:FT_DATA_TYPE_LOGGING];
    FTRecordModel *model = [[[FTTrackerEventDBTool sharedManger] getFirstRecords:1 withType:FT_DATA_TYPE_LOGGING] firstObject];
    XCTAssertFalse([model.data isEqualToString:@"testData0"]);
    XCTAssertTrue(newCount == 5000);
}
- (void)testLogLevelFilter{
    [self setRightSDKConfig];
    NSInteger count =  [[FTTrackerEventDBTool sharedManger] getDatasCount];
    FTLoggerConfig *loggerConfig = [[FTLoggerConfig alloc]init];
    loggerConfig.enableCustomLog = YES;
    loggerConfig.logLevelFilter = @[@(FTStatusInfo)];
    [[FTSDKAgent sharedInstance] startLoggerWithConfigOptions:loggerConfig];
    
    [[FTSDKAgent sharedInstance] logging:@"testLoggingMethod" status:FTStatusInfo];
    [[FTSDKAgent sharedInstance] syncProcess];
    [[FTTrackerEventDBTool sharedManger]insertCacheToDB];
    NSInteger newCount =  [[FTTrackerEventDBTool sharedManger] getDatasCount];
    XCTAssertTrue(newCount>count);
    [[FTSDKAgent sharedInstance] logging:@"testLoggingMethodError" status:FTStatusError];
    [[FTSDKAgent sharedInstance] syncProcess];
    [[FTTrackerEventDBTool sharedManger]insertCacheToDB];
    NSInteger newCount2 =  [[FTTrackerEventDBTool sharedManger] getDatasCount];
    XCTAssertTrue(newCount2 == newCount);

}
- (void)testEmptyStringMessageLog{
    [self setRightSDKConfig];
    NSInteger count =  [[FTTrackerEventDBTool sharedManger] getDatasCount];
    FTLoggerConfig *loggerConfig = [[FTLoggerConfig alloc]init];
    loggerConfig.enableCustomLog = YES;
    [[FTSDKAgent sharedInstance] startLoggerWithConfigOptions:loggerConfig];
    [[FTSDKAgent sharedInstance] logging:@"" status:FTStatusInfo];
    [[FTSDKAgent sharedInstance] syncProcess];
    [[FTTrackerEventDBTool sharedManger]insertCacheToDB];
    NSInteger newCount =  [[FTTrackerEventDBTool sharedManger] getDatasCount];
    XCTAssertTrue(newCount == count);
}
- (void)testNotSetLoggerConfig{
    [self setRightSDKConfig];
    NSInteger count =  [[FTTrackerEventDBTool sharedManger] getDatasCount];
    [[FTSDKAgent sharedInstance] logging:@"testNotSetLoggerConfig" status:FTStatusInfo];
    [[FTSDKAgent sharedInstance] syncProcess];
    [[FTTrackerEventDBTool sharedManger]insertCacheToDB];
    NSInteger newCount =  [[FTTrackerEventDBTool sharedManger] getDatasCount];
    XCTAssertTrue(newCount == count);
}
- (void)setRightSDKConfig{
    FTSDKConfig *config = [[FTSDKConfig alloc]initWithDatakitUrl:self.url];
    config.enableSDKDebugLog = YES;
    [FTSDKAgent startWithConfigOptions:config];
    [[FTSDKAgent sharedInstance] unbindUser];
    [[FTTrackerEventDBTool sharedManger] deleteItemWithTm:[FTDateUtil currentTimeNanosecond]];
}
-(void)testSetEmptyLoggerServiceName{
    [self setRightSDKConfig];
    FTSDKConfig *config = [[FTSDKConfig alloc]initWithDatakitUrl:self.url];
    FTLoggerConfig *loggerConfig = [[FTLoggerConfig alloc]init];
    loggerConfig.enableCustomLog = YES;
    [FTSDKAgent startWithConfigOptions:config];
    [[FTSDKAgent sharedInstance] startLoggerWithConfigOptions:loggerConfig];
    [[FTSDKAgent sharedInstance] logging:@"testSetEmptyServiceName" status:FTStatusInfo];
    [[FTSDKAgent sharedInstance] syncProcess];
    [[FTTrackerEventDBTool sharedManger]insertCacheToDB];
    NSArray *array = [[FTTrackerEventDBTool sharedManger] getFirstRecords:10 withType:FT_DATA_TYPE_LOGGING];
    FTRecordModel *model = [array lastObject];
    NSDictionary *dict = [FTJSONUtil dictionaryWithJsonString:model.data];
    NSDictionary *op = dict[@"opdata"];
    NSDictionary *tags = op[FT_TAGS];
    NSString *serviceName = [tags valueForKey:FT_KEY_SERVICE];
    XCTAssertTrue(serviceName.length>0);
}
- (void)testEnableLinkRumData{
    [self setRightSDKConfig];
    FTLoggerConfig *loggerConfig = [[FTLoggerConfig alloc]init];
    loggerConfig.enableLinkRumData = YES;
    loggerConfig.enableCustomLog = YES;
    FTRumConfig *rumConfig = [[FTRumConfig alloc]initWithAppid:self.appid];
    rumConfig.enableTraceUserView = YES;
    [[FTSDKAgent sharedInstance] startLoggerWithConfigOptions:loggerConfig];
    [[FTSDKAgent sharedInstance] startRumWithConfigOptions:rumConfig];
    [[FTGlobalRumManager sharedManager] startViewWithName:@"TestLoggerLinkRumData"];
    [[FTGlobalRumManager sharedManager] addActionName:@"EnableLinkRumDataClick" actionType:@"click"];
    [[FTSDKAgent sharedInstance] logging:@"testEnableLinkRumData" status:FTStatusInfo];

    [[FTSDKAgent sharedInstance] syncProcess];
    [[FTTrackerEventDBTool sharedManger]insertCacheToDB];
    NSArray *datas = [[FTTrackerEventDBTool sharedManger] getFirstRecords:10 withType:FT_DATA_TYPE_LOGGING];
    FTRecordModel *model = [datas lastObject];
    NSDictionary *dict = [FTJSONUtil dictionaryWithJsonString:model.data];
    NSDictionary *opdata = dict[@"opdata"];
    NSDictionary *tags =opdata[FT_TAGS];
    XCTAssertTrue([tags.allKeys containsObject:FT_RUM_KEY_SESSION_ID]);
    XCTAssertTrue([tags.allKeys containsObject:FT_RUM_KEY_SESSION_TYPE]);
}
- (void)testDisableLinkRumData{
    [self setRightSDKConfig];
    FTLoggerConfig *loggerConfig = [[FTLoggerConfig alloc]init];
    loggerConfig.enableLinkRumData = NO;
    loggerConfig.enableCustomLog = YES;
    FTRumConfig *rumConfig = [[FTRumConfig alloc]initWithAppid:self.appid];
    [[FTSDKAgent sharedInstance] startLoggerWithConfigOptions:loggerConfig];
    [[FTSDKAgent sharedInstance] startRumWithConfigOptions:rumConfig];
   
    [[FTSDKAgent sharedInstance] logging:@"testEnableLinkRumData" status:FTStatusInfo];

    [[FTSDKAgent sharedInstance] syncProcess];
    NSArray *datas = [[FTTrackerEventDBTool sharedManger] getFirstRecords:10 withType:FT_DATA_TYPE_LOGGING];
    FTRecordModel *model = [datas lastObject];
    NSDictionary *dict = [FTJSONUtil dictionaryWithJsonString:model.data];
    NSDictionary *opdata = dict[@"opdata"];
    NSDictionary *tags =opdata[FT_TAGS];
    XCTAssertFalse([tags.allKeys containsObject:FT_RUM_KEY_SESSION_ID]);
    XCTAssertFalse([tags.allKeys containsObject:FT_RUM_KEY_SESSION_TYPE]);

}
- (void)testSampleRate0{
    [self setRightSDKConfig];
    FTLoggerConfig *loggerConfig = [[FTLoggerConfig alloc]init];
    loggerConfig.sampleRate = 0;
    loggerConfig.enableCustomLog = YES;
    [[FTSDKAgent sharedInstance] startLoggerWithConfigOptions:loggerConfig];
    NSArray *oldDatas = [[FTTrackerEventDBTool sharedManger] getFirstRecords:10 withType:FT_DATA_TYPE_LOGGING];

    [[FTSDKAgent sharedInstance] logging:@"testSampleRate0" status:FTStatusInfo];
    NSLog(@"testSampleRate0");
    [[FTSDKAgent sharedInstance] syncProcess];
    NSArray *newDatas = [[FTTrackerEventDBTool sharedManger] getFirstRecords:10 withType:FT_DATA_TYPE_LOGGING];

    XCTAssertTrue(oldDatas.count == newDatas.count);
}
- (void)testSampleRate100{
    [self setRightSDKConfig];
    FTLoggerConfig *loggerConfig = [[FTLoggerConfig alloc]init];
    loggerConfig.enableCustomLog = YES;
    [[FTSDKAgent sharedInstance] startLoggerWithConfigOptions:loggerConfig];
    NSArray *oldDatas = [[FTTrackerEventDBTool sharedManger] getFirstRecords:10 withType:FT_DATA_TYPE_LOGGING];
    [[FTSDKAgent sharedInstance] logging:@"testSampleRate0" status:FTStatusInfo];
    [[FTSDKAgent sharedInstance] syncProcess];
    [[FTTrackerEventDBTool sharedManger]insertCacheToDB];
    NSArray *newDatas = [[FTTrackerEventDBTool sharedManger] getFirstRecords:10 withType:FT_DATA_TYPE_LOGGING];
    XCTAssertTrue(oldDatas.count+1 == newDatas.count);

}
- (void)testGlobalContext{
    [self setRightSDKConfig];
    FTLoggerConfig *loggerConfig = [[FTLoggerConfig alloc]init];
    loggerConfig.enableCustomLog = YES;
    loggerConfig.globalContext = @{@"logger_id":@"logger_id_1"};
    [[FTSDKAgent sharedInstance] startLoggerWithConfigOptions:loggerConfig];
    [[FTSDKAgent sharedInstance] logging:@"testGlobalContext" status:FTStatusInfo];
    [[FTSDKAgent sharedInstance] syncProcess];
    [[FTTrackerEventDBTool sharedManger]insertCacheToDB];
    NSArray *newDatas = [[FTTrackerEventDBTool sharedManger] getFirstRecords:10 withType:FT_DATA_TYPE_LOGGING];
    FTRecordModel *model = [newDatas lastObject];
    NSDictionary *dict = [FTJSONUtil dictionaryWithJsonString:model.data];
    NSDictionary *op = dict[@"opdata"];
    NSDictionary *tags = op[FT_TAGS];
    XCTAssertTrue([tags[@"logger_id"] isEqualToString:@"logger_id_1"]);

}
- (void)testLoggerProperty{
    [self setRightSDKConfig];
    FTLoggerConfig *loggerConfig = [[FTLoggerConfig alloc]init];
    loggerConfig.enableCustomLog = YES;
    [[FTSDKAgent sharedInstance] startLoggerWithConfigOptions:loggerConfig];
    [[FTSDKAgent sharedInstance] logging:@"testLoggerProperty" status:FTStatusInfo property:@{@"logger_property":@"testLoggerProperty"}];
    [[FTSDKAgent sharedInstance] syncProcess];
    [[FTTrackerEventDBTool sharedManger]insertCacheToDB];
    NSArray *newDatas = [[FTTrackerEventDBTool sharedManger] getFirstRecords:10 withType:FT_DATA_TYPE_LOGGING];
    FTRecordModel *model = [newDatas lastObject];
    NSDictionary *dict = [FTJSONUtil dictionaryWithJsonString:model.data];
    NSDictionary *op = dict[@"opdata"];
    NSDictionary *fields = op[FT_FIELDS];
    XCTAssertTrue([fields[@"logger_property"] isEqualToString:@"testLoggerProperty"]);
}


@end
