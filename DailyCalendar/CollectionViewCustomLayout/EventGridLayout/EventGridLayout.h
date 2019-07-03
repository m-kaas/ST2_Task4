//
//  EventGridLayout.h
//  DailyCalendar
//
//  Created by Liubou Sakalouskaya on 7/3/19.
//  Copyright © 2019 Liubou Sakalouskaya. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class EventGridLayout;

@protocol EventGridLayoutDataSource <NSObject>

- (NSInteger)durationOfEventAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)startOfEventAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface EventGridLayout : UICollectionViewLayout

@property (weak, nonatomic) id<EventGridLayoutDataSource> dataSource;

@end

NS_ASSUME_NONNULL_END
