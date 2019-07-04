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
        self.showCurrentTime = YES;
        [self registerDecorationViewClasses];
        [self startTimeChangedTimer];
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
        [self prepareItemsAttributes];
    }
    if (![self.attributesCache objectForKey:dottedLineAttributesKey]) {
        [self prepareDottedLinesAttributes];
    }
    if (![self.attributesCache objectForKey:sectionTimeAttributesKey]) {
        [self prepareSectionTimesAttributes];
    }
    if (![self.attributesCache objectForKey:eventTimeAttributesKey]) {
        [self prepareEventTimesAttributes];
    }
    if (![self.attributesCache objectForKey:currentTimeLineAttributesKey]) {
        [self prepareCurrentTimeLineAttributes];
    }
    if (![self.attributesCache objectForKey:currentTimeAttributesKey]) {
        [self prepareCurrentTimeAttributes];
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
    if (self.showCurrentTime) {
        NSArray *currentTimeAttributes = [self.attributesCache objectForKey:currentTimeAttributesKey];
        [allAttributes addObjectsFromArray:currentTimeAttributes];
        NSArray *currentTimeLineAttributes = [self.attributesCache objectForKey:currentTimeLineAttributesKey];
        [allAttributes addObjectsFromArray:currentTimeLineAttributes];
    }
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

- (CGRect)sectionToShowCurrentTime {
    CGRect section = CGRectZero;
    NSArray *currentTimeLineAttributes = [self.attributesCache objectForKey:currentTimeLineAttributesKey];
    UICollectionViewLayoutAttributes *timeLineAttributes = currentTimeLineAttributes.firstObject;
    if (!timeLineAttributes) {
        [self prepareCurrentTimeLineAttributes];
        timeLineAttributes = [(NSArray *)[self.attributesCache objectForKey:currentTimeLineAttributesKey] firstObject];
    }
    CGFloat lineY = timeLineAttributes.frame.origin.y;
    CGFloat sectionY = (floor(lineY / sectionHeight) - 1) * sectionHeight + self.collectionView.bounds.size.height;
    sectionY = MIN(sectionY, self.collectionView.contentSize.height - 1);
    section = CGRectMake(0, sectionY, self.collectionView.bounds.size.width, 1);
    return section;
}

#pragma mark - Private

- (void)startTimeChangedTimer {
    NSDate *nextMinuteDate =  [[NSCalendar currentCalendar] nextDateAfterDate:[NSDate date] matchingUnit:NSCalendarUnitSecond value:0 options:NSCalendarMatchNextTime];
    NSTimer *minuteTimer = [[NSTimer alloc] initWithFireDate:nextMinuteDate interval:60 target:self selector:@selector(timeChanged) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:minuteTimer forMode:NSDefaultRunLoopMode];
}

- (void)timeChanged {
    [self.attributesCache removeObjectForKey:sectionTimeAttributesKey];
    [self.attributesCache removeObjectForKey:eventTimeAttributesKey];
    [self.attributesCache removeObjectForKey:currentTimeLineAttributesKey];
    [self.attributesCache removeObjectForKey:currentTimeAttributesKey];
    [self invalidateLayout];
}

- (void)registerDecorationViewClasses {
    [self registerClass:[DottedLineView class] forDecorationViewOfKind:dottedLineDecorationViewKind];
    [self registerClass:[TimeLabelView class] forDecorationViewOfKind:sectionTimeDecorationViewKind];
    [self registerClass:[TimeLabelView class] forDecorationViewOfKind:eventTimeDecorationViewKind];
    [self registerClass:[TimeLabelView class] forDecorationViewOfKind:currentTimeDecorationViewKind];
    [self registerClass:[CurrentTimeLineView class] forDecorationViewOfKind:currentTimeLineDecorationViewKind];
}

- (void)prepareItemsAttributes {
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
            CGFloat itemX = xOffset + self.collectionView.layoutMargins.left;
            CGFloat itemWidth = self.collectionView.bounds.size.width - xOffset - self.collectionView.layoutMargins.right - self.collectionView.layoutMargins.left;
            CGRect itemFrame = CGRectMake(itemX, itemY, itemWidth, itemHeight);
            UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            attr.frame = itemFrame;
            attr.zIndex = itemZIndex;
            [itemsAttributes addObject:attr];
        }
    }
    [self.attributesCache setObject:[itemsAttributes copy] forKey:itemAttributesKey];
    [self resolveIntersectingItems];
}

- (void)resolveIntersectingItems {
    NSArray *itemsAttributes = [self.attributesCache objectForKey:itemAttributesKey];
    if (!itemsAttributes) {
        return;
    }
    NSMutableArray *resolvedItemsAttributes = [NSMutableArray array];
    for (UICollectionViewLayoutAttributes *itemAttr in itemsAttributes) {
        if ([resolvedItemsAttributes containsObject:itemAttr]) {
            continue;
        }
        NSMutableArray *intersectingItems = [NSMutableArray array];
        __block CGFloat minY = CGRectGetMinY(itemAttr.frame);
        __block CGFloat maxY = CGRectGetMaxY(itemAttr.frame);
        for (UICollectionViewLayoutAttributes *attr in itemsAttributes) {
            if (CGRectIntersectsRect(attr.frame, itemAttr.frame)) {
                [intersectingItems addObject:attr];
                minY = MIN(minY, CGRectGetMinY(attr.frame));
                maxY = MAX(maxY, CGRectGetMaxY(attr.frame));
            }
        }
        if (intersectingItems.count == 0) { // no intersection
            [resolvedItemsAttributes addObject:itemAttr];
            continue;
        } // else we have "cluster" of intersecting items and its range on Y axis
        NSInteger numberOfColumns = 0;
        for (CGFloat y = minY; y <= maxY; y++) { // go through all the Y's and count intersecting items at this Y's
            NSInteger numberOfIntersectingItemsForY = 0;
            for (UICollectionViewLayoutAttributes *attr in intersectingItems) {
                if (CGRectGetMinY(attr.frame) <= y && CGRectGetMaxY(attr.frame) >= y) {
                    numberOfIntersectingItemsForY += 1;
                }
            }
            if (numberOfIntersectingItemsForY > numberOfColumns) {
                numberOfColumns = numberOfIntersectingItemsForY; // number of columns is the maximum number of intersecting items
            }
        }
        CGFloat itemWidth = (itemAttr.frame.size.width - eventsSpacing * (numberOfColumns - 1)) / numberOfColumns;
        for (UICollectionViewLayoutAttributes *attr in intersectingItems) {
            CGRect attrFrame = attr.frame;
            attrFrame.size.width = itemWidth;
            attr.frame = attrFrame;
        }
        for (int earlierIndex = 0; earlierIndex < intersectingItems.count; earlierIndex++) {
            UICollectionViewLayoutAttributes *earlierAttr = intersectingItems[earlierIndex];
            for (int laterIndex = earlierIndex + 1; laterIndex < intersectingItems.count; laterIndex++) {
                UICollectionViewLayoutAttributes *laterAttr = intersectingItems[laterIndex];
                if (CGRectIntersectsRect(laterAttr.frame, earlierAttr.frame)) { // move items to the right if needed
                    CGRect laterAttrFrame = laterAttr.frame;
                    laterAttrFrame.origin.x += itemWidth + eventsSpacing;
                    laterAttr.frame = laterAttrFrame;
                }
            }
            [resolvedItemsAttributes addObject:earlierAttr];
        }
    }
    [self.attributesCache setObject:[resolvedItemsAttributes copy] forKey:itemAttributesKey];
}

- (void)prepareDottedLinesAttributes {
    NSMutableArray *linesAttributes = [NSMutableArray array];
    for (int i = 1; i < numberOfSections; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i-1 inSection:0];
        CGRect viewFrame = CGRectMake(0, i * sectionHeight - dotSize / 2, self.collectionView.bounds.size.width, dotSize);
        UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:dottedLineDecorationViewKind withIndexPath:indexPath];
        attr.frame = viewFrame;
        attr.zIndex = decorationZIndex;
        [linesAttributes addObject:attr];
    }
    [self.attributesCache setObject:[linesAttributes copy] forKey:dottedLineAttributesKey];
}

- (void)prepareSectionTimesAttributes {
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
    [self.attributesCache setObject:[timesAttributes copy] forKey:sectionTimeAttributesKey];
}

- (void)prepareEventTimesAttributes {
    //TODO: several events in the same section
    NSMutableArray *timesAttributes = [NSMutableArray array];
    if ([self.dataSource respondsToSelector:@selector(startOfEventAtIndexPath:)]) {
        for (int i = 0; i < [self.collectionView numberOfItemsInSection:0]; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
            NSInteger start = [self.dataSource startOfEventAtIndexPath:indexPath];
            NSInteger section = start / minutesInSection;
            if (section % numberOfSectionsInHour == 0) {
                NSArray *sectionTimesAttributes = [self.attributesCache objectForKey:sectionTimeAttributesKey];
                if (sectionTimesAttributes) {
                    NSMutableArray *attributesWithoutEventSection = [NSMutableArray arrayWithArray:sectionTimesAttributes];
                    [attributesWithoutEventSection removeObjectAtIndex:(section / numberOfSectionsInHour)];
                    sectionTimesAttributes = [attributesWithoutEventSection copy];
                    [self.attributesCache setObject:sectionTimesAttributes forKey:sectionTimeAttributesKey];
                }
            }
            CGRect viewFrame = CGRectMake(self.collectionView.layoutMargins.left, section * sectionHeight, xOffset, sectionHeight);
            TimeLabelViewLayoutAttributes *attr = [TimeLabelViewLayoutAttributes layoutAttributesForDecorationViewOfKind:eventTimeDecorationViewKind withIndexPath:indexPath];
            attr.frame = viewFrame;
            attr.timeText = [NSString stringWithFormat:@"%ld:%02ld", start / 60, start % 60];
            attr.textColor = [UIColor customBlackColor];
            attr.font = [UIFont system15RegularFont];
            attr.zIndex = decorationZIndex;
            [timesAttributes addObject:attr];
        }
    }
    [self.attributesCache setObject:[timesAttributes copy] forKey:eventTimeAttributesKey];
}

- (void)prepareCurrentTimeLineAttributes {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    UICollectionViewLayoutAttributes *lineAttributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:currentTimeLineDecorationViewKind withIndexPath:indexPath];
    NSDate *today = [NSDate date];
    NSDate *startOfDay = [[NSCalendar currentCalendar] startOfDayForDate:today];
    NSInteger start = [[NSCalendar currentCalendar] components:NSCalendarUnitMinute fromDate:startOfDay toDate:today options:0].minute;
    CGFloat lineY = 1.0 * start / minutesInSection * sectionHeight;
    CGRect viewFrame = CGRectMake(xOffset, lineY, self.collectionView.bounds.size.width - xOffset, 1);
    lineAttributes.frame = viewFrame;
    lineAttributes.zIndex = decorationZIndex;
    [self.attributesCache setObject:@[lineAttributes] forKey:currentTimeLineAttributesKey];
}

- (void)prepareCurrentTimeAttributes {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    TimeLabelViewLayoutAttributes *timeAttributes = [TimeLabelViewLayoutAttributes layoutAttributesForDecorationViewOfKind:currentTimeDecorationViewKind withIndexPath:indexPath];
    NSDate *today = [NSDate date];
    NSDate *startOfDay = [[NSCalendar currentCalendar] startOfDayForDate:today];
    NSInteger start = [[NSCalendar currentCalendar] components:NSCalendarUnitMinute fromDate:startOfDay toDate:today options:0].minute;
    CGFloat lineY = 1.0 * start / minutesInSection * sectionHeight;
    CGFloat timeY = lineY - sectionHeight / 2.0;
    NSArray *sectionTimesAttributes = [self.attributesCache objectForKey:sectionTimeAttributesKey];
    if (sectionTimesAttributes) {
        NSMutableArray *attributesWithoutCurrentSection = [NSMutableArray arrayWithArray:sectionTimesAttributes];
        [sectionTimesAttributes enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            TimeLabelViewLayoutAttributes *attr = (TimeLabelViewLayoutAttributes *)obj;
            if (CGRectGetMinY(attr.frame) <= lineY && CGRectGetMaxY(attr.frame) > lineY) {
                [attributesWithoutCurrentSection removeObjectAtIndex:idx];
                *stop = YES;
            }
        }];
        sectionTimesAttributes = [attributesWithoutCurrentSection copy];
        [self.attributesCache setObject:sectionTimesAttributes forKey:sectionTimeAttributesKey];
    }
    NSArray *eventTimesAttributes = [self.attributesCache objectForKey:eventTimeAttributesKey];
    if (eventTimesAttributes) {
        NSMutableArray *attributesWithoutCurrentSection = [NSMutableArray arrayWithArray:eventTimesAttributes];
        [eventTimesAttributes enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            TimeLabelViewLayoutAttributes *attr = (TimeLabelViewLayoutAttributes *)obj;
            if (CGRectGetMinY(attr.frame) <= lineY && CGRectGetMaxY(attr.frame) > lineY) {
                [attributesWithoutCurrentSection removeObjectAtIndex:idx];
                *stop = YES;
            }
        }];
        eventTimesAttributes = [attributesWithoutCurrentSection copy];
        [self.attributesCache setObject:eventTimesAttributes forKey:eventTimeAttributesKey];
    }
    CGRect viewFrame = CGRectMake(self.collectionView.layoutMargins.left, timeY, xOffset, sectionHeight);
    timeAttributes.frame = viewFrame;
    timeAttributes.timeText = [NSString stringWithFormat:@"%ld:%02ld", start / 60, start % 60];
    timeAttributes.textColor = [UIColor customRedColor];
    timeAttributes.font = [UIFont system15RegularFont];
    timeAttributes.zIndex = currentTimeDecorationZIndex;
    [self.attributesCache setObject:@[timeAttributes] forKey:currentTimeAttributesKey];
}

@end
