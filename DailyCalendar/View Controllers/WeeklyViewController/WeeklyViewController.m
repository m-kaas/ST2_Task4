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
#import "EventStore.h"

NSString * const dayCellId = @"dayCellId";

@interface WeeklyViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) EventStore *eventStore;
@property (strong, nonatomic) NSDate *selectedDate;
@property (weak, nonatomic) IBOutlet UICollectionView *weekView;
@property (weak, nonatomic) IBOutlet UICollectionView *dayGridView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *weekViewLayout;
@property (assign, nonatomic) CGFloat lastContentOffset;

@end

@implementation WeeklyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"kmp";
    self.lastContentOffset = 0;
    self.weekView.backgroundColor = [UIColor customDarkBlueColor];
    self.eventStore = [EventStore new];
    UINib *dayCellNib = [UINib nibWithNibName:NSStringFromClass([WeeklyCollectionViewCell class]) bundle:[NSBundle mainBundle]];
    [self.weekView registerNib:dayCellNib forCellWithReuseIdentifier:dayCellId];
    EKEventStore *store = [EKEventStore new];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchEvents) name:EKEventStoreChangedNotification object:nil];
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
            [self setupDateInfo];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{ [self showAccessDeniedScreen]; });
        }
    }];
}

- (void)viewWillLayoutSubviews {
    [self.weekViewLayout invalidateLayout];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [self.weekViewLayout invalidateLayout];
}

- (void)dealloc
{
    //[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupDateInfo {
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    NSDateComponents *oneYear = [NSDateComponents new];
    oneYear.year = -1;
    NSDate *oneYearAgo = [currentCalendar dateByAddingComponents:oneYear toDate:[NSDate date] options:0];
    oneYear.year = 1;
    NSDate *oneYearFromNow = [currentCalendar dateByAddingComponents:oneYear toDate:[NSDate date] options:0];
    [self.eventStore loadEventsFromDate:oneYearAgo toDate:oneYearFromNow];
    self.selectedDate = [NSDate date];
    dispatch_async(dispatch_get_main_queue(), ^{ [self.dayGridView reloadData]; [self.weekView reloadData]; });
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
    return self.eventStore.numberOfWeeks;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return numberOfDaysInWeek;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WeeklyCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:dayCellId forIndexPath:indexPath];
    NSInteger days = indexPath.section * numberOfDaysInWeek + indexPath.item;
    NSDate *eventDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:days toDate:self.eventStore.startDate options:0];
    cell.date = eventDate;
    BOOL hasEvents = ([self.eventStore eventsForDate:eventDate].count > 0);
    cell.hasEvents = hasEvents;
    cell.layer.cornerRadius = cell.bounds.size.width / 2;
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger direction = 0;
    CGFloat newContentOffset = scrollView.contentOffset.x;
    if (newContentOffset < self.lastContentOffset) {
        direction = -1;
    } else if (newContentOffset > self.lastContentOffset) {
        direction = 1;
    }
    self.lastContentOffset = newContentOffset;
    NSDateComponents *week = [NSDateComponents new];
    week.day = numberOfDaysInWeek * direction;
    NSDate *newSelectedDate = [[NSCalendar currentCalendar] dateByAddingComponents:week toDate:self.selectedDate options:0];
    self.selectedDate = newSelectedDate;
    NSIndexPath *selectedIndexPath = self.weekView.indexPathsForSelectedItems.firstObject;
    if (selectedIndexPath) {
        NSIndexPath *newSelectedIndexPath = [NSIndexPath indexPathForItem:selectedIndexPath.item inSection:(selectedIndexPath.section + direction)];
        [self.weekView selectItemAtIndexPath:newSelectedIndexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    CGFloat cellSize = ((UICollectionViewFlowLayout *)collectionViewLayout).itemSize.width;
    CGFloat spacing = (collectionView.bounds.size.width - numberOfDaysInWeek * cellSize) / (numberOfDaysInWeek - 1);
    return spacing;
}

@end
