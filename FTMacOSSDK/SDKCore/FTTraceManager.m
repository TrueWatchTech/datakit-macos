//
//  FTTraceManager.m
//  FTMacOSSDK
//
//  Created by hulilei on 2023/4/4.
//

#import "FTTraceManager.h"
#import "FTURLSessionInstrumentation.h"
@implementation FTTraceManager
+ (instancetype)sharedInstance {
    static FTTraceManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[super allocWithZone:NULL] init];
    });
    return sharedInstance;
}
- (NSDictionary *)getTraceHeaderWithKey:(NSString *)key url:(NSURL *)url{
    return [[FTURLSessionInstrumentation sharedInstance].externalResourceHandler getTraceHeaderWithKey:key url:url];
}

@end
