//
//  WeekCollectionView.h
//  DailyCalendar
//
//  Created by Liubou Sakalouskaya on 6/29/19.
//  Copyright © 2019 Liubou Sakalouskaya. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class WeekCollectionView;

@protocol WeekCollectionViewDelegate <NSObject>

- (void)weekCollectionView:(WeekCollectionView *)weekCollectionView didTapOnItem:(UICollectionViewCell *)item;

@end

@interface WeekCollectionView : UIView

@property (weak, nonatomic) id<WeekCollectionViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
