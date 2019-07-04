//
//  EventGridLayout.m
//  DailyCalendar
//
//  Created by Liubou Sakalouskaya on 7/3/19.
//  Copyright © 2019 Liubou Sakalouskaya. All rights reserved.
//

#import "EventGridLayout.h"
#import "EventGridLayoutConstants.h"
#import "UIColor+CustomColors.h"
#import "UIFont+CustomFonts.h"
#import "DottedLineView.h"
#import "TimeLabelView.h"
#import "TimeLabelViewLayoutAttributes.h"
#import "CurrentTimeLineView.h"

@interface EventGridLayout ()

@property (strong, nonatomic) NSCache *attributesCache;

@end

@implementation EventGridLayout

#pragma mark - Lifecycle

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self registerClass:[DottedLineView class] forDecorationViewOfKind:dottedLineDecorationViewKind];
        [self registerClass:[TimeLabelView class] forDecorationViewOfKind:sectionTimeDecorationViewKind];
        [self registerClass:[TimeLabelView class] forDecorationViewOfKind:eventTimeDecorationViewKind];
        [self registerClass:[TimeLabelView class] forDecorationViewOfKind:currentTimeDecorationViewKind];
        [self registerClass:[CurrentTimeLineView class] forDecorationViewOfKind:currentTimeLineDecorationViewKind];
        
        NSDate *nextMinuteDate =  [[NSCalendar currentCalendar] nextDateAfterDate:[NSDate date] matchingUnit:NSCalendarUnitSecond value:0 options:NSCalendarMatchNextTime];
        NSTimer *minuteTimer = [[NSTimer alloc] initWithFireDate:nextMinuteDate interval:60 target:self selector:@selector(timeChanged) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:minuteTimer forMode:NSDefaultRunLoopMode];
    }
    return self;
}

#pragma mark - UICollectionViewLayout

- (CGSize)collectionViewContentSize {
    return CGSizeMake(self.collectionView.bounds.size.width, numberOfSections * sectionHeight);
}

- (void)prepareLayout {
    if (!self.attributesCache) {
        self.attributesCache = [NSCache new];
    }
    if (![self.attributesCache objectForKey:itemAttributesKey]) {
        NSArray *itemsAttributes = [self prepareItemsAttributes];
        [self.attributesCache setObject:itemsAttributes forKey:itemAttributesKey];
    }
    if (![self.attributesCache objectForKey:dottedLineAttributesKey]) {
        NSArray *linesAttributes = [self prepareDottedLinesAttributes];
        [self.attributesCache setObject:linesAttributes forKey:dottedLineAttributesKey];
    }
    if (![self.attributesCache objectForKey:sectionTimeAttributesKey]) {
        NSArray *sectionTimesAttributes = [self prepareSectionTimesAttributes];
        [self.attributesCache setObject:sectionTimesAttributes forKey:sectionTimeAttributesKey];
    }
    if (![self.attributesCache objectForKey:eventTimeAttributesKey]) {
        NSArray *eventTimesAttributes = [self prepareEventTimesAttributes];
        [self.attributesCache setObject:eventTimesAttributes forKey:eventTimeAttributesKey];
    }
    if (![self.attributesCache objectForKey:currentTimeLineAttributesKey]) {
        NSArray *currentTimeLineAttributes = [self prepareCurrentTimeLineAttributes];
        [self.attributesCache setObject:currentTimeLineAttributes forKey:currentTimeLineAttributesKey];
    }
    if (![self.attributesCache objectForKey:currentTimeAttributesKey]) {
        NSArray *currentTimeAttributes = [self prepareCurrentTimeAttributes];
        [self.attributesCache setObject:currentTimeAttributes forKey:currentTimeAttributesKey];
    }
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *rectAttributes = [NSMutableArray array];
    NSMutableArray *allAttributes = [NSMutableArray array];
    NSArray *itemsAttributes = [self.attributesCache objectForKey:itemAttributesKey];
    [allAttributes addObjectsFromArray:itemsAttributes];
    NSArray *dottedLinesAttributes = [self.attributesCache objectForKey:dottedLineAttributesKey];
    [allAttributes addObjectsFromArray:dottedLinesAttributes];
    NSArray *sectionTimesAttributes = [self.attributesCache objectForKey:sectionTimeAttributesKey];
    [allAttributes addObjectsFromArray:sectionTimesAttributes];
    NSArray *eventTimesAttributes = [self.attributesCache objectForKey:eventTimeAttributesKey];
    [allAttributes addObjectsFromArray:eventTimesAttributes];
    NSArray *currentTimeLineAttributes = [self.attributesCache objectForKey:currentTimeLineAttributesKey];
    [allAttributes addObjectsFromArray:currentTimeLineAttributes];
    NSArray *currentTimeAttributes = [self.attributesCache objectForKey:currentTimeAttributesKey];
    [allAttributes addObjectsFromArray:currentTimeAttributes];
    for (UICollectionViewLayoutAttributes *attributes in allAttributes) {
        if (CGRectIntersectsRect(attributes.frame, rect)) {
            [rectAttributes addObject:attributes];
        }
    }
    return [rectAttributes copy];
}

#pragma mark - Public

- (void)invalidateFullLayout {
    [self.attributesCache removeAllObjects];
    [self invalidateLayout];
}

#pragma mark - Private

- (void)timeChanged {
    [self.attributesCache removeObjectForKey:currentTimeLineAttributesKey];
    [self.attributesCache removeObjectForKey:currentTimeAttributesKey];
    [self invalidateLayout];
}

- (NSArray *)prepareItemsAttributes {
    NSMutableArray *itemsAttributes = [NSMutableArray array];
    if ([self.dataSource respondsToSelector:@selector(durationOfEventAtIndexPath:)] &&
        [self.dataSource respondsToSelector:@selector(startOfEventAtIndexPath:)]) {
        for (int i = 0; i < [self.collectionView numberOfItemsInSection:0]; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
            NSInteger minutes = [self.dataSource durationOfEventAtIndexPath:indexPath];
            CGFloat itemHeight = 1.0 * minutes / minutesInSection * sectionHeight;
            NSInteger start = [self.dataSource startOfEventAtIndexPath:indexPath];
            CGFloat itemY = 1.0 * start / minutesInSection * sectionHeight;
            if (itemY + itemHeight > self.collectionView.contentSize.height) {
                itemHeight = self.collectionView.contentSize.height - itemY;
            }
            CGFloat itemWidth = self.collectionView.bounds.size.width - xOffset - self.collectionView.layoutMargins.right - self.collectionView.layoutMargins.left;
            CGRect itemFrame = CGRectMake(xOffset + self.collectionView.layoutMargins.left, itemY, itemWidth, itemHeight);
            UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            attr.frame = itemFrame;
            attr.zIndex = itemZIndex;
            [itemsAttributes addObject:attr];
        }
    }
    return [itemsAttributes copy];
}

- (NSArray *)prepareDottedLinesAttributes {
    NSMutableArray *linesAttributes = [NSMutableArray array];
    for (int i = 1; i < numberOfSections; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i-1 inSection:0];
        CGRect viewFrame = CGRectMake(0, i * sectionHeight - dotSize / 2, self.collectionView.bounds.size.width, dotSize);
        UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:dottedLineDecorationViewKind withIndexPath:indexPath];
        attr.frame = viewFrame;
        attr.zIndex = decorationZIndex;
        [linesAttributes addObject:attr];
    }
    return [linesAttributes copy];
}

- (NSArray *)prepareSectionTimesAttributes {
    NSMutableArray *timesAttributes = [NSMutableArray array];
    for (int i = 0; i < numberOfHours; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        CGRect viewFrame = CGRectMake(self.collectionView.layoutMargins.left, i * sectionHeight * numberOfSectionsInHour, xOffset, sectionHeight);
        TimeLabelViewLayoutAttributes *attr = [TimeLabelViewLayoutAttributes layoutAttributesForDecorationViewOfKind:sectionTimeDecorationViewKind withIndexPath:indexPath];
        attr.frame = viewFrame;
        attr.timeText = [NSString stringWithFormat:@"%d:00", i];
        attr.textColor = [UIColor customDarkGrayColor];
        attr.font = [UIFont system15RegularFont];
        attr.zIndex = decorationZIndex;
        [timesAttributes addObject:attr];
    }
    return [timesAttributes copy];
}

- (NSArray *)prepareEventTimesAttributes {
    NSMutableArray *timesAttributes = [NSMutableArray array];
    if ([self.dataSource respondsToSelector:@selector(startOfEventAtIndexPath:)]) {
        for (int i = 0; i < [self.collectionView numberOfItemsInSection:0]; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
            NSInteger start = [self.dataSource startOfEventAtIndexPath:indexPath];
            if (start % minutesInHour == 0) {
                continue;
            }
            NSInteger section = start / minutesInSection;
            CGRect viewFrame = CGRectMake(self.collectionView.layoutMargins.left, section * sectionHeight, xOffset, sectionHeight);
            TimeLabelViewLayoutAttributes *attr = [TimeLabelViewLayoutAttributes layoutAttributesForDecorationViewOfKind:eventTimeDecorationViewKind withIndexPath:indexPath];
            attr.frame = viewFrame;
            attr.timeText = [NSString stringWithFormat:@"%ld:%ld", start / 60, start % 60];
            attr.textColor = [UIColor customBlackColor];
            attr.font = [UIFont system15RegularFont];
            attr.zIndex = decorationZIndex;
            [timesAttributes addObject:attr];
        }
    }
    return [timesAttributes copy];
}

- (NSArray *)prepareCurrentTimeLineAttributes {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    UICollectionViewLayoutAttributes *lineAttributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:currentTimeLineDecorationViewKind withIndexPath:indexPath];
    NSDate *today = [NSDate date];
    NSDate *startOfDay = [[NSCalendar currentCalendar] startOfDayForDate:today];
    NSInteger start = [[NSCalendar currentCalendar] components:NSCalendarUnitMinute fromDate:startOfDay toDate:today options:0].minute;
    CGFloat lineY = 1.0 * start / minutesInSection * sectionHeight;
    CGRect viewFrame = CGRectMake(xOffset, lineY, self.collectionView.bounds.size.width - xOffset, 1);
    lineAttributes.frame = viewFrame;
    lineAttributes.zIndex = decorationZIndex;
    return @[lineAttributes];
}

- (NSArray *)prepareCurrentTimeAttributes {
    //TODO: do not show other times if they are equal to current time
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    TimeLabelViewLayoutAttributes *timeAttributes = [TimeLabelViewLayoutAttributes layoutAttributesForDecorationViewOfKind:currentTimeDecorationViewKind withIndexPath:indexPath];
    NSDate *today = [NSDate date];
    NSDate *startOfDay = [[NSCalendar currentCalendar] startOfDayForDate:today];
    NSInteger start = [[NSCalendar currentCalendar] components:NSCalendarUnitMinute fromDate:startOfDay toDate:today options:0].minute;
    CGFloat timeY = 1.0 * start / minutesInSection * sectionHeight - sectionHeight / 2.0;
    CGRect viewFrame = CGRectMake(self.collectionView.layoutMargins.left, timeY, xOffset, sectionHeight);
    timeAttributes.frame = viewFrame;
    timeAttributes.timeText = [NSString stringWithFormat:@"%ld:%ld", start / 60, start % 60];
    timeAttributes.textColor = [UIColor customRedColor];
    timeAttributes.font = [UIFont system15RegularFont];
    timeAttributes.zIndex = currentTimeDecorationZIndex;
    return @[timeAttributes];
}

@end
