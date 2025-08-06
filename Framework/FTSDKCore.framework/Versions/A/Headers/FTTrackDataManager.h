//
//  FTTrackDataManger.h
//  FTMacOSSDK
//
//  Created by hulilei on 2021/8/4.
//  Copyright © 2021 DataFlux-cn. All rights reserved.
//

#import <Foundation/Foundation.h>
/// Data addition type
typedef NS_ENUM(NSInteger, FTAddDataType) {
    ///rum
    FTAddDataNormal,
    ///logging
    FTAddDataLogging,
    ///Crash log
    FTAddDataImmediate,
};
NS_ASSUME_NONNULL_BEGIN
@class FTRecordModel;
/// Data writing, data upload related operations
@interface FTTrackDataManager : NSObject
/// Singleton
+(instancetype)sharedInstance;
/// Data writing
/// - Parameters:
///   - data: Data
///   - type: Data storage type
- (void)addTrackData:(FTRecordModel *)data type:(FTAddDataType)type;

/// Upload data
- (void)uploadTrackData;
@end

NS_ASSUME_NONNULL_END
