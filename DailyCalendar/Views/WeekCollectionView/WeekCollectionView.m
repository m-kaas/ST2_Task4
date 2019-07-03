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

NSString * const dayCellId = @"dayCellId";

@interface WeekCollectionView () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;

@property (assign, nonatomic) CGFloat lastContentOffset;

@end

@implementation WeekCollectionView

- (void)loadXibFile {
    UIView *view = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] firstObject];
    [self addSubview:view];
    view.frame = self.bounds;
    self.collectionView.backgroundColor = [UIColor customDarkBlueColor];
    self.lastContentOffset = 0;
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
    //TODO: scroll to the start of the week without decelerating
}

- (void)reloadData {
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    //return [self.dataSource numberOfWeeksInWeekCollectionView:self];
    return self.eventStore.numberOfWeeks;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return numberOfDaysInWeek;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WeekCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:dayCellId forIndexPath:indexPath];
    NSInteger days = indexPath.section * numberOfDaysInWeek + indexPath.item;
    //NSDate *startDate = [self.dataSource startDateForWeekCollectionView:self];
    NSDate *eventDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:days toDate:self.eventStore.startDate options:0];
    cell.date = eventDate;
    //BOOL hasEvents = [self.dataSource weekCollectionView:self hasEventsForDate:eventDate];
    cell.hasEvents = [self.eventStore hasEventsForDate:eventDate];
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
    //TODO: notify about selection
    NSIndexPath *selectedIndexPath = self.collectionView.indexPathsForSelectedItems.firstObject;
    if (selectedIndexPath) {
        NSIndexPath *newSelectedIndexPath = [NSIndexPath indexPathForItem:selectedIndexPath.item inSection:(selectedIndexPath.section + direction)];
        [self.collectionView selectItemAtIndexPath:newSelectedIndexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    CGFloat cellSize = ((UICollectionViewFlowLayout *)collectionViewLayout).itemSize.width;
    CGFloat spacing = (collectionView.bounds.size.width - numberOfDaysInWeek * cellSize) / (numberOfDaysInWeek - 1);
    return spacing;
}

@end
