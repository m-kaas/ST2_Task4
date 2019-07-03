//
//  WeeklyViewController.m
//  DailyCalendar
//
//  Created by Liubou Sakalouskaya on 6/29/19.
//  Copyright © 2019 Liubou Sakalouskaya. All rights reserved.
//

#import <EventKit/EventKit.h>
#import "WeeklyViewController.h"
#import "UIColor+CustomColors.h"
#import "UIFont+CustomFonts.h"
#import "AccessDeniedView.h"
#import "EventStore.h"
#import "WeekCollectionView.h"
#import "DayCollectionView.h"

@interface WeeklyViewController () <WeekCollectionViewDelegate, WeekCollectionViewDataSource, DayCollectionViewDataSource>

@property (strong, nonatomic) EventStore *eventStore;
@property (strong, nonatomic) NSDate *selectedDate;
@property (weak, nonatomic) IBOutlet DayCollectionView *dayView;
@property (weak, nonatomic) IBOutlet WeekCollectionView *weekView;


@end

@implementation WeeklyViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addTodayButton];
    self.selectedDate = [NSDate date];
    self.weekView.delegate = self;
    self.weekView.dataSource = self;
    self.dayView.dataSource = self;
    self.eventStore = [EventStore new];
    EKEventStore *store = [EKEventStore new];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateEvents) name:EKEventStoreChangedNotification object:nil];
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
            [self setupCalendarInfo];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.dayView reloadData];
                [self.weekView reloadData];
                [self.weekView selectToday];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{ [self showAccessDeniedScreen]; });
        }
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Private

- (void)updateEvents {
    [self.eventStore reloadEvents];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.dayView reloadData];
        [self.weekView reloadData];
    });
}

- (void)setupCalendarInfo {
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    NSInteger years = -1;
    NSDate *oneYearAgo = [currentCalendar dateByAddingUnit:NSCalendarUnitYear value:years toDate:[NSDate date] options:0];
    years = 1;
    NSDate *oneYearFromNow = [currentCalendar dateByAddingUnit:NSCalendarUnitYear value:years toDate:[NSDate date] options:0];
    [self.eventStore loadEventsFromDate:oneYearAgo toDate:oneYearFromNow];
}

- (void)showAccessDeniedScreen {
    self.dayView.hidden = YES;
    self.weekView.hidden = YES;
    self.navigationItem.title = @"Нет доступа";
    AccessDeniedView *accessDeniedView = [[AccessDeniedView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:accessDeniedView];
    [accessDeniedView setLabelText:@"Доступ к календарю запрещен. Войдите в Settings и разрешите доступ"];
}

- (void)addTodayButton {
    UIBarButtonItem *todayButton = [[UIBarButtonItem alloc] initWithTitle:@"Today" style:UIBarButtonItemStyleDone target:self action:@selector(selectToday)];
    todayButton.tintColor = [UIColor customWhiteColor];
    self.navigationItem.rightBarButtonItem = todayButton;
}

- (void)selectToday {
    self.selectedDate = [NSDate date];
    [self.weekView selectToday];
    [self.dayView reloadData];
}

#pragma mark - Custom Accessors

- (void)setSelectedDate:(NSDate *)selectedDate {
    if (_selectedDate != selectedDate) {
        _selectedDate = selectedDate;
    }
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"dd MMMM yyyy";
    self.navigationItem.title = [formatter stringFromDate:self.selectedDate];
}

#pragma mark - WeekCollectionViewDelegate

- (void)weekCollectionView:(WeekCollectionView *)weekCollectionView didSelectDateAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger days = numberOfDaysInWeek * indexPath.section + indexPath.item;
    NSDate *date = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:days toDate:self.eventStore.startDate options:0];
    self.selectedDate = date;
    [self.dayView reloadData];
}

#pragma mark - WeekCollectionViewDataSource

- (NSInteger)numberOfWeeksInWeekCollectionView:(WeekCollectionView *)weekCollectionView {
    NSInteger numberOfWeeks = self.eventStore.numberOfWeeks;
    return numberOfWeeks;
}

- (NSDate *)startDateForWeekCollectionView:(WeekCollectionView *)weekCollectionView {
    NSDate *startDate = self.eventStore.startDate;
    return startDate;
}

- (BOOL)weekCollectionView:(WeekCollectionView *)weekCollectionView hasEventsForDate:(NSDate *)eventDate {
    BOOL hasEvents = [self.eventStore hasEventsForDate:eventDate];
    return hasEvents;
}

#pragma mark - DayCollectionViewDataSource

- (NSInteger)numberOfEventsInDayCollectionView:(DayCollectionView *)dayCollectionView {
    NSInteger numberOfEvents = [self.eventStore numberOfEventsForDate:self.selectedDate];
    return numberOfEvents;
}

- (nonnull EKEvent *)dayCollectionView:(nonnull DayCollectionView *)dayCollectionView eventForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSArray *dayEvents = [self.eventStore eventsForDate:self.selectedDate];
    EKEvent *event = dayEvents[indexPath.item];
    return event;
}

@end
