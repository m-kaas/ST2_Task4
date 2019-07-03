//
//  EventStore.h
//  DailyCalendar
//
//  Created by Liubou Sakalouskaya on 7/1/19.
//  Copyright © 2019 Liubou Sakalouskaya. All rights reserved.
//

#import <EventKit/EventKit.h>

extern const NSInteger numberOfDaysInWeek;

@interface EventStore : NSObject

@property (strong, nonatomic, readonly) NSDate *startDate;
@property (strong, nonatomic, readonly) NSDate *endDate;
@property (assign, nonatomic, readonly) NSInteger numberOfDays;
@property (assign, nonatomic, readonly) NSInteger numberOfWeeks;

- (void)addEvent:(EKEvent *)event;
- (void)loadEventsFromDate:(NSDate *)startDate toDate:(NSDate *)endDate;
- (NSArray *)eventsForDate:(NSDate *)date;
- (BOOL)hasEventsForDate:(NSDate *)date;
- (NSInteger)numberOfEventsForDate:(NSDate *)date;
- (void)reloadEvents;

@end
