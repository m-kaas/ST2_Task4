//
//  EventGridLayout.m
//  DailyCalendar
//
//  Created by Liubou Sakalouskaya on 7/3/19.
//  Copyright © 2019 Liubou Sakalouskaya. All rights reserved.
//

#import "EventGridLayout.h"

const CGFloat sectionHeight = 20.0;
const NSInteger numberOfSections = 24 * 4;
const NSInteger minutesInSection = 15;
NSString * const itemsAttributesKey = @"itemsAttributesKey";

@interface EventGridLayout ()

@property (strong, nonatomic) NSCache *attributesCache;

@end

@implementation EventGridLayout

- (CGSize)collectionViewContentSize {
    return CGSizeMake(self.collectionView.bounds.size.width, numberOfSections * sectionHeight);
}

- (void)prepareLayout {
    NSLog(@"enter prepareLayout");
    if (!self.attributesCache) {
        self.attributesCache = [NSCache new];
    }
    if (![self.attributesCache objectForKey:itemsAttributesKey]) {
        NSLog(@"calculate frames");
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
                [itemsAttributes addObject:attr];
            }
        }
        NSLog(@"add %ld attributes", itemsAttributes.count);
        [self.attributesCache setObject:itemsAttributes forKey:itemsAttributesKey];
    }
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSLog(@"enter layoutAttributesForElementsInRect");
    NSMutableArray *rectAttributes = [NSMutableArray array];
    NSArray *itemsAttributes = [self.attributesCache objectForKey:itemsAttributesKey];
    for (UICollectionViewLayoutAttributes *attributes in itemsAttributes) {
        if (CGRectIntersectsRect(attributes.frame, rect)) {
            [rectAttributes addObject:attributes];
        }
    }
    return [rectAttributes copy];
}

- (void)invalidateLayout {
    [super invalidateLayout];
    [self.attributesCache removeAllObjects];
    NSLog(@"invalidate layout");
}

@end
