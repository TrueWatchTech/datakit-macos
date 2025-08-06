//
//  FTTraceTests.m
//  FTMacOSSDKTests
//
//  Created by hulilei on 2023/4/18.
//

#import <XCTest/XCTest.h>
#import "FTDateUtil.h"
#import "FTRecordModel.h"
#import "FTTrackDataManager.h"
#import "FTTrackerEventDBTool.h"
#import "FTConstants.h"
#import "FTMacOSSDK.h"
#import "FTSDKAgent+Private.h"
@interface FTTraceTests : XCTestCase
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *traceUrl;
@end

@implementation FTTraceTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    NSProcessInfo *processInfo = [NSProcessInfo processInfo];
    self.url = [processInfo environment][@"ACCESS_SERVER_URL"];
    self.traceUrl = [processInfo environment][@"TRACE_URL"];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}
- (void)testTraceHeader{
    FTSDKConfig *config = [[FTSDKConfig alloc]initWithDatakitUrl:self.url];
    config.enableSDKDebugLog = YES;
    [FTSDKAgent startWithConfigOptions:config];
    FTTraceConfig *trace = [[FTTraceConfig alloc]init];
    trace.networkTraceType = FTNetworkTraceTypeJaeger;
    [[FTSDKAgent sharedInstance] startTraceWithConfigOptions:trace];
    NSString *uuidStr = [[NSUUID UUID] UUIDString];
    NSDictionary *traceHeader = [[FTTraceManager sharedInstance] getTraceHeaderWithKey:uuidStr url:[NSURL URLWithString:self.traceUrl]];
    XCTestExpectation *expectation= [self expectationWithDescription:@"Asynchronous operation timeout"];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.traceUrl]];
    if(traceHeader){
        [traceHeader enumerateKeysAndObjectsUsingBlock:^(id field, id value, BOOL * __unused stop) {
            [request setValue:value forHTTPHeaderField:field];
        }];
    }
    __block NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *header = task.currentRequest.allHTTPHeaderFields;
        NSString *traceStr =header[FT_NETWORK_JAEGER_TRACEID];
        NSArray *traceAry = [traceStr componentsSeparatedByString:@":"];
        NSString *trace = [traceAry firstObject];
        NSString *span =traceAry[1];
        NSString *sampled = [traceAry lastObject];
        XCTAssertTrue(trace.length == 32 && span.length == 16);
        XCTAssertTrue([trace.lowercaseString isEqualToString:trace] && [span.lowercaseString isEqualToString:span]);
        XCTAssertEqualObjects(sampled, @"1");
        [expectation fulfill];
    }];
    [task resume];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
    [[FTSDKAgent sharedInstance] shutDown];
}
- (void)testNoConfigTraceHeader{
    FTSDKConfig *config = [[FTSDKConfig alloc]initWithDatakitUrl:self.url];
    config.enableSDKDebugLog = YES;
    [FTSDKAgent startWithConfigOptions:config];
    NSString *uuidStr = [[NSUUID UUID] UUIDString];
    NSDictionary *traceHeader = [[FTTraceManager sharedInstance] getTraceHeaderWithKey:uuidStr url:[NSURL URLWithString:self.traceUrl]];
    XCTAssertTrue(traceHeader == nil);
    [[FTSDKAgent sharedInstance] shutDown];
}


@end
