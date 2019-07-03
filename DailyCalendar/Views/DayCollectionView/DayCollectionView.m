//
//  DayCollectionView.m
//  DailyCalendar
//
//  Created by Liubou Sakalouskaya on 7/2/19.
//  Copyright © 2019 Liubou Sakalouskaya. All rights reserved.
//

#import "DayCollectionView.h"
#import "EventCollectionViewCell.h"
#import "EventGridLayout.h"

NSString * const eventCellId = @"eventCellId";

@interface DayCollectionView () <UICollectionViewDataSource, EventGridLayoutDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet EventGridLayout *eventGridLayout;

@end

@implementation DayCollectionView

#pragma mark - Lifecycle

- (void)loadXibFile {
    UIView *view = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] firstObject];
    [self addSubview:view];
    view.frame = self.bounds;
    [self.collectionView registerClass:[EventCollectionViewCell class] forCellWithReuseIdentifier:eventCellId];
    self.eventGridLayout.dataSource = self;
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
    [self.eventGridLayout invalidateLayout];
    //TODO: scroll to the start of the week without decelerating
}

#pragma mark - Public

- (void)reloadData {
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger numberOfEvents = 0;
    if ([self.dataSource respondsToSelector:@selector(numberOfEventsInDayCollectionView:)]) {
        numberOfEvents = [self.dataSource numberOfEventsInDayCollectionView:self];
    }
    return numberOfEvents;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    EventCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:eventCellId forIndexPath:indexPath];
    if ([self.dataSource respondsToSelector:@selector(dayCollectionView:eventForItemAtIndexPath:)]) {
        cell.event = [self.dataSource dayCollectionView:self eventForItemAtIndexPath:indexPath];
    }
    return cell;
}

#pragma mark - EventGridLayoutDataSource

- (NSInteger)durationOfEventAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger duration = 0;
    if ([self.dataSource respondsToSelector:@selector(dayCollectionView:eventForItemAtIndexPath:)]) {
        EKEvent *event = [self.dataSource dayCollectionView:self eventForItemAtIndexPath:indexPath];
        duration = [[NSCalendar currentCalendar] components:NSCalendarUnitMinute fromDate:event.startDate toDate:event.endDate options:0].minute;
    }
    return duration;
}

- (NSInteger)startOfEventAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger start = 0;
    if ([self.dataSource respondsToSelector:@selector(dayCollectionView:eventForItemAtIndexPath:)]) {
        EKEvent *event = [self.dataSource dayCollectionView:self eventForItemAtIndexPath:indexPath];
        NSDate *startOfDay = [[NSCalendar currentCalendar] startOfDayForDate:event.startDate];
        start = [[NSCalendar currentCalendar] components:NSCalendarUnitMinute fromDate:startOfDay toDate:event.startDate options:0].minute;
    }
    return start;
}

@end
