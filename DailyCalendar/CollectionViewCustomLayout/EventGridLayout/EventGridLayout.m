//
//  EventGridLayout.m
//  DailyCalendar
//
//  Created by Liubou Sakalouskaya on 7/3/19.
//  Copyright © 2019 Liubou Sakalouskaya. All rights reserved.
//

#import "EventGridLayout.h"
#import "DottedLineView.h"

const CGFloat sectionHeight = 35.0;
const NSInteger numberOfSections = 24 * 4;
const NSInteger minutesInSection = 15;
const NSInteger itemZIndex = 1;
const NSInteger dottedLineZIndex = 0;
NSString * const itemsAttributesKey = @"itemsAttributesKey";
NSString * const dottedLinesAttributesKey = @"dottedLinesAttributesKey";
NSString * const dottedLineDecorationViewKind = @"dottedLineDecorationViewKind";

@interface EventGridLayout ()

@property (strong, nonatomic) NSCache *attributesCache;

@end

@implementation EventGridLayout

- (void)registerDecorationClasses {
    //TODO: enum for decoration view kinds
    [self registerClass:[DottedLineView class] forDecorationViewOfKind:dottedLineDecorationViewKind];
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
    if (![self.attributesCache objectForKey:itemsAttributesKey]) {
        NSMutableArray *itemsAttributes = [NSMutableArray array];
        if ([self.dataSource respondsToSelector:@selector(durationOfEventAtIndexPath:)] &&
            [self.dataSource respondsToSelector:@selector(startOfEventAtIndexPath:)]) {
            for (int i = 0; i < [self.collectionView numberOfItemsInSection:0]; i++) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
                NSInteger minutes = [self.dataSource durationOfEventAtIndexPath:indexPath];
                CGFloat itemHeight = minutes / minutesInSection * sectionHeight;
                NSInteger start = [self.dataSource startOfEventAtIndexPath:indexPath];
                CGFloat itemY = start / minutesInSection * sectionHeight;
                if (itemY + itemHeight > self.collectionView.contentSize.height) {
                    itemHeight = self.collectionView.contentSize.height - itemY;
                }
                CGRect itemFrame = CGRectMake(0, itemY, self.collectionView.bounds.size.width, itemHeight);
                UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
                attr.frame = itemFrame;
                attr.zIndex = itemZIndex;
                [itemsAttributes addObject:attr];
            }
        }
        [self.attributesCache setObject:itemsAttributes forKey:itemsAttributesKey];
    }
    if (![self.attributesCache objectForKey:dottedLinesAttributesKey]) {
        NSMutableArray *itemsAttributes = [NSMutableArray array];
        for (int i = 1; i < numberOfSections; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i-1 inSection:0];
            CGRect viewFrame = CGRectMake(0, i * sectionHeight, self.collectionView.bounds.size.width, dotSize);
            UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:dottedLineDecorationViewKind withIndexPath:indexPath];
            attr.frame = viewFrame;
            attr.zIndex = dottedLineZIndex;
            [itemsAttributes addObject:attr];
        }
        [self.attributesCache setObject:itemsAttributes forKey:dottedLinesAttributesKey];
    }
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *rectAttributes = [NSMutableArray array];
    NSArray *itemsAttributes = [self.attributesCache objectForKey:itemsAttributesKey];
    for (UICollectionViewLayoutAttributes *attributes in itemsAttributes) {
        if (CGRectIntersectsRect(attributes.frame, rect)) {
            [rectAttributes addObject:attributes];
        }
    }
    NSArray *dottedLinesAttributes = [self.attributesCache objectForKey:dottedLinesAttributesKey];
    for (UICollectionViewLayoutAttributes *attributes in dottedLinesAttributes) {
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
