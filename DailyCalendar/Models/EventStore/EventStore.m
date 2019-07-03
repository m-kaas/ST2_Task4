//
//  EventStore.m
//  DailyCalendar
//
//  Created by Liubou Sakalouskaya on 7/1/19.
//  Copyright © 2019 Liubou Sakalouskaya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventStore.h"

const NSInteger numberOfDaysInWeek = 7;

@interface EventStore ()

@property (strong, nonatomic) EKEventStore *eventStore;
@property (strong, nonatomic) NSMutableDictionary *eventsByDate;
@property (strong, nonatomic, readwrite) NSDate *startDate;
@property (strong, nonatomic, readwrite) NSDate *endDate;
@property (assign, nonatomic, readwrite) NSInteger numberOfDays;
@property (assign, nonatomic, readwrite) NSInteger numberOfWeeks;

@end

@implementation EventStore

- (void)addEvent:(EKEvent *)event {
    if (!self.eventsByDate) {
        self.eventsByDate = [NSMutableDictionary dictionary];
    }
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    NSDate *startDate = [currentCalendar startOfDayForDate:event.startDate];
    if ([self.eventsByDate.allKeys containsObject:startDate]) {
        [self.eventsByDate[startDate] addObject:event];
    } else {
        NSMutableArray *events = [NSMutableArray arrayWithObject:event];
        [self.eventsByDate addEntriesFromDictionary:@{ startDate: events }];
    }
}

- (void)loadEventsFromDate:(NSDate *)startDate toDate:(NSDate *)endDate {
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    NSInteger days = -[currentCalendar ordinalityOfUnit:NSCalendarUnitWeekday inUnit:NSCalendarUnitWeekOfYear forDate:startDate] + 1;
    self.startDate = [currentCalendar startOfDayForDate:[currentCalendar dateByAddingUnit:NSCalendarUnitDay value:days toDate:startDate options:0]];
    days = numberOfDaysInWeek - [currentCalendar ordinalityOfUnit:NSCalendarUnitWeekday inUnit:NSCalendarUnitWeekOfYear forDate:endDate] + 1;
    self.endDate = [currentCalendar startOfDayForDate:[currentCalendar dateByAddingUnit:NSCalendarUnitDay value:days toDate:endDate options:0]];
    self.numberOfDays = [currentCalendar components:NSCalendarUnitDay fromDate:self.startDate toDate:self.endDate options:0].day;
    self.numberOfWeeks = self.numberOfDays / numberOfDaysInWeek;
    [self fetchEvents];
}

- (void)fetchEvents {
    if (!self.eventStore) {
        self.eventStore = [EKEventStore new];
    }
    NSPredicate *eventsPredicate = [self.eventStore predicateForEventsWithStartDate:self.startDate endDate:self.endDate calendars:nil];
    [self.eventStore enumerateEventsMatchingPredicate:eventsPredicate usingBlock:^(EKEvent * _Nonnull event, BOOL * _Nonnull stop) {
        [self addEvent:event];
    }];
}

- (void)reloadEvents {
    self.eventStore = [EKEventStore new];
    [self.eventsByDate removeAllObjects];
    [self fetchEvents];
}

- (NSArray *)eventsForDate:(NSDate *)date {
    NSArray *events = [NSArray array];
    NSDate *startDate = [[NSCalendar currentCalendar] startOfDayForDate:date];
    if ([self.eventsByDate.allKeys containsObject:startDate]) {
        events = self.eventsByDate[startDate];
    }
    return events;
}

- (BOOL)hasEventsForDate:(NSDate *)date {
    NSDate *startDate = [[NSCalendar currentCalendar] startOfDayForDate:date];
    BOOL hasEvents = [self.eventsByDate.allKeys containsObject:startDate];
    return hasEvents;
}

- (NSInteger)numberOfEventsForDate:(NSDate *)date {
    NSInteger numberOfEvents = 0;
    NSDate *startDate = [[NSCalendar currentCalendar] startOfDayForDate:date];
    if ([self.eventsByDate.allKeys containsObject:startDate]) {
        NSArray *events = self.eventsByDate[startDate];
        numberOfEvents = events.count;
    }
    return numberOfEvents;
}

@end
