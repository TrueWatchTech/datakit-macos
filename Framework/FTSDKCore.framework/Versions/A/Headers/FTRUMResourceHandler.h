//
//  FTRUMResourceHandler.h
//  FTMobileAgent
//
//  Created by hulilei on 2021/5/26.
//  Copyright © 2021 hll. All rights reserved.
//

#import "FTRUMHandler.h"
@class FTRUMViewHandler;
NS_ASSUME_NONNULL_BEGIN
typedef void(^FTResourceEventSent)(void);
typedef void(^FTErrorEventSent)(void);

/// RUM Resource data processor
@interface FTRUMResourceHandler : FTRUMHandler
/// Resource unique identifier
@property (nonatomic, copy,readonly) NSString *identifier;
/// RUM context
@property (nonatomic, strong) FTRUMContext *context;
/// Resource data processing completion callback
@property (nonatomic, copy) FTResourceEventSent resourceHandler;
/// Resource error processing completion callback
@property (nonatomic, copy) FTErrorEventSent errorHandler;
/// Initialization method
/// - Parameters:
///   - model: RUM data model
///   - context: RUM context
-(instancetype)initWithModel:(FTRUMResourceDataModel *)model context:(FTRUMContext *)context;
@end

NS_ASSUME_NONNULL_END
