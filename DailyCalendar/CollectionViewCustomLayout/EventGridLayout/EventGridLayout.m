//
//  EventGridLayout.m
//  DailyCalendar
//
//  Created by Liubou Sakalouskaya on 7/3/19.
//  Copyright © 2019 Liubou Sakalouskaya. All rights reserved.
//

#import "EventGridLayout.h"
#import "UIColor+CustomColors.h"
#import "UIFont+CustomFonts.h"
#import "DottedLineView.h"
#import "TimeLabelView.h"
#import "TimeLabelViewLayoutAttributes.h"

const CGFloat sectionHeight = 35.0;
const CGFloat xOffset = 55.0;
const NSInteger numberOfHours = 24;
const NSInteger minutesInSection = 15;
const NSInteger minutesInHour = 60;
const NSInteger numberOfSectionsInHour = minutesInHour / minutesInSection;
const NSInteger numberOfSections = numberOfHours * numberOfSectionsInHour;
const NSInteger itemZIndex = 1;
const NSInteger decorationZIndex = 0;
NSString * const itemAttributesKey = @"itemAttributesKey";
NSString * const dottedLineAttributesKey = @"dottedLineAttributesKey";
NSString * const dottedLineDecorationViewKind = @"dottedLineDecorationViewKind";
NSString * const sectionTimeAttributesKey = @"sectionTimeAttributesKey";
NSString * const sectionTimeDecorationViewKind = @"sectionTimeDecorationViewKind";
NSString * const eventTimeAttributesKey = @"eventTimeAttributesKey";
NSString * const eventTimeDecorationViewKind = @"eventTimeDecorationViewKind";
NSString * const currentTimeAttributesKey = @"currentTimeAttributesKey";
NSString * const currentTimeDecorationViewKind = @"currentTimeDecorationViewKind";

@interface EventGridLayout ()

@property (strong, nonatomic) NSCache *attributesCache;

@end

@implementation EventGridLayout
//TODO: add separate file for constants

- (void)registerDecorationClasses {
    //TODO: enum for decoration view kinds
    [self registerClass:[DottedLineView class] forDecorationViewOfKind:dottedLineDecorationViewKind];
    [self registerClass:[TimeLabelView class] forDecorationViewOfKind:sectionTimeDecorationViewKind];
    [self registerClass:[TimeLabelView class] forDecorationViewOfKind:eventTimeDecorationViewKind];
    //[self registerClass:[TimeLabelView class] forDecorationViewOfKind:currentTimeDecorationViewKind];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self registerDecorationClasses];
    }
    return self;
}

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
            CGFloat itemWidth = self.collectionView.bounds.size.width - xOffset - self.collectionView.layoutMargins.right;
            CGRect itemFrame = CGRectMake(xOffset, itemY, itemWidth, itemHeight);
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
    for (UICollectionViewLayoutAttributes *attributes in allAttributes) {
        if (CGRectIntersectsRect(attributes.frame, rect)) {
            [rectAttributes addObject:attributes];
        }
    }
    return [rectAttributes copy];
}

- (void)invalidateLayout {
    [super invalidateLayout];
    [self.attributesCache removeAllObjects];
}

@end
