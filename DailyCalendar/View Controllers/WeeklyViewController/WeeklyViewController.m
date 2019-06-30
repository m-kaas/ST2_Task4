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
#import "WeeklyCollectionViewCell.h"

NSString * const dayCellId = @"dayCellId";
const NSInteger numberOfDaysInWeek = 7;

@interface WeeklyViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) NSMutableArray *events;
@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;
@property (strong, nonatomic) NSDate *selectedDate;
@property (weak, nonatomic) IBOutlet UICollectionView *weekView;
@property (weak, nonatomic) IBOutlet UICollectionView *dayGridView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *weekViewLayout;

@end

@implementation WeeklyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"kmp";
    self.weekView.backgroundColor = [UIColor customDarkBlueColor];
    UINib *dayCellNib = [UINib nibWithNibName:NSStringFromClass([WeeklyCollectionViewCell class]) bundle:[NSBundle mainBundle]];
    [self.weekView registerNib:dayCellNib forCellWithReuseIdentifier:dayCellId];
    EKEventStore *store = [EKEventStore new];
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
            [self fetchEvents];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchEvents) name:EKEventStoreChangedNotification object:nil];
            dispatch_async(dispatch_get_main_queue(), ^{ [self.dayGridView reloadData]; });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{ [self showAccessDeniedScreen]; });
        }
    }];
}

- (void)viewWillLayoutSubviews {
    [self.weekViewLayout invalidateLayout];
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
    self.startDate = oneYearAgo;
    oneYear.year = 1;
    NSDate *oneYearFromNow = [currentCalendar dateByAddingComponents:oneYear toDate:[NSDate date] options:0];
    self.endDate = oneYearFromNow;
    NSPredicate *eventsPredicate = [store predicateForEventsWithStartDate:oneYearAgo endDate:oneYearFromNow calendars:nil];
    self.events = [NSMutableArray arrayWithArray:[store eventsMatchingPredicate:eventsPredicate]];
}

- (void)showAccessDeniedScreen {
    self.dayGridView.hidden = YES;
    self.weekView.hidden = YES;
    self.navigationItem.title = @"Нет доступа";
    AccessDeniedView *accessDeniedView = [[AccessDeniedView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:accessDeniedView];
    [accessDeniedView setLabelText:@"Доступ к календарю запрещен. Войдите в Settings и разрешите доступ"];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    NSInteger numberOfDays = [[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:self.startDate toDate:self.endDate options:0].day;
    NSInteger numberOfSections = ceil(1.0 * numberOfDays / numberOfDaysInWeek);
    return numberOfSections;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return numberOfDaysInWeek;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WeeklyCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:dayCellId forIndexPath:indexPath];
    NSInteger days = indexPath.section * [collectionView numberOfItemsInSection:indexPath.section] + indexPath.item;
    cell.date = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:days toDate:self.startDate options:0];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    CGFloat cellSize = ((UICollectionViewFlowLayout *)collectionViewLayout).itemSize.width;
    CGFloat spacing = (collectionView.bounds.size.width - [collectionView numberOfItemsInSection:section] * cellSize) / ([collectionView numberOfItemsInSection:section] - 1);
    return spacing;
}

@end
