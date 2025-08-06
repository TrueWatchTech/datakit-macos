//
//  NSCollectionView+FTAutoTrack.h
//  FTMacOSSDK-framework
//
//  Created by hulilei on 2021/9/17.
//

#import <Cocoa/Cocoa.h>
#import "FTAutoTrackProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSCollectionView (FTAutoTrack)<FTRUMActionProperty>
-(void)datakit_setDelegate:(id<NSCollectionViewDelegate>)delegate;
@end

@interface NSTableView (FTAutoTrack)<FTRUMActionProperty>

@end
NS_ASSUME_NONNULL_END
