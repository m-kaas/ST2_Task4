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

@interface WeeklyViewController ()

@property (strong, nonatomic) NSMutableArray *events;

@end

@implementation WeeklyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"kmp";
    EKEventStore *store = [EKEventStore new];
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
            [self fetchEvents];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchEvents) name:EKEventStoreChangedNotification object:nil];
            //dispatch_async(dispatch_get_main_queue(), ^{ [self.contactsTableView reloadData]; });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{ [self showAccessDeniedScreen]; });
        }
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)fetchEvents {
    EKEventStore *store = [EKEventStore new];
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    NSDateComponents *oneYear = [NSDateComponents new];
    oneYear.year = -1;
    NSDate *oneYearAgo = [currentCalendar dateByAddingComponents:oneYear toDate:[NSDate date] options:0];
    oneYear.year = 1;
    NSDate *oneYearFromNow = [currentCalendar dateByAddingComponents:oneYear toDate:[NSDate date] options:0];
    NSPredicate *eventsPredicate = [store predicateForEventsWithStartDate:oneYearAgo endDate:oneYearFromNow calendars:nil];
    self.events = [NSMutableArray arrayWithArray:[store eventsMatchingPredicate:eventsPredicate]];
}

- (void)showAccessDeniedScreen {
    self.view.backgroundColor = [UIColor customLightGrayColor];
    UILabel *accessDeniedLabel = [UILabel new];
    accessDeniedLabel.textColor = [UIColor customBlackColor];
    accessDeniedLabel.font = [UIFont system17RegularFont];
    accessDeniedLabel.text = @"Доступ к календарю запрещен. Войдите в Settings и разрешите доступ";
    accessDeniedLabel.numberOfLines = 0;
    accessDeniedLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:accessDeniedLabel];
    accessDeniedLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[[accessDeniedLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor constant:20],
                                              [accessDeniedLabel.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:20],
                                              [accessDeniedLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
                                              [self.view.trailingAnchor constraintEqualToAnchor:accessDeniedLabel.trailingAnchor constant:20]]];
}

@end
