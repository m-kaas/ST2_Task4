//
//  WeekCollectionView.m
//  DailyCalendar
//
//  Created by Liubou Sakalouskaya on 7/2/19.
//  Copyright © 2019 Liubou Sakalouskaya. All rights reserved.
//

#import "WeekCollectionView.h"
#import "WeekCollectionViewCell.h"
#import "UIColor+CustomColors.h"
#import "EventStore.h"

NSString * const dayCellId = @"dayCellId";

@interface WeekCollectionView () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;
@property (assign, nonatomic) BOOL shouldUpdateContentOffset;
@property (assign, nonatomic) BOOL isAnimating;
@property (assign, nonatomic) CGFloat lastContentOffset;

@end

@implementation WeekCollectionView

#pragma mark - Lifecycle

- (void)loadXibFile {
    UIView *view = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] firstObject];
    [self addSubview:view];
    view.frame = self.bounds;
    view.backgroundColor = [UIColor customDarkBlueColor];
    self.collectionView.backgroundColor = [UIColor customDarkBlueColor];
    UINib *dayCellNib = [UINib nibWithNibName:NSStringFromClass([WeekCollectionViewCell class]) bundle:[NSBundle mainBundle]];
    [self.collectionView registerNib:dayCellNib forCellWithReuseIdentifier:dayCellId];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self loadXibFile];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self loadXibFile];
    }
    return self;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [self.flowLayout invalidateLayout];
    self.shouldUpdateContentOffset = YES;
    NSIndexPath *selectedIndexPath = self.collectionView.indexPathsForSelectedItems.firstObject;
    if (selectedIndexPath) {
        NSIndexPath *scrolledIndexPath = [NSIndexPath indexPathForItem:0 inSection:selectedIndexPath.section];
        self.isAnimating = YES;
        [self.collectionView scrollToItemAtIndexPath:scrolledIndexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    }
}

#pragma mark - Public

- (void)reloadData {
    NSIndexPath *indexPath = self.collectionView.indexPathsForSelectedItems.firstObject;
    [self.collectionView reloadData];
    if (indexPath) {
        [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    }
}

- (void)selectToday {
    if ([self.dataSource respondsToSelector:@selector(startDateForWeekCollectionView:)]) {
        NSDate *startDate = [self.dataSource startDateForWeekCollectionView:self];
        //NSInteger days = [[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:startDate toDate:[NSDate date] options:0].day;
        NSInteger days = [[EventStore appCalendar] components:NSCalendarUnitDay fromDate:startDate toDate:[NSDate date] options:0].day;
        NSInteger item = days % numberOfDaysInWeek;
        NSInteger section = days / numberOfDaysInWeek;
        NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForItem:item inSection:section];
        NSIndexPath *scrolledIndexPath = [NSIndexPath indexPathForItem:0 inSection:section];
        self.shouldUpdateContentOffset = YES;
        [self.collectionView scrollToItemAtIndexPath:scrolledIndexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
        [self.collectionView selectItemAtIndexPath:selectedIndexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        [self collectionView:self.collectionView didSelectItemAtIndexPath:selectedIndexPath];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    NSInteger numberOfWeeks = 0;
    if ([self.dataSource respondsToSelector:@selector(numberOfWeeksInWeekCollectionView:)]) {
        numberOfWeeks = [self.dataSource numberOfWeeksInWeekCollectionView:self];
    }
    return numberOfWeeks;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return numberOfDaysInWeek;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WeekCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:dayCellId forIndexPath:indexPath];
    if ([self.dataSource respondsToSelector:@selector(startDateForWeekCollectionView:)] &&
        [self.dataSource respondsToSelector:@selector(weekCollectionView:hasEventsForDate:)]) {
        NSInteger days = indexPath.section * numberOfDaysInWeek + indexPath.item;
        NSDate *startDate = [self.dataSource startDateForWeekCollectionView:self];
        //NSCalendar *currentCalendar = [NSCalendar currentCalendar];
        NSCalendar *currentCalendar = [EventStore appCalendar];
        NSDate *eventDate = [currentCalendar dateByAddingUnit:NSCalendarUnitDay value:days toDate:startDate options:0];
        NSDateComponents *dateComponents = [currentCalendar components:NSCalendarUnitDay|NSCalendarUnitWeekday fromDate:eventDate];
        cell.dateLabel.text = [NSString stringWithFormat:@"%ld", dateComponents.day];
        cell.dayLabel.text = currentCalendar.shortWeekdaySymbols[dateComponents.weekday - 1].uppercaseString;
        BOOL hasEvents = [self.dataSource weekCollectionView:self hasEventsForDate:eventDate];
        if (hasEvents) {
            cell.dotLabel.textColor = [UIColor customWhiteColor];
        } else {
            cell.dotLabel.textColor = [UIColor clearColor];
        }
    }
    cell.layer.cornerRadius = cell.bounds.size.width / 2;
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(weekCollectionView:didSelectDateAtIndexPath:)]) {
        [self.delegate weekCollectionView:self didSelectDateAtIndexPath:indexPath];
    }
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
    NSIndexPath *selectedIndexPath = self.collectionView.indexPathsForSelectedItems.firstObject;
    if (selectedIndexPath) {
        NSIndexPath *newSelectedIndexPath = [NSIndexPath indexPathForItem:selectedIndexPath.item inSection:(selectedIndexPath.section + direction)];
        [self.collectionView selectItemAtIndexPath:newSelectedIndexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
        [self collectionView:self.collectionView didSelectItemAtIndexPath:newSelectedIndexPath];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (self.shouldUpdateContentOffset && self.isAnimating) {
        self.lastContentOffset = scrollView.contentOffset.x;
        self.shouldUpdateContentOffset = NO;
        self.isAnimating = NO;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.shouldUpdateContentOffset && !self.isAnimating) {
        self.lastContentOffset = scrollView.contentOffset.x;
        self.shouldUpdateContentOffset = NO;
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    CGFloat cellSize = ((UICollectionViewFlowLayout *)collectionViewLayout).itemSize.width;
    CGFloat spacing = (collectionView.bounds.size.width - numberOfDaysInWeek * cellSize) / (numberOfDaysInWeek - 1);
    return spacing;
}

@end
