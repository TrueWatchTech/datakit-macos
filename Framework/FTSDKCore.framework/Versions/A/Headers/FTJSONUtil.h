//
//  FTJSONUtil.h
//  FTMobileAgent
//
//  Created by hulilei on 2020/10/20.
//  Copyright © 2020 hll. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// JSON utility
@interface FTJSONUtil : NSObject
/**
 * @abstract
 * Convert a dict to Json string
 *
 * @param dict Object to convert
 *
 * @return Converted string
 */
+ (NSString *)convertToJsonData:(NSDictionary *)dict;
/**
 * @abstract
 * Convert a Json string to dict
 *
 * @param jsonString Json string to convert
 *
 * @return Converted dict
 */
+ (nullable NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;
/**
 * @abstract
 * Convert an Object to Json string
 *
 * @param obj Object to convert
 *
 * @return Converted string
 */
- (nullable NSData *)JSONSerializeDictObject:(NSDictionary *)obj;
/**
 * @abstract
 * Convert an array to Json string
 *
 * @param array Array to convert
 *
 * @return Converted string
 */
+ (NSString *)convertToJsonDataWithArray:(NSArray *)array;

@end

NS_ASSUME_NONNULL_END
