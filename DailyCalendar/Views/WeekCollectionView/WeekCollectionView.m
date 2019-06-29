//
//  WeekCollectionView.m
//  DailyCalendar
//
//  Created by Liubou Sakalouskaya on 6/29/19.
//  Copyright © 2019 Liubou Sakalouskaya. All rights reserved.
//

#import "WeekCollectionView.h"

@interface WeekCollectionView ()

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation WeekCollectionView

#pragma mark - Lifecycle

- (void)loadXibFile {
    UIView *weekView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] firstObject];
    [self addSubview:weekView];
    weekView.frame = self.bounds;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self loadXibFile];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self loadXibFile];
    }
    return self;
}

#pragma mark - UICollectionViewDataSource

#pragma mark - UICollectionViewDelegate

@end
