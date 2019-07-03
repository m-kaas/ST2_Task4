//
//  WeekCollectionView.h
//  DailyCalendar
//
//  Created by Liubou Sakalouskaya on 7/2/19.
//  Copyright © 2019 Liubou Sakalouskaya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventStore.h"

NS_ASSUME_NONNULL_BEGIN

@class WeekCollectionView;

@protocol WeekCollectionViewDataSource <NSObject>

- (NSInteger)numberOfWeeksInWeekCollectionView:(WeekCollectionView *)weekCollectionView;
- (NSDate *)startDateForWeekCollectionView:(WeekCollectionView *)weekCollectionView;
- (BOOL)weekCollectionView:(WeekCollectionView *)weekCollectionView hasEventsForDate:(NSDate *)eventDate;

@end

@protocol WeekCollectionViewDelegate <NSObject>

- (void)weekCollectionView:(WeekCollectionView *)weekCollectionView didSelectDateAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface WeekCollectionView : UIView

@property (weak, nonatomic) id<WeekCollectionViewDataSource> dataSource;
@property (weak, nonatomic) id<WeekCollectionViewDelegate> delegate;

- (void)reloadData;
- (void)selectToday;

@end

NS_ASSUME_NONNULL_END
