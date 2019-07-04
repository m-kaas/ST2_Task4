//
//  DayCollectionView.h
//  DailyCalendar
//
//  Created by Liubou Sakalouskaya on 7/2/19.
//  Copyright © 2019 Liubou Sakalouskaya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>

NS_ASSUME_NONNULL_BEGIN

@class DayCollectionView;

@protocol DayCollectionViewDataSource <NSObject>

- (NSInteger)numberOfEventsInDayCollectionView:(DayCollectionView *)dayCollectionView;
- (EKEvent *)dayCollectionView:(DayCollectionView *)dayCollectionView eventForItemAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface DayCollectionView : UIView

@property (weak, nonatomic) id<DayCollectionViewDataSource> dataSource;
@property (assign, nonatomic) BOOL showCurrentTime;

- (void)reloadData;
- (void)scrollToCurrentTime;

@end

NS_ASSUME_NONNULL_END
