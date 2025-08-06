//
//  SplitViewItemVC1.h
//  Example
//
//  Created by hulilei on 2021/9/26.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN
@protocol SplitViewItemClick <NSObject>

- (void)tableViewSelectionDidSelect:(NSInteger)index;

@end
@interface SplitViewItemVC1 : NSViewController
@property (nonatomic, weak) id<SplitViewItemClick> delegate;

@end

NS_ASSUME_NONNULL_END
