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

@interface WeeklyViewController () <DayCollectionViewDataSource>

@property (strong, nonatomic) EventStore *eventStore;
@property (strong, nonatomic) NSDate *selectedDate;
@property (weak, nonatomic) IBOutlet DayCollectionView *dayView;
@property (weak, nonatomic) IBOutlet WeekCollectionView *weekView;


@end

@implementation WeeklyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"kmp";
    self.selectedDate = [NSDate date];
    self.dayView.dataSource = self;
    self.eventStore = [EventStore new];
    EKEventStore *store = [EKEventStore new];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchEvents) name:EKEventStoreChangedNotification object:nil];
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
            [self setupCalendarInfo];
            //TODO: handle eventStore and selectedDate somehow else, e.g. eventStore -> dataSource
            self.weekView.eventStore = self.eventStore;
            self.weekView.selectedDate = self.selectedDate;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.dayView reloadData];
                [self.weekView reloadData];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{ [self showAccessDeniedScreen]; });
        }
    }];
}

- (void)dealloc
{
    //[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupCalendarInfo {
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    NSDateComponents *oneYear = [NSDateComponents new];
    oneYear.year = -1;
    NSDate *oneYearAgo = [currentCalendar dateByAddingComponents:oneYear toDate:[NSDate date] options:0];
    oneYear.year = 1;
    NSDate *oneYearFromNow = [currentCalendar dateByAddingComponents:oneYear toDate:[NSDate date] options:0];
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
